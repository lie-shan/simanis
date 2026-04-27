const db = require('../config/database');

// Get all pembayaran
exports.getAllPembayaran = async (req, res) => {
  try {
    const { siswa_id, status, jenis_pembayaran, bulan, tahun } = req.query;

    let query = `
      SELECT p.id, p.kode_transaksi, p.siswa_id, p.jenis_pembayaran, p.jumlah, 
             p.tanggal_jatuh_tempo, p.tanggal_bayar, p.status, p.metode_pembayaran, 
             p.keterangan, p.created_at, p.updated_at,
             s.nis, s.nama as nama_siswa, k.nama_kelas
      FROM pembayaran p
      JOIN siswa s ON p.siswa_id = s.id
      LEFT JOIN kelas k ON s.kelas_id = k.id
      WHERE 1=1
    `;
    const params = [];

    if (siswa_id) {
      query += ' AND p.siswa_id = ?';
      params.push(siswa_id);
    }
    if (status) {
      query += ' AND p.status = ?';
      params.push(status);
    }
    if (jenis_pembayaran) {
      query += ' AND p.jenis_pembayaran = ?';
      params.push(jenis_pembayaran);
    }
    if (bulan) {
      query += ' AND MONTH(p.tanggal_jatuh_tempo) = ?';
      params.push(bulan);
    }
    if (tahun) {
      query += ' AND YEAR(p.tanggal_jatuh_tempo) = ?';
      params.push(tahun);
    }

    query += ' ORDER BY p.created_at DESC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all pembayaran error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data pembayaran'
    });
  }
};

// Get pembayaran by ID or kode_transaksi
exports.getPembayaranById = async (req, res) => {
  try {
    const { id } = req.params;
    
    // Cek apakah id adalah kode_transaksi (TRX-*) atau numeric id
    const isKodeTransaksi = id.toString().startsWith('TRX-');
    const whereClause = isKodeTransaksi ? 'p.kode_transaksi = ?' : 'p.id = ?';

    const [rows] = await db.query(
      `SELECT p.id, p.kode_transaksi, p.siswa_id, p.jenis_pembayaran, p.jumlah, 
              p.tanggal_jatuh_tempo, p.tanggal_bayar, p.status, p.metode_pembayaran, 
              p.keterangan, p.created_at, p.updated_at,
              s.nis, s.nama as nama_siswa, k.nama_kelas, s.nama_wali, s.no_hp_wali
       FROM pembayaran p
       JOIN siswa s ON p.siswa_id = s.id
       LEFT JOIN kelas k ON s.kelas_id = k.id
       WHERE ${whereClause}`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pembayaran tidak ditemukan'
      });
    }

    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error('Get pembayaran by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data pembayaran'
    });
  }
};

// Get pembayaran by siswa
exports.getPembayaranBySiswa = async (req, res) => {
  try {
    const { siswa_id } = req.params;
    const { tahun } = req.query;

    // Verify siswa exists
    const [siswaCheck] = await db.query(
      `SELECT s.*, k.nama_kelas FROM siswa s LEFT JOIN kelas k ON s.kelas_id = k.id WHERE s.id = ?`,
      [siswa_id]
    );
    if (siswaCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa tidak ditemukan'
      });
    }

    let query = 'SELECT * FROM pembayaran WHERE siswa_id = ?';
    const params = [siswa_id];

    if (tahun) {
      query += ' AND YEAR(tanggal_jatuh_tempo) = ?';
      params.push(tahun);
    }

    query += ' ORDER BY tanggal_jatuh_tempo DESC';

    const [rows] = await db.query(query, params);

    // Get summary
    const [summary] = await db.query(
      `SELECT status,
              COUNT(*) as total,
              SUM(jumlah) as total_jumlah
       FROM pembayaran
       WHERE siswa_id = ? ${tahun ? 'AND YEAR(tanggal_jatuh_tempo) = ?' : ''}
       GROUP BY status`,
      params
    );

    // Calculate totals
    const totalTagihan = summary.reduce((sum, item) => sum + parseFloat(item.total_jumlah || 0), 0);
    const totalLunas = summary
      .filter(item => item.status === 'lunas')
      .reduce((sum, item) => sum + parseFloat(item.total_jumlah || 0), 0);
    const totalBelumBayar = summary
      .filter(item => item.status !== 'lunas')
      .reduce((sum, item) => sum + parseFloat(item.total_jumlah || 0), 0);

    res.json({
      success: true,
      data: {
        siswa: siswaCheck[0],
        pembayaran: rows,
        summary: summary,
        total_tagihan: totalTagihan,
        total_lunas: totalLunas,
        total_belum_bayar: totalBelumBayar
      }
    });
  } catch (error) {
    console.error('Get pembayaran by siswa error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data pembayaran'
    });
  }
};

