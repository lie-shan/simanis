const bcrypt = require('bcryptjs');
const db = require('../config/database');

// Get all users
exports.getAllUsers = async (req, res) => {
  try {
    const { role, status } = req.query;
    
    let query = 'SELECT id, nama, email, no_whatsapp, role, status, created_at FROM users WHERE 1=1';
    const params = [];

    if (role) {
      query += ' AND role = ?';
      params.push(role);
    }
    if (status) {
      query += ' AND status = ?';
      params.push(status);
    }

    query += ' ORDER BY nama ASC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all users error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data pengguna'
    });
  }
};

// Get user by ID
exports.getUserById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      'SELECT id, nama, email, no_whatsapp, role, status, created_at FROM users WHERE id = ?',
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengguna tidak ditemukan'
      });
    }

    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error('Get user by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data pengguna'
    });
  }
};

// Create user
exports.createUser = async (req, res) => {
  try {
    const { nama, email, password, no_whatsapp, role } = req.body;

    // Validate required fields
    if (!nama || !email || !password || !role) {
      return res.status(400).json({
        success: false,
        message: 'Data tidak lengkap'
      });
    }

    // Check if email already exists
    const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Email sudah terdaftar'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.query(
      'INSERT INTO users (nama, email, password, no_whatsapp, role) VALUES (?, ?, ?, ?, ?)',
      [nama, email, hashedPassword, no_whatsapp, role]
    );

    // Get created user
    const [created] = await db.query(
      'SELECT id, nama, email, no_whatsapp, role, status, created_at FROM users WHERE id = ?',
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Pengguna berhasil ditambahkan',
      data: created[0]
    });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan pengguna'
    });
  }
};

// Update user
exports.updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { nama, email, no_whatsapp, role, status } = req.body;

    // Check if user exists
    const [existing] = await db.query('SELECT id FROM users WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengguna tidak ditemukan'
      });
    }

    // Check if email is taken by another user
    if (email) {
      const [emailCheck] = await db.query(
        'SELECT id FROM users WHERE email = ? AND id != ?',
        [email, id]
      );
      if (emailCheck.length > 0) {
        return res.status(400).json({
          success: false,
          message: 'Email sudah digunakan oleh pengguna lain'
        });
      }
    }

    await db.query(
      'UPDATE users SET nama = ?, email = ?, no_whatsapp = ?, role = ?, status = ? WHERE id = ?',
      [nama, email, no_whatsapp, role, status, id]
    );

    // Get updated user
    const [updated] = await db.query(
      'SELECT id, nama, email, no_whatsapp, role, status, created_at FROM users WHERE id = ?',
      [id]
    );

    res.json({
      success: true,
      message: 'Pengguna berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui pengguna'
    });
  }
};

// Delete user
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if user exists
    const [existing] = await db.query('SELECT id FROM users WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengguna tidak ditemukan'
      });
    }

    await db.query('DELETE FROM users WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Pengguna berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus pengguna'
    });
  }
};

// Change password
exports.changePassword = async (req, res) => {
  try {
    const { id } = req.params;
    const { old_password, new_password } = req.body;

    if (!old_password || !new_password) {
      return res.status(400).json({
        success: false,
        message: 'Password lama dan baru wajib diisi'
      });
    }

    // Get user
    const [users] = await db.query('SELECT password FROM users WHERE id = ?', [id]);
    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengguna tidak ditemukan'
      });
    }

    // Verify old password
    const isPasswordValid = await bcrypt.compare(old_password, users[0].password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Password lama salah'
      });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(new_password, 10);

    // Update password
    await db.query('UPDATE users SET password = ? WHERE id = ?', [hashedPassword, id]);

    res.json({
      success: true,
      message: 'Password berhasil diubah'
    });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengubah password'
    });
  }
};
