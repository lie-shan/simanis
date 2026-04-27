const bcrypt = require('bcryptjs');
const db = require('../config/database');

// Get all siswa with kelas info
exports.getAllSiswa = async (req, res) => {
  try {
    const { kelas_id, jenis_kelamin, search } = req.query;

    let query = `
      SELECT s.*, k.nama_kelas, u.email, u.status as user_status
      FROM siswa s
      LEFT JOIN kelas k ON s.kelas_id = k.id
      LEFT JOIN users u ON s.user_id = u.id
      WHERE 1=1
    `;
    const params = [];

    if (kelas_id) {
      query += ' AND s.kelas_id = ?';
      params.push(kelas_id);
    }
    if (jenis_kelamin) {
      query += ' AND s.jenis_kelamin = ?';
      params.push(jenis_kelamin);
    }
    if (search) {
      query += ' AND (s.nama LIKE ? OR s.nis LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ' ORDER BY s.kelas_id ASC, s.nama ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all siswa error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data siswa'
    });
  }
};

// Get siswa by ID with complete info
exports.getSiswaById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `SELECT s.*, k.nama_kelas, k.tingkat, k.tahun_ajaran,
              u.email, u.no_whatsapp, u.status as user_status
       FROM siswa s
       LEFT JOIN kelas k ON s.kelas_id = k.id
       LEFT JOIN users u ON s.user_id = u.id
       WHERE s.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa tidak ditemukan'
      });
    }

    // Get nilai summary
    const [nilaiRows] = await db.query(
      `SELECT n.*, m.nama_mapel, m.kode_mapel
       FROM nilai n
       JOIN mata_pelajaran m ON n.mapel_id = m.id
       WHERE n.siswa_id = ?
       ORDER BY n.tahun_ajaran DESC, n.semester DESC`,
      [id]
    );

    // Get presensi summary
    const [presensiRows] = await db.query(
      `SELECT status, COUNT(*) as total
       FROM presensi
       WHERE siswa_id = ?
       GROUP BY status`,
      [id]
    );

    // Get pembayaran summary
    const [pembayaranRows] = await db.query(
      `SELECT status, COUNT(*) as total, SUM(jumlah) as total_jumlah
       FROM pembayaran
       WHERE siswa_id = ?
       GROUP BY status`,
      [id]
    );

    res.json({
      success: true,
      data: {
        ...rows[0],
        nilai: nilaiRows,
        presensi_summary: presensiRows,
        pembayaran_summary: pembayaranRows
      }
    });
  } catch (error) {
    console.error('Get siswa by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data siswa'
    });
  }
};

// Create siswa with user account
exports.createSiswa = async (req, res) => {
  try {
    const {
      nis, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
      alamat, kelas_id, tahun_masuk, nama_ayah, nama_ibu, no_hp_ortu,
      email, password, no_whatsapp, foto_url
    } = req.body;

    // Validate required fields
    if (!nis || !nama || !jenis_kelamin) {
      return res.status(400).json({
        success: false,
        message: 'NIS, nama, dan jenis kelamin wajib diisi'
      });
    }

    // Check if NIS already exists
    const [existingNis] = await db.query('SELECT id FROM siswa WHERE nis = ?', [nis]);
    if (existingNis.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'NIS sudah terdaftar'
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
        [nama, email, hashedPassword, no_whatsapp, 'siswa']
      );

      user_id = userResult.insertId;
    }

    // Create siswa
    const [result] = await db.query(
      `INSERT INTO siswa (user_id, nis, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
                          alamat, kelas_id, tahun_masuk, nama_ayah, nama_ibu, no_hp_ortu, foto_url)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [user_id, nis, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
       alamat, kelas_id, tahun_masuk, nama_ayah, nama_ibu, no_hp_ortu, foto_url]
    );

    // Get created siswa
    const [created] = await db.query(
      `SELECT s.*, k.nama_kelas, u.email, u.status as user_status
       FROM siswa s
       LEFT JOIN kelas k ON s.kelas_id = k.id
       LEFT JOIN users u ON s.user_id = u.id
       WHERE s.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Siswa berhasil ditambahkan' + (user_id ? ' dengan akun pengguna' : ''),
      data: created[0]
    });
  } catch (error) {
    console.error('Create siswa error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan siswa'
    });
  }
};

// Update siswa
exports.updateSiswa = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      nis, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
      alamat, kelas_id, tahun_masuk, nama_ayah, nama_ibu, no_hp_ortu,
      no_whatsapp, foto_url, status
    } = req.body;

    // Check if siswa exists
    const [existing] = await db.query('SELECT * FROM siswa WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa tidak ditemukan'
      });
    }

    const siswa = existing[0];

    // Check if NIS is taken by another siswa
    if (nis && nis !== siswa.nis) {
      const [nisCheck] = await db.query('SELECT id FROM siswa WHERE nis = ? AND id != ?', [nis, id]);
      if (nisCheck.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'NIS sudah digunakan oleh siswa lain'
        });
      }
    }

    // Update siswa
    await db.query(
      `UPDATE siswa SET
        nis = COALESCE(?, nis),
        nama = COALESCE(?, nama),
        jenis_kelamin = COALESCE(?, jenis_kelamin),
        tempat_lahir = COALESCE(?, tempat_lahir),
        tanggal_lahir = COALESCE(?, tanggal_lahir),
        alamat = COALESCE(?, alamat),
        kelas_id = COALESCE(?, kelas_id),
        tahun_masuk = COALESCE(?, tahun_masuk),
        nama_ayah = COALESCE(?, nama_ayah),
        nama_ibu = COALESCE(?, nama_ibu),
        no_hp_ortu = COALESCE(?, no_hp_ortu),
        foto_url = COALESCE(?, foto_url)
       WHERE id = ?`,
      [nis, nama, jenis_kelamin, tempat_lahir, tanggal_lahir,
       alamat, kelas_id, tahun_masuk, nama_ayah, nama_ibu, no_hp_ortu, foto_url, id]
    );

    // Update user if exists
    if (siswa.user_id) {
      await db.query(
        `UPDATE users SET
          nama = COALESCE(?, nama),
          no_whatsapp = COALESCE(?, no_whatsapp),
          status = COALESCE(?, status)
         WHERE id = ?`,
        [nama, no_whatsapp, status, siswa.user_id]
      );
    }

    // Get updated siswa
    const [updated] = await db.query(
      `SELECT s.*, k.nama_kelas, u.email, u.status as user_status
       FROM siswa s
       LEFT JOIN kelas k ON s.kelas_id = k.id
       LEFT JOIN users u ON s.user_id = u.id
       WHERE s.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Siswa berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update siswa error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui siswa'
    });
  }
};