// Create pembayaran
exports.createPembayaran = async (req, res) => {
  try {
    const {
      siswa_id, jenis_pembayaran, jumlah, tanggal_jatuh_tempo,
      keterangan, kode_transaksi, status, tanggal_bayar, metode_pembayaran
    } = req.body;

    // Validate required fields
    if (!siswa_id || !jenis_pembayaran || !jumlah || !tanggal_jatuh_tempo) {
      return res.status(400).json({
        success: false,
        message: 'Siswa, jenis pembayaran, jumlah, dan tanggal jatuh tempo wajib diisi'
      });
    }

    // Verify siswa exists
    const [siswaCheck] = await db.query('SELECT id FROM siswa WHERE id = ?', [siswa_id]);
    if (siswaCheck.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Siswa tidak ditemukan'
      });
    }

    // Tentukan status dan tanggal bayar
    const finalStatus = status || 'belum_bayar';
    const finalTanggalBayar = (finalStatus === 'lunas' && tanggal_bayar) ? tanggal_bayar : null;
    const finalMetodeBayar = (finalStatus === 'lunas' && metode_pembayaran) ? metode_pembayaran : null;

    // Create pembayaran dengan data lengkap
    const [result] = await db.query(
      `INSERT INTO pembayaran (kode_transaksi, siswa_id, jenis_pembayaran, jumlah, tanggal_jatuh_tempo, status, tanggal_bayar, metode_pembayaran, keterangan)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [kode_transaksi || null, siswa_id, jenis_pembayaran, jumlah, tanggal_jatuh_tempo, finalStatus, finalTanggalBayar, finalMetodeBayar, keterangan]
    );

    // Get created pembayaran
    const [created] = await db.query(
      `SELECT p.*, s.nis, s.nama as nama_siswa, k.nama_kelas
       FROM pembayaran p
       JOIN siswa s ON p.siswa_id = s.id
       LEFT JOIN kelas k ON s.kelas_id = k.id
       WHERE p.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Pembayaran berhasil ditambahkan',
      data: created[0]
    });
  } catch (error) {
    console.error('Create pembayaran error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan pembayaran'
    });
  }
};

// Bulk create pembayaran (for a class)
exports.createBulkPembayaran = async (req, res) => {
  try {
    const { kelas_id, jenis_pembayaran, jumlah, tanggal_jatuh_tempo, keterangan } = req.body;

    if (!kelas_id || !jenis_pembayaran || !jumlah || !tanggal_jatuh_tempo) {
      return res.status(400).json({
        success: false,
        message: 'Kelas, jenis pembayaran, jumlah, dan tanggal jatuh tempo wajib diisi'
      });
    }

    // Get all siswa in kelas
    const [siswaRows] = await db.query(
      'SELECT id FROM siswa WHERE kelas_id = ?',
      [kelas_id]
    );

    if (siswaRows.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Tidak ada siswa di kelas ini'
      });
    }

    const connection = await db.getConnection();
    await connection.beginTransaction();

    try {
      const results = [];

      for (const siswa of siswaRows) {
        const [result] = await connection.query(
          `INSERT INTO pembayaran (siswa_id, jenis_pembayaran, jumlah, tanggal_jatuh_tempo, status, keterangan)
           VALUES (?, ?, ?, ?, 'belum_bayar', ?)`,
          [siswa.id, jenis_pembayaran, jumlah, tanggal_jatuh_tempo, keterangan]
        );
        results.push({ siswa_id: siswa.id, pembayaran_id: result.insertId });
      }

      await connection.commit();

      res.status(201).json({
        success: true,
        message: `${results.length} tagihan berhasil ditambahkan`,
        data: results
      });
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Create bulk pembayaran error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan tagihan'
    });
  }
};

