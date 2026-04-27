const db = require('../config/database');

// Get all pengumuman
exports.getAllPengumuman = async (req, res) => {
  try {
    const { kategori, status, search, active_only } = req.query;

    let query = `
      SELECT p.*, u.nama as dibuat_oleh_nama
      FROM pengumuman p
      LEFT JOIN users u ON p.dibuat_oleh = u.id
      WHERE 1=1
    `;
    const params = [];

    if (kategori) {
      query += ' AND p.kategori = ?';
      params.push(kategori);
    }
    if (status) {
      query += ' AND p.status = ?';
      params.push(status);
    }
    if (active_only === 'true') {
      query += ' AND (p.tanggal_selesai IS NULL OR p.tanggal_selesai >= CURDATE())';
      query += ' AND (p.tanggal_mulai IS NULL OR p.tanggal_mulai <= CURDATE())';
    }
    if (search) {
      query += ' AND (p.judul LIKE ? OR p.isi LIKE ?)';
      params.push(`%${search}%`, `%${search}%`);
    }

    query += ' ORDER BY p.created_at DESC';

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all pengumuman error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data pengumuman'
    });
  }
};

// Get pengumuman by ID
exports.getPengumumanById = async (req, res) => {
  try {
    const { id } = req.params;

    const [rows] = await db.query(
      `SELECT p.*, u.nama as dibuat_oleh_nama
       FROM pengumuman p
       LEFT JOIN users u ON p.dibuat_oleh = u.id
       WHERE p.id = ?`,
      [id]
    );

    if (rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengumuman tidak ditemukan'
      });
    }

    res.json({
      success: true,
      data: rows[0]
    });
  } catch (error) {
    console.error('Get pengumuman by ID error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data pengumuman'
    });
  }
};

// Get active pengumuman (for public display)
exports.getActivePengumuman = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT p.*, u.nama as dibuat_oleh_nama
       FROM pengumuman p
       LEFT JOIN users u ON p.dibuat_oleh = u.id
       WHERE p.status = 'published'
         AND (p.tanggal_mulai IS NULL OR p.tanggal_mulai <= CURDATE())
         AND (p.tanggal_selesai IS NULL OR p.tanggal_selesai >= CURDATE())
       ORDER BY
         CASE p.kategori
           WHEN 'penting' THEN 1
           WHEN 'akademik' THEN 2
           WHEN 'kegiatan' THEN 3
           ELSE 4
         END,
         p.created_at DESC`
    );

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get active pengumuman error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data pengumuman'
    });
  }
};

// Create pengumuman
exports.createPengumuman = async (req, res) => {
  try {
    const { judul, isi, kategori, tanggal_mulai, tanggal_selesai, status } = req.body;
    const userId = req.user?.id;

    // Validate required fields
    if (!judul || !isi) {
      return res.status(400).json({
        success: false,
        message: 'Judul dan isi wajib diisi'
      });
    }

    // Create pengumuman
    const [result] = await db.query(
      `INSERT INTO pengumuman (judul, isi, kategori, tanggal_mulai, tanggal_selesai, dibuat_oleh, status)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [judul, isi, kategori || 'umum', tanggal_mulai, tanggal_selesai, userId, status || 'published']
    );

    // Get created pengumuman
    const [created] = await db.query(
      `SELECT p.*, u.nama as dibuat_oleh_nama
       FROM pengumuman p
       LEFT JOIN users u ON p.dibuat_oleh = u.id
       WHERE p.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Pengumuman berhasil ditambahkan',
      data: created[0]
    });
  } catch (error) {
    console.error('Create pengumuman error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan pengumuman'
    });
  }
};

// Update pengumuman
exports.updatePengumuman = async (req, res) => {
  try {
    const { id } = req.params;
    const { judul, isi, kategori, tanggal_mulai, tanggal_selesai, status } = req.body;

    // Check if pengumuman exists
    const [existing] = await db.query('SELECT * FROM pengumuman WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengumuman tidak ditemukan'
      });
    }

    // Update pengumuman
    await db.query(
      `UPDATE pengumuman SET
        judul = COALESCE(?, judul),
        isi = COALESCE(?, isi),
        kategori = COALESCE(?, kategori),
        tanggal_mulai = COALESCE(?, tanggal_mulai),
        tanggal_selesai = COALESCE(?, tanggal_selesai),
        status = COALESCE(?, status)
       WHERE id = ?`,
      [judul, isi, kategori, tanggal_mulai, tanggal_selesai, status, id]
    );

    // Get updated pengumuman
    const [updated] = await db.query(
      `SELECT p.*, u.nama as dibuat_oleh_nama
       FROM pengumuman p
       LEFT JOIN users u ON p.dibuat_oleh = u.id
       WHERE p.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Pengumuman berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update pengumuman error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui pengumuman'
    });
  }
};

// Delete pengumuman
exports.deletePengumuman = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if pengumuman exists
    const [existing] = await db.query('SELECT id FROM pengumuman WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Pengumuman tidak ditemukan'
      });
    }

    await db.query('DELETE FROM pengumuman WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Pengumuman berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete pengumuman error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus pengumuman'
    });
  }
};

// Get pengumuman statistics
exports.getPengumumanStats = async (req, res) => {
  try {
    // Count by category
    const [kategoriStats] = await db.query(
      `SELECT kategori, COUNT(*) as total
       FROM pengumuman
       GROUP BY kategori`
    );

    // Count by status
    const [statusStats] = await db.query(
      `SELECT status, COUNT(*) as total
       FROM pengumuman
       GROUP BY status`
    );

    // Active vs expired
    const [activeStats] = await db.query(
      `SELECT
        SUM(CASE WHEN status = 'published'
                  AND (tanggal_mulai IS NULL OR tanggal_mulai <= CURDATE())
                  AND (tanggal_selesai IS NULL OR tanggal_selesai >= CURDATE())
             THEN 1 ELSE 0 END) as active,
        SUM(CASE WHEN status = 'published'
                  AND tanggal_selesai < CURDATE()
             THEN 1 ELSE 0 END) as expired,
        SUM(CASE WHEN status = 'draft' THEN 1 ELSE 0 END) as draft
       FROM pengumuman`
    );

    // Monthly trend (last 6 months)
    const [monthlyTrend] = await db.query(
      `SELECT DATE_FORMAT(created_at, '%Y-%m') as bulan,
              COUNT(*) as total
       FROM pengumuman
       WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
       GROUP BY DATE_FORMAT(created_at, '%Y-%m')
       ORDER BY bulan`
    );

    res.json({
      success: true,
      data: {
        kategori: kategoriStats,
        status: statusStats,
        active_summary: activeStats[0],
        monthly_trend: monthlyTrend
      }
    });
  } catch (error) {
    console.error('Get pengumuman stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil statistik pengumuman'
    });
  }
};
