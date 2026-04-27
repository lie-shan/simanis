const db = require('../config/database');

// Get all nilai
exports.getAllNilai = async (req, res) => {
  try {
    const { mapel_id, kelas_id, semester, tahun_ajaran } = req.query;
    
    let query = `
      SELECT n.*,
             s.nama as nama_siswa, s.nis,
             m.nama_mapel,
             k.nama_kelas,
             g.nama as nama_guru
      FROM nilai n
      JOIN siswa s ON n.siswa_id = s.id
      JOIN mata_pelajaran m ON n.mapel_id = m.id
      JOIN kelas k ON n.kelas_id = k.id
      LEFT JOIN guru g ON n.guru_id = g.id
      WHERE 1=1
    `;
    const params = [];

    if (mapel_id) {
      query += ' AND n.mapel_id = ?';
      params.push(mapel_id);
    }
    if (kelas_id) {
      query += ' AND n.kelas_id = ?';
      params.push(kelas_id);
    }
    if (semester) {
      query += ' AND n.semester = ?';
      params.push(semester);
    }
    if (tahun_ajaran) {
      query += ' AND n.tahun_ajaran = ?';
      params.push(tahun_ajaran);
    }

    query += ' ORDER BY s.nama ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all nilai error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data nilai'
    });
  }
};

// Get nilai by siswa
exports.getNilaiBySiswa = async (req, res) => {
  try {
    const { siswa_id } = req.params;
    const { semester, tahun_ajaran } = req.query;

    let query = `
      SELECT n.*,
             m.nama_mapel, m.kode_mapel,
             k.nama_kelas,
             g.nama as nama_guru
      FROM nilai n
      JOIN mata_pelajaran m ON n.mapel_id = m.id
      JOIN kelas k ON n.kelas_id = k.id
      LEFT JOIN guru g ON n.guru_id = g.id
      WHERE n.siswa_id = ?
    `;
    const params = [siswa_id];

    if (semester) {
      query += ' AND n.semester = ?';
      params.push(semester);
    }
    if (tahun_ajaran) {
      query += ' AND n.tahun_ajaran = ?';
      params.push(tahun_ajaran);
    }

    query += ' ORDER BY m.nama_mapel ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get nilai by siswa error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data nilai'
    });
  }
};

// Get nilai by mapel
exports.getNilaiByMapel = async (req, res) => {
  try {
    const { mapel_id } = req.params;
    const { kelas_id, semester, tahun_ajaran } = req.query;

    let query = `
      SELECT n.*,
             s.nama as nama_siswa, s.nis,
             k.nama_kelas,
             g.nama as nama_guru
      FROM nilai n
      JOIN siswa s ON n.siswa_id = s.id
      JOIN kelas k ON n.kelas_id = k.id
      LEFT JOIN guru g ON n.guru_id = g.id
      WHERE n.mapel_id = ?
    `;
    const params = [mapel_id];

    if (kelas_id) {
      query += ' AND n.kelas_id = ?';
      params.push(kelas_id);
    }
    if (semester) {
      query += ' AND n.semester = ?';
      params.push(semester);
    }
    if (tahun_ajaran) {
      query += ' AND n.tahun_ajaran = ?';
      params.push(tahun_ajaran);
    }

    query += ' ORDER BY s.nama ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get nilai by mapel error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data nilai'
    });
  }
};

// Get nilai by kelas
exports.getNilaiByKelas = async (req, res) => {
  try {
    const { kelas_id } = req.params;
    const { mapel_id, semester, tahun_ajaran } = req.query;

    let query = `
      SELECT n.*,
             s.nama as nama_siswa, s.nis,
             m.nama_mapel,
             g.nama as nama_guru
      FROM nilai n
      JOIN siswa s ON n.siswa_id = s.id
      JOIN mata_pelajaran m ON n.mapel_id = m.id
      LEFT JOIN guru g ON n.guru_id = g.id
      WHERE n.kelas_id = ?
    `;
    const params = [kelas_id];

    if (mapel_id) {
      query += ' AND n.mapel_id = ?';
      params.push(mapel_id);
    }
    if (semester) {
      query += ' AND n.semester = ?';
      params.push(semester);
    }
    if (tahun_ajaran) {
      query += ' AND n.tahun_ajaran = ?';
      params.push(tahun_ajaran);
    }

    query += ' ORDER BY s.nama ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get nilai by kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data nilai'
    });
  }
};