// Update pembayaran (for editing tagihan)
exports.updatePembayaran = async (req, res) => {
  try {
    const { id } = req.params;
    const { jenis_pembayaran, jumlah, tanggal_jatuh_tempo, keterangan } = req.body;

    // Cek apakah id adalah kode_transaksi (TRX-*) atau numeric id
    const isKodeTransaksi = id.toString().startsWith('TRX-');
    const whereClause = isKodeTransaksi ? 'kode_transaksi = ?' : 'id = ?';

    // Check if pembayaran exists
    const [existing] = await db.query(`SELECT * FROM pembayaran WHERE ${whereClause}`, [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pembayaran tidak ditemukan'
      });
    }

    const pembayaran = existing[0];
    const dbId = pembayaran.id; // Gunakan id numeric untuk update

    // Can only edit if not yet paid
    if (pembayaran.status === 'lunas' && jumlah) {
      return res.status(400).json({
        success: false,
        message: 'Tidak dapat mengubah jumlah pembayaran yang sudah lunas'
      });
    }

    // Update pembayaran
    await db.query(
      `UPDATE pembayaran SET
        jenis_pembayaran = COALESCE(?, jenis_pembayaran),
        jumlah = COALESCE(?, jumlah),
        tanggal_jatuh_tempo = COALESCE(?, tanggal_jatuh_tempo),
        keterangan = COALESCE(?, keterangan)
       WHERE id = ?`,
      [jenis_pembayaran, jumlah, tanggal_jatuh_tempo, keterangan, dbId]
    );

    // Get updated pembayaran
    const [updated] = await db.query(
      `SELECT p.id, p.kode_transaksi, p.siswa_id, p.jenis_pembayaran, p.jumlah, 
              p.tanggal_jatuh_tempo, p.tanggal_bayar, p.status, p.metode_pembayaran, 
              p.keterangan, p.created_at, p.updated_at,
              s.nis, s.nama as nama_siswa, k.nama_kelas
       FROM pembayaran p
       JOIN siswa s ON p.siswa_id = s.id
       LEFT JOIN kelas k ON s.kelas_id = k.id
       WHERE p.id = ?`,
      [dbId]
    );

    res.json({
      success: true,
      message: 'Pembayaran berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update pembayaran error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui pembayaran'
    });
  }
};

// Process payment (bayar)
exports.processPayment = async (req, res) => {
  try {
    const { id } = req.params;
    const { metode_pembayaran, bukti_pembayaran } = req.body;

    // Cek apakah id adalah kode_transaksi (TRX-*) atau numeric id
    const isKodeTransaksi = id.toString().startsWith('TRX-');
    const whereClause = isKodeTransaksi ? 'kode_transaksi = ?' : 'id = ?';

    // Check if pembayaran exists
    const [existing] = await db.query(`SELECT * FROM pembayaran WHERE ${whereClause}`, [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pembayaran tidak ditemukan'
      });
    }

    const pembayaran = existing[0];
    const dbId = pembayaran.id;

    if (pembayaran.status === 'lunas') {
      return res.status(400).json({
        success: false,
        message: 'Pembayaran sudah lunas'
      });
    }

    // Check if late
    const today = new Date().toISOString().split('T')[0];
    const status = today > pembayaran.tanggal_jatuh_tempo ? 'terlambat' : 'lunas';

    // Update pembayaran
    await db.query(
      `UPDATE pembayaran SET
        status = ?,
        tanggal_bayar = CURRENT_DATE,
        metode_pembayaran = ?,
        bukti_pembayaran = ?
       WHERE id = ?`,
      [status, metode_pembayaran, bukti_pembayaran, dbId]
    );

    // Get updated pembayaran
    const [updated] = await db.query(
      `SELECT p.id, p.kode_transaksi, p.siswa_id, p.jenis_pembayaran, p.jumlah, 
              p.tanggal_jatuh_tempo, p.tanggal_bayar, p.status, p.metode_pembayaran, 
              p.keterangan, p.created_at, p.updated_at,
              s.nis, s.nama as nama_siswa, k.nama_kelas
       FROM pembayaran p
       JOIN siswa s ON p.siswa_id = s.id
       LEFT JOIN kelas k ON s.kelas_id = k.id
       WHERE p.id = ?`,
      [dbId]
    );

    res.json({
      success: true,
      message: 'Pembayaran berhasil diproses',
      data: updated[0]
    });
  } catch (error) {
    console.error('Process payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memproses pembayaran'
    });
  }
};

// Cancel payment
exports.cancelPayment = async (req, res) => {
  try {
    const { id } = req.params;

    // Cek apakah id adalah kode_transaksi (TRX-*) atau numeric id
    const isKodeTransaksi = id.toString().startsWith('TRX-');
    const whereClause = isKodeTransaksi ? 'kode_transaksi = ?' : 'id = ?';

    // Check if pembayaran exists
    const [existing] = await db.query(`SELECT * FROM pembayaran WHERE ${whereClause}`, [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pembayaran tidak ditemukan'
      });
    }

    const pembayaran = existing[0];
    const dbId = pembayaran.id;

    if (pembayaran.status === 'belum_bayar') {
      return res.status(400).json({
        success: false,
        message: 'Pembayaran belum dilakukan'
      });
    }

    // Revert to unpaid
    await db.query(
      `UPDATE pembayaran SET
        status = 'belum_bayar',
        tanggal_bayar = NULL,
        metode_pembayaran = NULL,
        bukti_pembayaran = NULL
       WHERE id = ?`,
      [dbId]
    );

    res.json({
      success: true,
      message: 'Pembayaran berhasil dibatalkan'
    });
  } catch (error) {
    console.error('Cancel payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat membatalkan pembayaran'
    });
  }
};

