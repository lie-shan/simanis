const db = require('../config/database');

// Get all mata pelajaran
exports.getAllMapel = async (req, res) => {
  try {
    const { search } = req.query;

    let query = `
      SELECT m.*,
             COUNT(DISTINCT j.id) as total_jadwal,
             COUNT(DISTINCT n.id) as total_nilai,
             COUNT(DISTINCT g.id) as total_guru
      FROM mata_pelajaran m
      LEFT JOIN jadwal j ON m.id = j.mapel_id
      LEFT JOIN nilai n ON m.id = n.mapel_id
      LEFT JOIN guru g ON m.id = g.id
      WHERE 1=1
    `;
    const params = [];

    if (search) {
      query += ' AND (m.nama_mapel LIKE ? OR m.kode_mapel LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ' GROUP BY m.id ORDER BY m.kode_mapel ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all mapel error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data mata pelajaran'
    });
  }
};

// Get mata pelajaran by ID
exports.getMapelById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `SELECT m.*
       FROM mata_pelajaran m
       WHERE m.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Mata pelajaran tidak ditemukan'
      });
    }

    // Get jadwal for this mapel
    const [jadwalRows] = await db.query(
      `SELECT j.*, k.nama_kelas, g.nama as nama_guru
       FROM jadwal j
       JOIN kelas k ON j.kelas_id = k.id
       JOIN guru g ON j.guru_id = g.id
       WHERE j.mapel_id = ?
       ORDER BY FIELD(j.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), j.jam_mulai`,
      [id]
    );

    // Get nilai summary
    const [nilaiRows] = await db.query(
      `SELECT k.nama_kelas,
              COUNT(n.id) as total_nilai,
              AVG(n.nilai_akhir) as rata_rata
       FROM nilai n
       JOIN kelas k ON n.kelas_id = k.id
       WHERE n.mapel_id = ?
       GROUP BY k.id, k.nama_kelas`,
      [id]
    );

    // Get guru yang mengajar
    const [guruRows] = await db.query(
      `SELECT DISTINCT g.id, g.nama, g.nip
       FROM guru g
       JOIN jadwal j ON g.id = j.guru_id
       WHERE j.mapel_id = ?`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...rows[0],
        jadwal: jadwalRows,
        statistik_nilai: nilaiRows,
        guru_mengajar: guruRows
      }
    });
  } catch (error) {
    console.error('Get mapel by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data mata pelajaran'
    });
  }
};

// Create mata pelajaran
exports.createMapel = async (req, res) => {
  try {
    const { kode_mapel, nama_mapel, deskripsi } = req.body;

    // Validate required fields
    if (!kode_mapel || !nama_mapel) {
      return res.status(400).json({
        success: false,
        message: 'Kode mapel dan nama mapel wajib diisi'
      });
    }

    // Check if kode_mapel already exists
    const [existing] = await db.query('SELECT id FROM mata_pelajaran WHERE kode_mapel = ?', [kode_mapel]);
    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Kode mapel sudah terdaftar'
      });
    }

    // Create mapel
    const [result] = await db.query(
      'INSERT INTO mata_pelajaran (kode_mapel, nama_mapel, deskripsi) VALUES (?, ?, ?)',
      [kode_mapel, nama_mapel, deskripsi]
    );

    // Get created mapel
    const [created] = await db.query(
      'SELECT * FROM mata_pelajaran WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Mata pelajaran berhasil ditambahkan',
      data: created[0]
    });
  } catch (error) {
    console.error('Create mapel error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan mata pelajaran'
    });
  }
};

// Update mata pelajaran
exports.updateMapel = async (req, res) => {
  try {
    const { id } = req.params;
    const { kode_mapel, nama_mapel, deskripsi } = req.body;

    // Check if mapel exists
    const [existing] = await db.query('SELECT * FROM mata_pelajaran WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Mata pelajaran tidak ditemukan'
      });
    }

    const mapel = existing[0];

    // Check if kode_mapel is taken by another mapel
    if (kode_mapel && kode_mapel !== mapel.kode_mapel) {
      const [check] = await db.query('SELECT id FROM mata_pelajaran WHERE kode_mapel = ? AND id != ?', [kode_mapel, id]);
      if (check.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Kode mapel sudah digunakan oleh mata pelajaran lain'
        });
      }
    }

    // Update mapel
    await db.query(
      `UPDATE mata_pelajaran SET
        kode_mapel = COALESCE(?, kode_mapel),
        nama_mapel = COALESCE(?, nama_mapel),
        deskripsi = COALESCE(?, deskripsi)
       WHERE id = ?`,
      [kode_mapel, nama_mapel, deskripsi, id]
    );

    // Get updated mapel
    const [updated] = await db.query(
      'SELECT * FROM mata_pelajaran WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Mata pelajaran berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update mapel error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui mata pelajaran'
    });
  }
};

// Delete mata pelajaran
exports.deleteMapel = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if mapel exists
    const [existing] = await db.query('SELECT id FROM mata_pelajaran WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Mata pelajaran tidak ditemukan'
      });
    }

    // Check for related data
    const [jadwalCheck] = await db.query('SELECT COUNT(*) as count FROM jadwal WHERE mapel_id = ?', [id]);
    const [nilaiCheck] = await db.query('SELECT COUNT(*) as count FROM nilai WHERE mapel_id = ?', [id]);

    if (jadwalCheck[0].count > 0 || nilaiCheck[0].count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Mata pelajaran tidak dapat dihapus karena masih digunakan di jadwal atau nilai'
      });
    }

    await db.query('DELETE FROM mata_pelajaran WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Mata pelajaran berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete mapel error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus mata pelajaran'
    });
  }
};

// Get available mapel (for dropdown)
exports.getAvailableMapel = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, kode_mapel, nama_mapel
       FROM mata_pelajaran
       ORDER BY kode_mapel ASC`
    );

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get available mapel error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data mata pelajaran'
    });
  }
};
