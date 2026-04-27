const db = require('../config/database');

// Get all kelas with wali kelas info
exports.getAllKelas = async (req, res) => {
  try {
    const { tingkat, tahun_ajaran, search } = req.query;

    let query = `
      SELECT k.*, g.nama as nama_wali_kelas,
             COUNT(DISTINCT s.id) as total_siswa,
             COUNT(DISTINCT j.id) as total_jadwal
      FROM kelas k
      LEFT JOIN guru g ON k.wali_kelas_id = g.id
      LEFT JOIN siswa s ON k.id = s.kelas_id
      LEFT JOIN jadwal j ON k.id = j.kelas_id
      WHERE 1=1
    `;
    const params = [];

    if (tingkat) {
      query += ' AND k.tingkat = ?';
      params.push(tingkat);
    }
    if (tahun_ajaran) {
      query += ' AND k.tahun_ajaran = ?';
      params.push(tahun_ajaran);
    }
    if (search) {
      query += ' AND k.nama_kelas LIKE ?';
      params.push(`%${search}%`);
    }

    query += ' GROUP BY k.id ORDER BY k.tingkat ASC, k.nama_kelas ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data kelas'
    });
  }
};

// Get kelas by ID with complete info
exports.getKelasById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `SELECT k.*, g.nama as nama_wali_kelas
       FROM kelas k
       LEFT JOIN guru g ON k.wali_kelas_id = g.id
       WHERE k.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kelas tidak ditemukan'
      });
    }

    // Get siswa in kelas
    const [siswaRows] = await db.query(
      `SELECT s.id, s.nis, s.nama, s.jenis_kelamin, s.foto_url
       FROM siswa s
       WHERE s.kelas_id = ?
       ORDER BY s.nama ASC`,
      [id]
    );

    // Get jadwal for kelas
    const [jadwalRows] = await db.query(
      `SELECT j.*, m.nama_mapel, m.kode_mapel, g.nama as nama_guru
       FROM jadwal j
       JOIN mata_pelajaran m ON j.mapel_id = m.id
       JOIN guru g ON j.guru_id = g.id
       WHERE j.kelas_id = ?
       ORDER BY FIELD(j.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), j.jam_mulai`,
      [id]
    );

    // Get nilai summary
    const [nilaiRows] = await db.query(
      `SELECT m.nama_mapel,
              AVG(n.nilai_akhir) as rata_rata,
              COUNT(n.id) as total_nilai
       FROM nilai n
       JOIN mata_pelajaran m ON n.mapel_id = m.id
       WHERE n.kelas_id = ?
       GROUP BY m.id, m.nama_mapel`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...rows[0],
        siswa: siswaRows,
        jadwal: jadwalRows,
        statistik_nilai: nilaiRows
      }
    });
  } catch (error) {
    console.error('Get kelas by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data kelas'
    });
  }
};

// Create kelas
exports.createKelas = async (req, res) => {
  try {
    const { nama_kelas, tingkat, wali_kelas_id, tahun_ajaran } = req.body;

    // Validate required fields
    if (!nama_kelas || !tingkat || !tahun_ajaran) {
      return res.status(400).json({
        success: false,
        message: 'Nama kelas, tingkat, dan tahun ajaran wajib diisi'
      });
    }

    // Check if nama_kelas already exists for same tahun_ajaran
    const [existing] = await db.query(
      'SELECT id FROM kelas WHERE nama_kelas = ? AND tahun_ajaran = ?',
      [nama_kelas, tahun_ajaran]
    );
    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Kelas sudah ada untuk tahun ajaran ini'
      });
    }

    // Verify wali_kelas exists if provided
    if (wali_kelas_id) {
      const [guruCheck] = await db.query('SELECT id FROM guru WHERE id = ?', [wali_kelas_id]);
      if (guruCheck.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Guru tidak ditemukan'
        });
      }

      // Check if guru is already wali kelas for another class in same year
      const [waliCheck] = await db.query(
        'SELECT id FROM kelas WHERE wali_kelas_id = ? AND tahun_ajaran = ?',
        [wali_kelas_id, tahun_ajaran]
      );
      if (waliCheck.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Guru sudah menjadi wali kelas untuk kelas lain di tahun ajaran ini'
        });
      }
    }

    // Create kelas
    const [result] = await db.query(
      'INSERT INTO kelas (nama_kelas, tingkat, wali_kelas_id, tahun_ajaran) VALUES (?, ?, ?, ?)',
      [nama_kelas, tingkat, wali_kelas_id, tahun_ajaran]
    );

    // Get created kelas
    const [created] = await db.query(
      `SELECT k.*, g.nama as nama_wali_kelas
       FROM kelas k
       LEFT JOIN guru g ON k.wali_kelas_id = g.id
       WHERE k.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Kelas berhasil ditambahkan',
      data: created[0]
    });
  } catch (error) {
    console.error('Create kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan kelas'
    });
  }
};

