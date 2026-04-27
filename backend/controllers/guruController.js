const bcrypt = require('bcryptjs');
const db = require('../config/database');

// Get all guru with mapel info
exports.getAllGuru = async (req, res) => {
  try {
    const { search, mata_pelajaran } = req.query;

    let query = `
      SELECT g.*, u.email, u.no_whatsapp, u.status as user_status,
             GROUP_CONCAT(DISTINCT m.nama_mapel SEPARATOR ', ') as mengajar_mapel
      FROM guru g
      LEFT JOIN users u ON g.user_id = u.id
      LEFT JOIN jadwal j ON g.id = j.guru_id
      LEFT JOIN mata_pelajaran m ON j.mapel_id = m.id
      WHERE 1=1
    `;
    const params = [];

    if (search) {
      query += ' AND (g.nama LIKE ?)';
      params.push(`%${search}%`);
    }

    query += ' GROUP BY g.id ORDER BY g.nama ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all guru error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data guru'
    });
  }
};

// Get guru by ID with complete info
exports.getGuruById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `SELECT g.*, u.email, u.no_whatsapp, u.status as user_status
       FROM guru g
       LEFT JOIN users u ON g.user_id = u.id
       WHERE g.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Guru tidak ditemukan'
      });
    }

    // Get jadwal mengajar
    const [jadwalRows] = await db.query(
      `SELECT j.*, k.nama_kelas, m.nama_mapel, m.kode_mapel
       FROM jadwal j
       JOIN kelas k ON j.kelas_id = k.id
       JOIN mata_pelajaran m ON j.mapel_id = m.id
       WHERE j.guru_id = ?
       ORDER BY FIELD(j.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), j.jam_mulai`,
      [id]
    );

    // Get kelas yang diwalikan
    const [waliKelasRows] = await db.query(
      `SELECT k.* FROM kelas k WHERE k.wali_kelas_id = ?`,
      [id]
    );

    // Get nilai yang diinput
    const [nilaiRows] = await db.query(
      `SELECT COUNT(*) as total_nilai,
              AVG(nilai_akhir) as rata_rata_nilai
       FROM nilai
       WHERE guru_id = ?`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...rows[0],
        jadwal_mengajar: jadwalRows,
        wali_kelas: waliKelasRows,
        statistik_nilai: nilaiRows[0]
      }
    });
  } catch (error) {
    console.error('Get guru by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data guru'
    });
  }
};

// Create guru with user account
exports.createGuru = async (req, res) => {
  try {
    const {
      nama, jenis_kelamin,
      alamat, no_hp,
      email, password, no_whatsapp, foto_url
    } = req.body;

    // Validate required fields
    if (!nama || !jenis_kelamin) {
      return res.status(400).json({
        success: false,
        message: 'Nama dan jenis kelamin wajib diisi'
      });
    }

    let user_id = null;

    // Create user account if email provided
    if (email && password) {
      // Check if email already exists
      const [existingEmail] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
      if (existingEmail.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Email sudah terdaftar'
        });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Create user
      const [userResult] = await db.query(
        'INSERT INTO users (nama, email, password, no_whatsapp, role) VALUES (?, ?, ?, ?, ?)',
        [nama, email, hashedPassword, no_whatsapp || no_hp, 'guru']
      );

      user_id = userResult.insertId;
    }

    // Create guru
    const [result] = await db.query(
      `INSERT INTO guru (user_id, nama, jenis_kelamin, alamat, no_hp, foto_url)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [user_id, nama, jenis_kelamin, alamat, no_hp, foto_url]
    );

    // Get created guru
    const [created] = await db.query(
      `SELECT g.*, u.email, u.status as user_status
       FROM guru g
       LEFT JOIN users u ON g.user_id = u.id
       WHERE g.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Guru berhasil ditambahkan' + (user_id ? ' dengan akun pengguna' : ''),
      data: created[0]
    });
  } catch (error) {
    console.error('Create guru error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan guru'
    });
  }
};

// Update guru
exports.updateGuru = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      nama, jenis_kelamin,
      alamat, no_hp, no_whatsapp, foto_url, status
    } = req.body;

    // Check if guru exists
    const [existing] = await db.query('SELECT * FROM guru WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Guru tidak ditemukan'
      });
    }

    const guru = existing[0];

    // Update guru
    await db.query(
      `UPDATE guru SET
        nama = COALESCE(?, nama),
        jenis_kelamin = COALESCE(?, jenis_kelamin),
        alamat = COALESCE(?, alamat),
        no_hp = COALESCE(?, no_hp),
        foto_url = COALESCE(?, foto_url)
       WHERE id = ?`,
      [nama, jenis_kelamin, alamat, no_hp, foto_url, id]
    );

    // Update user if exists
    if (guru.user_id) {
      await db.query(
        `UPDATE users SET
          nama = COALESCE(?, nama),
          no_whatsapp = COALESCE(?, no_whatsapp),
          status = COALESCE(?, status)
         WHERE id = ?`,
        [nama, no_whatsapp || no_hp, status, guru.user_id]
      );
    }

    // Get updated guru
    const [updated] = await db.query(
      `SELECT g.*, u.email, u.status as user_status
       FROM guru g
       LEFT JOIN users u ON g.user_id = u.id
       WHERE g.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Guru berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update guru error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui guru'
    });
  }
};

// Delete guru
exports.deleteGuru = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if guru exists
    const [existing] = await db.query('SELECT * FROM guru WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Guru tidak ditemukan'
      });
    }

    const guru = existing[0];

    // Check for related data
    const [jadwalCheck] = await db.query('SELECT COUNT(*) as count FROM jadwal WHERE guru_id = ?', [id]);
    const [kelasCheck] = await db.query('SELECT COUNT(*) as count FROM kelas WHERE wali_kelas_id = ?', [id]);
    const [nilaiCheck] = await db.query('SELECT COUNT(*) as count FROM nilai WHERE guru_id = ?', [id]);

    if (jadwalCheck[0].count > 0 || kelasCheck[0].count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Guru tidak dapat dihapus karena masih terdaftar di jadwal atau sebagai wali kelas'
      });
    }

    // Delete guru (user will be handled by ON DELETE SET NULL)
    await db.query('DELETE FROM guru WHERE id = ?', [id]);

    // Delete associated user if exists
    if (guru.user_id) {
      await db.query('DELETE FROM users WHERE id = ?', [guru.user_id]);
    }

    res.json({
      success: true,
      message: 'Guru berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete guru error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus guru'
    });
  }
};

// Get available guru (for dropdown)
exports.getAvailableGuru = async (req, res) => {
  try {
    const { exclude_kelas_id } = req.query;

    let query = `
      SELECT g.id, g.nama, g.nip
      FROM guru g
      LEFT JOIN users u ON g.user_id = u.id
      WHERE (u.status = 'aktif' OR u.status IS NULL)
    `;
    const params = [];

    // If exclude_kelas_id provided, exclude guru who is wali kelas for other classes
    // but include if they are wali kelas for this specific kelas
    if (exclude_kelas_id) {
      query += ` AND (
        g.id NOT IN (SELECT wali_kelas_id FROM kelas WHERE wali_kelas_id IS NOT NULL AND id != ?)
        OR g.id IN (SELECT wali_kelas_id FROM kelas WHERE id = ?)
      )`;
      params.push(exclude_kelas_id, exclude_kelas_id);
    }

    query += ' ORDER BY g.nama ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get available guru error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data guru'
    });
  }
};
