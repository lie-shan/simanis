const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

// Login
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email dan password wajib diisi'
      });
    }

    // Find user
    const [users] = await db.query(
      'SELECT * FROM users WHERE email = ? AND status = ?',
      [email, 'aktif']
    );

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah'
      });
    }

    const user = users[0];

    // DEBUG: Log password comparison
    console.log('DEBUG Login:');
    console.log('  Email:', email);
    console.log('  Input password:', password);
    console.log('  DB password hash:', user.password.substring(0, 30) + '...');

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    console.log('  Password valid:', isPasswordValid);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Email atau password salah'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { 
        id: user.id, 
        email: user.email, 
        role: user.role 
      },
      process.env.JWT_SECRET || 'your_jwt_secret',
      { expiresIn: '24h' }
    );

    // Remove password from response
    delete user.password;

    res.json({
      success: true,
      message: 'Login berhasil',
      data: {
        user,
        token
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat login'
    });
  }
};

// Logout
exports.logout = async (req, res) => {
  res.json({
    success: true,
    message: 'Logout berhasil'
  });
};

// Forgot password
exports.forgotPassword = async (req, res) => {
  try {
    const { no_whatsapp } = req.body;

    if (!no_whatsapp) {
      return res.status(400).json({
        success: false,
        message: 'Nomor WhatsApp wajib diisi'
      });
    }

    // Find user by WhatsApp number
    const [users] = await db.query(
      'SELECT * FROM users WHERE no_whatsapp = ? AND status = ?',
      [no_whatsapp, 'aktif']
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Nomor WhatsApp tidak terdaftar'
      });
    }

    const user = users[0];

    // Generate new temporary password
    const tempPassword = Math.random().toString(36).slice(-8);
    const hashedPassword = await bcrypt.hash(tempPassword, 10);

    // Update password in database
    await db.query(
      'UPDATE users SET password = ? WHERE id = ?',
      [hashedPassword, user.id]
    );

    // TODO: Send password via WhatsApp API
    // For now, just return success
    console.log(`Temporary password for ${user.email}: ${tempPassword}`);

    res.json({
      success: true,
      message: 'Password baru telah dikirim ke WhatsApp Anda',
      // In development, return temp password
      ...(process.env.NODE_ENV === 'development' && { temp_password: tempPassword })
    });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat reset password'
    });
  }
};

// Reset password
exports.resetPassword = async (req, res) => {
  try {
    const { email, old_password, new_password } = req.body;

    if (!email || !old_password || !new_password) {
      return res.status(400).json({
        success: false,
        message: 'Semua field wajib diisi'
      });
    }

    // Find user
    const [users] = await db.query(
      'SELECT * FROM users WHERE email = ?',
      [email]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan'
      });
    }

    const user = users[0];

    // Verify old password
    const isPasswordValid = await bcrypt.compare(old_password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Password lama salah'
      });
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(new_password, 10);

    // Update password
    await db.query(
      'UPDATE users SET password = ? WHERE id = ?',
      [hashedPassword, user.id]
    );

    res.json({
      success: true,
      message: 'Password berhasil diubah'
    });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengubah password'
    });
  }
};

// Verify token
exports.verifyToken = async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Token tidak ditemukan'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');

    // Get user data
    const [users] = await db.query(
      'SELECT id, nama, email, role, status FROM users WHERE id = ?',
      [decoded.id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User tidak ditemukan'
      });
    }

    res.json({
      success: true,
      data: users[0]
    });
  } catch (error) {
    res.status(401).json({
      success: false,
      message: 'Token tidak valid'
    });
  }
};