// Delete siswa
exports.deleteSiswa = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if siswa exists
    const [existing] = await db.query('SELECT * FROM siswa WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Siswa tidak ditemukan'
      });
    }

    const siswa = existing[0];

    // Check for related data
    const [nilaiCheck] = await db.query('SELECT COUNT(*) as count FROM nilai WHERE siswa_id = ?', [id]);
    const [presensiCheck] = await db.query('SELECT COUNT(*) as count FROM presensi WHERE siswa_id = ?', [id]);
    const [pembayaranCheck] = await db.query('SELECT COUNT(*) as count FROM pembayaran WHERE siswa_id = ?', [id]);

    if (nilaiCheck[0].count > 0 || presensiCheck[0].count > 0 || pembayaranCheck[0].count > 0) {
      return res.status(400).json({
        success: false,
        message: 'Siswa tidak dapat dihapus karena memiliki data nilai, presensi, atau pembayaran terkait'
      });
    }

    // Delete siswa (user will be handled by ON DELETE SET NULL)
    await db.query('DELETE FROM siswa WHERE id = ?', [id]);

    // Delete associated user if exists
    if (siswa.user_id) {
      await db.query('DELETE FROM users WHERE id = ?', [siswa.user_id]);
    }

    res.json({
      success: true,
      message: 'Siswa berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete siswa error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus siswa'
    });
  }
};

// Get siswa count by kelas
exports.getSiswaCountByKelas = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT k.id, k.nama_kelas, COUNT(s.id) as total_siswa
       FROM kelas k
       LEFT JOIN siswa s ON k.id = s.kelas_id
       GROUP BY k.id, k.nama_kelas
       ORDER BY k.nama_kelas`
    );

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get siswa count error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data'
    });
  }
};
