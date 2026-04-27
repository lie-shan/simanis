const db = require('../config/database');

// Get all presensi
exports.getAllPresensi = async (req, res) => {
  try {
    const { siswa_id, tanggal, status, kelas_id, bulan, tahun } = req.query;

    let query = `
      SELECT p.*, s.nis, s.nama as nama_siswa, s.kelas_id, k.nama_kelas
      FROM presensi p
      JOIN siswa s ON p.siswa_id = s.id
      LEFT JOIN kelas k ON s.kelas_id = k.id
      WHERE 1=1
    `;
    const params = [];

    if (siswa_id) {
      query += ' AND p.siswa_id = ?';
      params.push(siswa_id);
    }
    if (tanggal) {
      query += ' AND p.tanggal = ?';
      params.push(tanggal);
    }
    if (status) {
      query += ' AND p.status = ?';
      params.push(status);
    }
    if (kelas_id) {
      query += ' AND s.kelas_id = ?';
      params.push(kelas_id);
    }
    if (bulan) {
      query += ' AND MONTH(p.tanggal) = ?';
      params.push(bulan);
    }
    if (tahun) {
      query += ' AND YEAR(p.tanggal) = ?';
      params.push(tahun);
    }

    query += ' ORDER BY p.tanggal DESC, s.nama ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all presensi error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data presensi'
    });
  }
};

// Get presensi by siswa
exports.getPresensiBySiswa = async (req, res) => {
  try {
    const { siswa_id } = req.params;
    const { bulan, tahun } = req.query;

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

    let query = 'SELECT * FROM presensi WHERE siswa_id = ?';
    const params = [siswa_id];

    if (bulan) {
      query += ' AND MONTH(tanggal) = ?';
      params.push(bulan);
    }
    if (tahun) {
      query += ' AND YEAR(tanggal) = ?';
      params.push(tahun);
    }

    query += ' ORDER BY tanggal DESC';

    const [rows] = await db.query(query, params);

    // Get summary
    const [summary] = await db.query(
      `SELECT status, COUNT(*) as total
       FROM presensi
       WHERE siswa_id = ? ${bulan ? 'AND MONTH(tanggal) = ?' : ''} ${tahun ? 'AND YEAR(tanggal) = ?' : ''}
       GROUP BY status`,
      params
    );

    res.json({
      success: true,
      data: {
        siswa: siswaCheck[0],
        presensi: rows,
        summary: summary
      }
    });
  } catch (error) {
    console.error('Get presensi by siswa error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data presensi'
    });
  }
};

// Get presensi by kelas on specific date
exports.getPresensiByKelas = async (req, res) => {
  try {
    const { kelas_id } = req.params;
    const { tanggal } = req.query;

    // Verify kelas exists
    const [kelasCheck] = await db.query('SELECT id, nama_kelas FROM kelas WHERE id = ?', [kelas_id]);
    if (kelasCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kelas tidak ditemukan'
      });
    }

    const checkDate = tanggal || new Date().toISOString().split('T')[0];

    // Get all siswa in kelas
    const [siswaRows] = await db.query(
      `SELECT s.id, s.nis, s.nama
       FROM siswa s
       WHERE s.kelas_id = ?
       ORDER BY s.nama ASC`,
      [kelas_id]
    );

    // Get presensi for each siswa on the date
    const [presensiRows] = await db.query(
      `SELECT p.*, s.id as siswa_id
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       WHERE s.kelas_id = ? AND p.tanggal = ?`,
      [kelas_id, checkDate]
    );

    // Merge siswa with their presensi
    const result = siswaRows.map(siswa => {
      const presensi = presensiRows.find(p => p.siswa_id === siswa.id);
      return {
        ...siswa,
        presensi: presensi || null
      };
    });

    res.json({
      success: true,
      data: {
        kelas: kelasCheck[0],
        tanggal: checkDate,
        daftar_presensi: result
      }
    });
  } catch (error) {
    console.error('Get presensi by kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data presensi'
    });
  }
};