// Delete pembayaran
exports.deletePembayaran = async (req, res) => {
  try {
    const { id } = req.params;

    // Cek apakah id adalah kode_transaksi (TRX-*) atau numeric id
    const isKodeTransaksi = id.toString().startsWith('TRX-');
    const whereClause = isKodeTransaksi ? 'kode_transaksi = ?' : 'id = ?';

    const [existing] = await db.query(`SELECT * FROM pembayaran WHERE ${whereClause}`, [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pembayaran tidak ditemukan'
      });
    }

    const pembayaran = existing[0];
    const dbId = pembayaran.id;

    await db.query('DELETE FROM pembayaran WHERE id = ?', [dbId]);

    res.json({
      success: true,
      message: 'Pembayaran berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete pembayaran error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus pembayaran'
    });
  }
};

// Get pembayaran statistics
exports.getPembayaranStats = async (req, res) => {
  try {
    const { tahun, bulan } = req.query;

    let whereClause = '';
    const params = [];

    if (tahun) {
      whereClause += ' AND YEAR(p.tanggal_jatuh_tempo) = ?';
      params.push(tahun);
    }
    if (bulan) {
      whereClause += ' AND MONTH(p.tanggal_jatuh_tempo) = ?';
      params.push(bulan);
    }

    // Overall stats by status
    const [statusStats] = await db.query(
      `SELECT p.status,
              COUNT(*) as total,
              SUM(p.jumlah) as total_jumlah
       FROM pembayaran p
       WHERE 1=1 ${whereClause}
       GROUP BY p.status`,
      params
    );

    // Stats by jenis_pembayaran
    const [jenisStats] = await db.query(
      `SELECT p.jenis_pembayaran,
              COUNT(*) as total,
              SUM(CASE WHEN p.status = 'lunas' THEN p.jumlah ELSE 0 END) as total_lunas,
              SUM(CASE WHEN p.status != 'lunas' THEN p.jumlah ELSE 0 END) as total_belum
       FROM pembayaran p
       WHERE 1=1 ${whereClause}
       GROUP BY p.jenis_pembayaran`,
      params
    );

    // Stats per kelas
    const [kelasStats] = await db.query(
      `SELECT k.nama_kelas,
              COUNT(*) as total_tagihan,
              SUM(CASE WHEN p.status = 'lunas' THEN 1 ELSE 0 END) as total_lunas,
              SUM(CASE WHEN p.status != 'lunas' THEN 1 ELSE 0 END) as total_belum_bayar,
              SUM(p.jumlah) as total_jumlah
       FROM pembayaran p
       JOIN siswa s ON p.siswa_id = s.id
       JOIN kelas k ON s.kelas_id = k.id
       WHERE 1=1 ${whereClause}
       GROUP BY k.id, k.nama_kelas
       ORDER BY k.nama_kelas`,
      params
    );

    // Monthly trend (last 12 months)
    const [monthlyTrend] = await db.query(
      `SELECT DATE_FORMAT(tanggal_bayar, '%Y-%m') as bulan,
              COUNT(*) as total_pembayaran,
              SUM(jumlah) as total_jumlah
       FROM pembayaran
       WHERE status = 'lunas'
         AND tanggal_bayar >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
       GROUP BY DATE_FORMAT(tanggal_bayar, '%Y-%m')
       ORDER BY bulan`,
      []
    );

    // Calculate totals
    const totalTagihan = statusStats.reduce((sum, item) => sum + parseFloat(item.total_jumlah || 0), 0);
    const totalLunas = statusStats
      .filter(item => item.status === 'lunas')
      .reduce((sum, item) => sum + parseFloat(item.total_jumlah || 0), 0);
    const totalBelumBayar = statusStats
      .filter(item => item.status !== 'lunas')
      .reduce((sum, item) => sum + parseFloat(item.total_jumlah || 0), 0);

    res.json({
      success: true,
      data: {
        status: statusStats,
        jenis_pembayaran: jenisStats,
        per_kelas: kelasStats,
        monthly_trend: monthlyTrend,
        total_tagihan: totalTagihan,
        total_lunas: totalLunas,
        total_belum_bayar: totalBelumBayar
      }
    });
  } catch (error) {
    console.error('Get pembayaran stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil statistik pembayaran'
    });
  }
};

// Get jenis pembayaran options
exports.getJenisPembayaran = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT DISTINCT jenis_pembayaran,
              COUNT(*) as total,
              AVG(jumlah) as rata_rata_jumlah
       FROM pembayaran
       GROUP BY jenis_pembayaran`
    );

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get jenis pembayaran error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data jenis pembayaran'
    });
  }
};
