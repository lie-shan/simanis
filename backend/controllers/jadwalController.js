const db = require('../config/database');

// Get all jadwal
exports.getAllJadwal = async (req, res) => {
  try {
    const { kelas_id, guru_id, mapel_id, hari } = req.query;

    let query = `
      SELECT j.*, k.nama_kelas, m.nama_mapel, m.kode_mapel, g.nama as nama_guru
      FROM jadwal j
      JOIN kelas k ON j.kelas_id = k.id
      JOIN mata_pelajaran m ON j.mapel_id = m.id
      JOIN guru g ON j.guru_id = g.id
      WHERE 1=1
    `;
    const params = [];

    if (kelas_id) {
      query += ' AND j.kelas_id = ?';
      params.push(kelas_id);
    }
    if (guru_id) {
      query += ' AND j.guru_id = ?';
      params.push(guru_id);
    }
    if (mapel_id) {
      query += ' AND j.mapel_id = ?';
      params.push(mapel_id);
    }
    if (hari) {
      query += ' AND j.hari = ?';
      params.push(hari);
    }

    query += ` ORDER BY
      FIELD(j.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'),
      j.jam_mulai ASC`;

    const [rows] = await db.query(query, params);

    res.json({
      success: true,
      data: rows
    });
  } catch (error) {
    console.error('Get all jadwal error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data jadwal'
    });
  }
};

// Get jadwal by kelas
exports.getJadwalByKelas = async (req, res) => {
  try {
    const { kelas_id } = req.params;

    // Verify kelas exists
    const [kelasCheck] = await db.query('SELECT id, nama_kelas FROM kelas WHERE id = ?', [kelas_id]);
    if (kelasCheck.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kelas tidak ditemukan'
      });
    }

    const [rows] = await db.query(
      `SELECT j.*, m.nama_mapel, m.kode_mapel, g.nama as nama_guru
       FROM jadwal j
       JOIN mata_pelajaran m ON j.mapel_id = m.id
       JOIN guru g ON j.guru_id = g.id
       WHERE j.kelas_id = ?
       ORDER BY FIELD(j.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), j.jam_mulai`,
      [kelas_id]
    );

    // Group by hari
    const grouped = {};
    const hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    hariList.forEach(h => grouped[h] = []);

    rows.forEach(jadwal => {
      if (!grouped[jadwal.hari]) grouped[jadwal.hari] = [];
      grouped[jadwal.hari].push(jadwal);
    });

    res.json({
      success: true,
      data: {
        kelas: kelasCheck[0],
        jadwal: grouped
      }
    });
  } catch (error) {
    console.error('Get jadwal by kelas error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data jadwal'
    });
  }
};