// Create presensi
exports.createPresensi = async (req, res) => {
  try {
    const { siswa_id, tanggal, status, keterangan } = req.body;

    // Validate required fields
    if (!siswa_id || !tanggal || !status) {
      return res.status(400).json({
        success: false,
        message: 'Siswa, tanggal, dan status wajib diisi'
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

    // Check if presensi already exists for this siswa on this date
    const [existing] = await db.query(
      'SELECT id FROM presensi WHERE siswa_id = ? AND tanggal = ?',
      [siswa_id, tanggal]
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Presensi untuk siswa ini pada tanggal tersebut sudah ada'
      });
    }

    // Create presensi
    const [result] = await db.query(
      'INSERT INTO presensi (siswa_id, tanggal, status, keterangan) VALUES (?, ?, ?, ?)',
      [siswa_id, tanggal, status, keterangan]
    );

    // Get created presensi
    const [created] = await db.query(
      `SELECT p.*, s.nis, s.nama as nama_siswa, k.nama_kelas
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       LEFT JOIN kelas k ON s.kelas_id = k.id
       WHERE p.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Presensi berhasil ditambahkan',
      data: created[0]
    });
  } catch (error) {
    console.error('Create presensi error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan presensi'
    });
  }
};

// Bulk create presensi (for a class)
exports.createBulkPresensi = async (req, res) => {
  try {
    const { kelas_id, tanggal, data } = req.body;

    if (!kelas_id || !tanggal || !Array.isArray(data) || data.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Kelas, tanggal, dan data presensi wajib diisi'
      });
    }

    const connection = await db.getConnection();
    await connection.beginTransaction();

    try {
      const results = [];

      for (const item of data) {
        const { siswa_id, status, keterangan } = item;

        // Check if presensi already exists
        const [existing] = await connection.query(
          'SELECT id FROM presensi WHERE siswa_id = ? AND tanggal = ?',
          [siswa_id, tanggal]
        );

        if (existing.length > 0) {
          // Update existing
          await connection.query(
            'UPDATE presensi SET status = ?, keterangan = ? WHERE id = ?',
            [status, keterangan, existing[0].id]
          );
          results.push({ siswa_id, status: 'updated' });
        } else {
          // Create new
          await connection.query(
            'INSERT INTO presensi (siswa_id, tanggal, status, keterangan) VALUES (?, ?, ?, ?)',
            [siswa_id, tanggal, status, keterangan]
          );
          results.push({ siswa_id, status: 'created' });
        }
      }

      await connection.commit();

      res.json({
        success: true,
        message: `${results.length} presensi berhasil disimpan`,
        data: results
      });
    } catch (error) {
      await connection.rollback();
      throw error;
    } finally {
      connection.release();
    }
  } catch (error) {
    console.error('Create bulk presensi error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menyimpan presensi'
    });
  }
};

// Update presensi
exports.updatePresensi = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, keterangan } = req.body;

    // Check if presensi exists
    const [existing] = await db.query('SELECT * FROM presensi WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Presensi tidak ditemukan'
      });
    }

    // Update presensi
    await db.query(
      'UPDATE presensi SET status = COALESCE(?, status), keterangan = COALESCE(?, keterangan) WHERE id = ?',
      [status, keterangan, id]
    );

    // Get updated presensi
    const [updated] = await db.query(
      `SELECT p.*, s.nis, s.nama as nama_siswa, k.nama_kelas
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       LEFT JOIN kelas k ON s.kelas_id = k.id
       WHERE p.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Presensi berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update presensi error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui presensi'
    });
  }
};

// Delete presensi
exports.deletePresensi = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if presensi exists
    const [existing] = await db.query('SELECT id FROM presensi WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Presensi tidak ditemukan'
      });
    }

    await db.query('DELETE FROM presensi WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Presensi berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete presensi error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus presensi'
    });
  }
};

// Get presensi statistics
exports.getPresensiStats = async (req, res) => {
  try {
    const { kelas_id, bulan, tahun } = req.query;

    let whereClause = '';
    const params = [];

    if (kelas_id) {
      whereClause += ' AND s.kelas_id = ?';
      params.push(kelas_id);
    }
    if (bulan) {
      whereClause += ' AND MONTH(p.tanggal) = ?';
      params.push(bulan);
    }
    if (tahun) {
      whereClause += ' AND YEAR(p.tanggal) = ?';
      params.push(tahun);
    }

    // Overall stats
    const [overall] = await db.query(
      `SELECT status, COUNT(*) as total
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       WHERE 1=1 ${whereClause}
       GROUP BY status`,
      params
    );

    // Stats per kelas
    const [perKelas] = await db.query(
      `SELECT k.nama_kelas,
              p.status,
              COUNT(*) as total
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       JOIN kelas k ON s.kelas_id = k.id
       WHERE 1=1 ${whereClause}
       GROUP BY k.id, k.nama_kelas, p.status
       ORDER BY k.nama_kelas`,
      params
    );

    // Stats per siswa (top 10 with most alpha)
    const [topAlpha] = await db.query(
      `SELECT s.nis, s.nama, k.nama_kelas,
              COUNT(*) as total_alpha
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       JOIN kelas k ON s.kelas_id = k.id
       WHERE p.status = 'alpha' ${whereClause}
       GROUP BY s.id, s.nis, s.nama, k.nama_kelas
       ORDER BY total_alpha DESC
       LIMIT 10`,
      params
    );

    res.json({
      success: true,
      data: {
        overall,
        per_kelas: perKelas,
        top_alpha: topAlpha
      }
    });
  } catch (error) {
    console.error('Get presensi stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil statistik presensi'
    });
  }
};