// Update kelas
exports.updateKelas = async (req, res) => {
  try {
    const { id } = req.params;
    const { nama_kelas, tingkat, wali_kelas_id, tahun_ajaran } = req.body;

    // Check if kelas exists
    const [existing] = await db.query('SELECT * FROM kelas WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kelas tidak ditemukan'
      });
    }

    const kelas = existing[0];

    // Check if nama_kelas is taken by another kelas in same tahun_ajaran
    if (nama_kelas && tahun_ajaran &&
        (nama_kelas !== kelas.nama_kelas || tahun_ajaran !== kelas.tahun_ajaran)) {
      const [check] = await db.query(
        'SELECT id FROM kelas WHERE nama_kelas = ? AND tahun_ajaran = ? AND id != ?',
        [nama_kelas, tahun_ajaran, id]
      );
      if (check.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Kelas sudah ada untuk tahun ajaran ini'
        });
      }
    }

    // Verify wali_kelas exists if provided
    if (wali_kelas_id && wali_kelas_id !== kelas.wali_kelas_id) {
      const [guruCheck] = await db.query('SELECT id FROM guru WHERE id = ?', [wali_kelas_id]);
      if (guruCheck.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Guru tidak ditemukan'
        });
      }

      const tahun = tahun_ajaran || kelas.tahun_ajaran;
      const [waliCheck] = await db.query(
        'SELECT id FROM kelas WHERE wali_kelas_id = ? AND tahun_ajaran = ? AND id != ?',
        [wali_kelas_id, tahun, id]
      );
      if (waliCheck.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Guru sudah menjadi wali kelas untuk kelas lain di tahun ajaran ini'
        });
      }
    }

    // Update kelas
    await db.query(
      `UPDATE kelas SET
        nama_kelas = COALESCE(?, nama_kelas),
        tingkat = COALESCE(?, tingkat),
        wali_kelas_id = COALESCE(?, wali_kelas_id),
        tahun_ajaran = COALESCE(?, tahun_ajaran)
       WHERE id = ?`,
      [nama_kelas, tingkat, wali_kelas_id, tahun_ajaran, id]
    );

    // Get updated kelas
    const [updated] = await db.query(
      `SELECT k.*, g.nama as nama_wali_kelas
       FROM kelas k
       LEFT JOIN guru g ON k.wali_kelas_id = g.id
       WHERE k.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Kelas berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui kelas'
    });
  }
};

// Delete kelas
exports.deleteKelas = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if kelas exists
    const [existing] = await db.query('SELECT id FROM kelas WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kelas tidak ditemukan'
      });
    }

    // Check for related data
    const [siswaCheck] = await db.query('SELECT COUNT(*) as count FROM siswa WHERE kelas_id = ?', [id]);
    const [jadwalCheck] = await db.query('SELECT COUNT(*) as count FROM jadwal WHERE kelas_id = ?', [id]);
    const [nilaiCheck] = await db.query('SELECT COUNT(*) as count FROM nilai WHERE kelas_id = ?', [id]);

    if (siswaCheck[0].count > 0 || jadwalCheck[0].count > 0 || nilaiCheck[0].count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Kelas tidak dapat dihapus karena memiliki data siswa, jadwal, atau nilai terkait'
      });
    }

    await db.query('DELETE FROM kelas WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Kelas berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus kelas'
    });
  }
};

// Get available kelas (for dropdown)
exports.getAvailableKelas = async (req, res) => {
  try {
    const { tahun_ajaran } = req.query;

    let query = `
      SELECT k.id, k.nama_kelas, k.tingkat, g.nama as nama_wali_kelas
      FROM kelas k
      LEFT JOIN guru g ON k.wali_kelas_id = g.id
      WHERE 1=1
    `;
    const params = [];

    if (tahun_ajaran) {
      query += ' AND k.tahun_ajaran = ?';
      params.push(tahun_ajaran);
    }

    query += ' ORDER BY k.tingkat ASC, k.nama_kelas ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get available kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data kelas'
    });
  }
};

// Get kelas statistics
exports.getKelasStats = async (req, res) => {
  try {
    const { tahun_ajaran } = req.query;

    let whereClause = '';
    const params = [];

    if (tahun_ajaran) {
      whereClause = 'WHERE k.tahun_ajaran = ?';
      params.push(tahun_ajaran);
    }

    const [rows] = await db.query(
      `SELECT
        COUNT(DISTINCT k.id) as total_kelas,
        COUNT(DISTINCT s.id) as total_siswa,
        COUNT(DISTINCT k.wali_kelas_id) as total_wali_kelas,
        ROUND(AVG(sub.siswa_count), 1) as rata_siswa_per_kelas
       FROM kelas k
       LEFT JOIN siswa s ON k.id = s.kelas_id
       LEFT JOIN (SELECT kelas_id, COUNT(*) as siswa_count FROM siswa GROUP BY kelas_id) sub ON k.id = sub.kelas_id
       ${whereClause}`,
      params
    );

    // Get per tingkat breakdown
    const [tingkatRows] = await db.query(
      `SELECT k.tingkat,
              COUNT(DISTINCT k.id) as total_kelas,
              COUNT(s.id) as total_siswa
       FROM kelas k
       LEFT JOIN siswa s ON k.id = s.kelas_id
       ${whereClause}
       GROUP BY k.tingkat
       ORDER BY k.tingkat`,
      params
    );

    res.json({
      success: true,
      data: {
        overall: rows[0],
        per_tingkat: tingkatRows
      }
    });
  } catch (error) {
    console.error('Get kelas stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil statistik kelas'
    });
  }
};