// Create jadwal
exports.createJadwal = async (req, res) => {
  try {
    const { kelas_id, mapel_id, guru_id, hari, jam_mulai, jam_selesai, ruangan } = req.body;

    // Validate required fields
    if (!kelas_id || !mapel_id || !guru_id || !hari || !jam_mulai || !jam_selesai) {
      return res.status(400).json({
        success: false,
        message: 'Semua field wajib diisi kecuali ruangan'
      });
    }

    // Verify kelas exists
    const [kelasCheck] = await db.query('SELECT id FROM kelas WHERE id = ?', [kelas_id]);
    if (kelasCheck.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Kelas tidak ditemukan'
      });
    }

    // Verify mapel exists
    const [mapelCheck] = await db.query('SELECT id FROM mata_pelajaran WHERE id = ?', [mapel_id]);
    if (mapelCheck.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Mata pelajaran tidak ditemukan'
      });
    }

    // Verify guru exists
    const [guruCheck] = await db.query('SELECT id FROM guru WHERE id = ?', [guru_id]);
    if (guruCheck.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Guru tidak ditemukan'
      });
    }

    // Check for schedule conflicts in same kelas
    const [conflictKelas] = await db.query(
      `SELECT id FROM jadwal
       WHERE kelas_id = ? AND hari = ?
       AND ((jam_mulai <= ? AND jam_selesai > ?)
            OR (jam_mulai < ? AND jam_selesai >= ?)
            OR (jam_mulai >= ? AND jam_selesai <= ?))`,
      [kelas_id, hari, jam_mulai, jam_mulai, jam_selesai, jam_selesai, jam_mulai, jam_selesai]
    );

    if (conflictKelas.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Jadwal bentrok dengan jadwal kelas lain pada waktu tersebut'
      });
    }

    // Check for schedule conflicts for guru
    const [conflictGuru] = await db.query(
      `SELECT id FROM jadwal
       WHERE guru_id = ? AND hari = ?
       AND ((jam_mulai <= ? AND jam_selesai > ?)
            OR (jam_mulai < ? AND jam_selesai >= ?)
            OR (jam_mulai >= ? AND jam_selesai <= ?))`,
      [guru_id, hari, jam_mulai, jam_mulai, jam_selesai, jam_selesai, jam_mulai, jam_selesai]
    );

    if (conflictGuru.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Guru sudah memiliki jadwal pada waktu tersebut'
      });
    }

    // Create jadwal
    const [result] = await db.query(
      `INSERT INTO jadwal (kelas_id, mapel_id, guru_id, hari, jam_mulai, jam_selesai, ruangan)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [kelas_id, mapel_id, guru_id, hari, jam_mulai, jam_selesai, ruangan]
    );

    // Get created jadwal
    const [created] = await db.query(
      `SELECT j.*, k.nama_kelas, m.nama_mapel, g.nama as nama_guru
       FROM jadwal j
       JOIN kelas k ON j.kelas_id = k.id
       JOIN mata_pelajaran m ON j.mapel_id = m.id
       JOIN guru g ON j.guru_id = g.id
       WHERE j.id = ?`,
      [result.insertId]
    );

    res.status(201).json({
      success: true,
      message: 'Jadwal berhasil ditambahkan',
      data: created[0]
    });
  } catch (error) {
    console.error('Create jadwal error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menambahkan jadwal'
    });
  }
};

// Update jadwal
exports.updateJadwal = async (req, res) => {
  try {
    const { id } = req.params;
    const { kelas_id, mapel_id, guru_id, hari, jam_mulai, jam_selesai, ruangan } = req.body;

    // Check if jadwal exists
    const [existing] = await db.query('SELECT * FROM jadwal WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Jadwal tidak ditemukan'
      });
    }

    const jadwal = existing[0];

    // Check for conflicts if time/kelas/guru changed
    const finalKelas = kelas_id || jadwal.kelas_id;
    const finalGuru = guru_id || jadwal.guru_id;
    const finalHari = hari || jadwal.hari;
    const finalJamMulai = jam_mulai || jadwal.jam_mulai;
    const finalJamSelesai = jam_selesai || jadwal.jam_selesai;

    // Check kelas conflicts
    const [conflictKelas] = await db.query(
      `SELECT id FROM jadwal
       WHERE kelas_id = ? AND hari = ? AND id != ?
       AND ((jam_mulai <= ? AND jam_selesai > ?)
            OR (jam_mulai < ? AND jam_selesai >= ?)
            OR (jam_mulai >= ? AND jam_selesai <= ?))`,
      [finalKelas, finalHari, id, finalJamMulai, finalJamMulai, finalJamSelesai, finalJamSelesai, finalJamMulai, finalJamSelesai]
    );

    if (conflictKelas.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Jadwal bentrok dengan jadwal kelas lain pada waktu tersebut'
      });
    }

    // Check guru conflicts
    const [conflictGuru] = await db.query(
      `SELECT id FROM jadwal
       WHERE guru_id = ? AND hari = ? AND id != ?
       AND ((jam_mulai <= ? AND jam_selesai > ?)
            OR (jam_mulai < ? AND jam_selesai >= ?)
            OR (jam_mulai >= ? AND jam_selesai <= ?))`,
      [finalGuru, finalHari, id, finalJamMulai, finalJamMulai, finalJamSelesai, finalJamSelesai, finalJamMulai, finalJamSelesai]
    );

    if (conflictGuru.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Guru sudah memiliki jadwal pada waktu tersebut'
      });
    }

    // Update jadwal
    await db.query(
      `UPDATE jadwal SET
        kelas_id = COALESCE(?, kelas_id),
        mapel_id = COALESCE(?, mapel_id),
        guru_id = COALESCE(?, guru_id),
        hari = COALESCE(?, hari),
        jam_mulai = COALESCE(?, jam_mulai),
        jam_selesai = COALESCE(?, jam_selesai),
        ruangan = COALESCE(?, ruangan)
       WHERE id = ?`,
      [kelas_id, mapel_id, guru_id, hari, jam_mulai, jam_selesai, ruangan, id]
    );

    // Get updated jadwal
    const [updated] = await db.query(
      `SELECT j.*, k.nama_kelas, m.nama_mapel, g.nama as nama_guru
       FROM jadwal j
       JOIN kelas k ON j.kelas_id = k.id
       JOIN mata_pelajaran m ON j.mapel_id = m.id
       JOIN guru g ON j.guru_id = g.id
       WHERE j.id = ?`,
      [id]
    );

    res.json({
      success: true,
      message: 'Jadwal berhasil diperbarui',
      data: updated[0]
    });
  } catch (error) {
    console.error('Update jadwal error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat memperbarui jadwal'
    });
  }
};

// Delete jadwal
exports.deleteJadwal = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if jadwal exists
    const [existing] = await db.query('SELECT id FROM jadwal WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Jadwal tidak ditemukan'
      });
    }

    await db.query('DELETE FROM jadwal WHERE id = ?', [id]);

    res.json({
      success: true,
      message: 'Jadwal berhasil dihapus'
    });
  } catch (error) {
    console.error('Delete jadwal error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat menghapus jadwal'
    });
  }
};

// Get guru schedule
exports.getGuruSchedule = async (req, res) => {
  try {
    const { guru_id } = req.params;

    const [rows] = await db.query(
      `SELECT j.*, k.nama_kelas, m.nama_mapel, m.kode_mapel
       FROM jadwal j
       JOIN kelas k ON j.kelas_id = k.id
       JOIN mata_pelajaran m ON j.mapel_id = m.id
       WHERE j.guru_id = ?
       ORDER BY FIELD(j.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), j.jam_mulai`,
      [guru_id]
    );

    // Group by hari
    const grouped = {};
    const hariList = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    hariList.forEach(h => grouped[h] = []);

    rows.forEach(jadwal => {
      if (!grouped[jadwal.hari]) grouped[jadwal.hari] = [];
      grouped[jadwal.hari].push(jadwal);
    });

    res.json({
      success: true,
      data: grouped
    });
  } catch (error) {
    console.error('Get guru schedule error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil jadwal guru'
    });
  }
};