// Get nilai by ID
exports.getNilaiById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `SELECT n.*,
              s.nama as nama_siswa, s.nis,
              m.nama_mapel, m.kode_mapel,
              k.nama_kelas,
              g.nama as nama_guru
       FROM nilai n
       LEFT JOIN guru g ON n.guru_id = g.id
       JOIN siswa s ON n.siswa_id = s.id
       JOIN mata_pelajaran m ON n.mapel_id = m.id
       JOIN kelas k ON n.kelas_id = k.id
       WHERE n.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Nilai tidak ditemukan'
      });
    }

    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error('Get nilai by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data nilai'
    });
  }
};

// Create nilai
exports.createNilai = async (req, res) => {
  try {
    const {
      siswa_id,
      mapel_id,
      kelas_id,
      guru_id,
      semester,
      tahun_ajaran,
      nilai_harian,
      nilai_uts,
      nilai_uas
    } = req.body;

    // Validate required fields
    if (!siswa_id || !mapel_id || !kelas_id || !semester || !tahun_ajaran) {
      return res.status(400).json({
        success: false,
        message: 'Data tidak lengkap'
      });
    }

    // Check if nilai already exists
    const [existing] = await db.query(
      'SELECT id FROM nilai WHERE siswa_id = ? AND mapel_id = ? AND semester = ? AND tahun_ajaran = ?',
      [siswa_id, mapel_id, semester, tahun_ajaran]
    );

    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Nilai untuk siswa, mapel, dan semester ini sudah ada'
      });
    }

    const [result] = await db.query(
      `INSERT INTO nilai (siswa_id, mapel_id, kelas_id, guru_id, semester, tahun_ajaran, nilai_harian, nilai_uts, nilai_uas)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [siswa_id, mapel_id, kelas_id, guru_id, semester, tahun_ajaran, nilai_harian || 0, nilai_uts || 0, nilai_uas || 0]
    );

    // Get created nilai
    const [created] = await db.query(
      `SELECT n.*,
              s.nama as nama_siswa, s.nis,
              m.nama_mapel,
              k.nama_kelas,
              g.nama as nama_guru
       FROM nilai n
       JOIN siswa s ON n.siswa_id = s.id
       JOIN mata_pelajaran m ON n.mapel_id = m.id
       JOIN kelas k ON n.kelas_id = k.id
       LEFT JOIN guru g ON n.guru_id = g.id
       WHERE n.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Nilai berhasil ditambahkan',
      data: created[0]
    });
  } catch (error) {
    console.error('Create nilai error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan nilai'
    });
  }
};

// Update nilai
exports.updateNilai = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      nilai_harian,
      nilai_uts,
      nilai_uas
    } = req.body;

    // Check if nilai exists
    const [existing] = await db.query('SELECT id FROM nilai WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Nilai tidak ditemukan'
      });
    }

    await db.query(
      `UPDATE nilai 
       SET nilai_harian = ?, nilai_uts = ?, nilai_uas = ?
       WHERE id = ?`,
      [nilai_harian, nilai_uts, nilai_uas, id]
    );

    // Get updated nilai
    const [updated] = await db.query(
      `SELECT n.*,
              s.nama as nama_siswa, s.nis,
              m.nama_mapel,
              k.nama_kelas,
              g.nama as nama_guru
       FROM nilai n
       JOIN siswa s ON n.siswa_id = s.id
       JOIN mata_pelajaran m ON n.mapel_id = m.id
       JOIN kelas k ON n.kelas_id = k.id
       LEFT JOIN guru g ON n.guru_id = g.id
       WHERE n.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Nilai berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update nilai error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui nilai'
    });
  }
};

// Delete nilai
exports.deleteNilai = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if nilai exists
    const [existing] = await db.query('SELECT id FROM nilai WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Nilai tidak ditemukan'
      });
    }

    await db.query('DELETE FROM nilai WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Nilai berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete nilai error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus nilai'
    });
  }
};
