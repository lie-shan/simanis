const db = require('../config/database');

// Get dashboard overview
exports.getDashboardOverview = async (req, res) => {
  try {
    const { tahun_ajaran } = req.query;
    const tahunAjaran = tahun_ajaran || '2023/2024';

    // Count statistics
    const [counts] = await db.query(
      `SELECT
        (SELECT COUNT(*) FROM users WHERE status = 'aktif') as total_users,
        (SELECT COUNT(*) FROM siswa) as total_siswa,
        (SELECT COUNT(*) FROM guru) as total_guru,
        (SELECT COUNT(*) FROM kelas WHERE tahun_ajaran = ?) as total_kelas,
        (SELECT COUNT(*) FROM mata_pelajaran) as total_mapel,
        (SELECT COUNT(*) FROM jadwal j JOIN kelas k ON j.kelas_id = k.id WHERE k.tahun_ajaran = ?) as total_jadwal
      FROM dual`,
      [tahunAjaran, tahunAjaran]
    );

    // Today's presensi summary
    const today = new Date().toISOString().split('T')[0];
    const [presensiToday] = await db.query(
      `SELECT
        status,
        COUNT(*) as total
       FROM presensi
       WHERE tanggal = ?
       GROUP BY status`,
      [today]
    );

    // Pembayaran summary
    const [pembayaranSummary] = await db.query(
      `SELECT
        status,
        COUNT(*) as total,
        SUM(jumlah) as total_jumlah
       FROM pembayaran
       GROUP BY status`
    );

    // Active pengumuman
    const [pengumumanActive] = await db.query(
      `SELECT
        COUNT(*) as total
       FROM pengumuman
       WHERE status = 'published'
         AND (tanggal_mulai IS NULL OR tanggal_mulai <= CURDATE())
         AND (tanggal_selesai IS NULL OR tanggal_selesai >= CURDATE())`
    );

    // Recent activities (nilai updates)
    const [recentNilai] = await db.query(
      `SELECT n.*,
              s.nama as nama_siswa,
              m.nama_mapel,
              g.nama as nama_guru
       FROM nilai n
       JOIN siswa s ON n.siswa_id = s.id
       JOIN mata_pelajaran m ON n.mapel_id = m.id
       LEFT JOIN guru g ON n.guru_id = g.id
       ORDER BY n.updated_at DESC
       LIMIT 5`
    );

    // Recent presensi
    const [recentPresensi] = await db.query(
      `SELECT p.*, s.nama as nama_siswa, k.nama_kelas
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       LEFT JOIN kelas k ON s.kelas_id = k.id
       ORDER BY p.created_at DESC
       LIMIT 5`
    );

    // Kelas statistics
    const [kelasStats] = await db.query(
      `SELECT k.nama_kelas,
              COUNT(DISTINCT s.id) as total_siswa,
              COUNT(DISTINCT j.id) as total_jadwal
       FROM kelas k
       LEFT JOIN siswa s ON k.id = s.kelas_id
       LEFT JOIN jadwal j ON k.id = j.kelas_id
       WHERE k.tahun_ajaran = ?
       GROUP BY k.id, k.nama_kelas
       ORDER BY k.nama_kelas`,
      [tahunAjaran]
    );

    res.json({
      success: true,
      data: {
        tahun_ajaran: tahunAjaran,
        counts: counts[0],
        presensi_today: {
          tanggal: today,
          summary: presensiToday
        },
        pembayaran_summary: pembayaranSummary,
        pengumuman_active: pengumumanActive[0].total,
        recent_nilai: recentNilai,
        recent_presensi: recentPresensi,
        kelas_stats: kelasStats
      }
    });
  } catch (error) {
    console.error('Get dashboard overview error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil data dashboard'
    });
  }
};

// Get academic statistics
exports.getAcademicStats = async (req, res) => {
  try {
    const { tahun_ajaran, semester, kelas_id } = req.query;

    let whereClause = '';
    const params = [];

    if (tahun_ajaran) {
      whereClause += ' AND n.tahun_ajaran = ?';
      params.push(tahun_ajaran);
    }
    if (semester) {
      whereClause += ' AND n.semester = ?';
      params.push(semester);
    }
    if (kelas_id) {
      whereClause += ' AND n.kelas_id = ?';
      params.push(kelas_id);
    }

    // Grade distribution
    const [gradeDistribution] = await db.query(
      `SELECT grade, COUNT(*) as total
       FROM nilai n
       WHERE 1=1 ${whereClause}
       GROUP BY grade
       ORDER BY FIELD(grade, 'A', 'B', 'C', 'D', 'E')`,
      params
    );

    // Average per mata pelajaran
    const [avgPerMapel] = await db.query(
      `SELECT m.nama_mapel, m.kode_mapel,
              COUNT(n.id) as total_nilai,
              AVG(n.nilai_akhir) as rata_rata,
              MAX(n.nilai_akhir) as nilai_tertinggi,
              MIN(n.nilai_akhir) as nilai_terendah
       FROM nilai n
       JOIN mata_pelajaran m ON n.mapel_id = m.id
       WHERE 1=1 ${whereClause}
       GROUP BY m.id, m.nama_mapel, m.kode_mapel
       ORDER BY rata_rata DESC`,
      params
    );

    // Average per kelas
    const [avgPerKelas] = await db.query(
      `SELECT k.nama_kelas,
              COUNT(DISTINCT n.siswa_id) as total_siswa,
              COUNT(n.id) as total_nilai,
              AVG(n.nilai_akhir) as rata_rata
       FROM nilai n
       JOIN kelas k ON n.kelas_id = k.id
       WHERE 1=1 ${whereClause}
       GROUP BY k.id, k.nama_kelas
       ORDER BY rata_rata DESC`,
      params
    );

    // Top 10 students
    const [topStudents] = await db.query(
      `SELECT s.nis, s.nama as nama_siswa, k.nama_kelas,
              COUNT(n.id) as total_mapel,
              AVG(n.nilai_akhir) as rata_rata
       FROM nilai n
       JOIN siswa s ON n.siswa_id = s.id
       JOIN kelas k ON n.kelas_id = k.id
       WHERE 1=1 ${whereClause}
       GROUP BY s.id, s.nis, s.nama, k.nama_kelas
       HAVING COUNT(n.id) >= 5
       ORDER BY rata_rata DESC
       LIMIT 10`,
      params
    );

    res.json({
      success: true,
      data: {
        grade_distribution: gradeDistribution,
        avg_per_mapel: avgPerMapel,
        avg_per_kelas: avgPerKelas,
        top_students: topStudents
      }
    });
  } catch (error) {
    console.error('Get academic stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil statistik akademik'
    });
  }
};

// Get financial statistics
exports.getFinancialStats = async (req, res) => {
  try {
    const { tahun, bulan } = req.query;

    let whereClause = '';
    const params = [];

    if (tahun) {
      whereClause += ' AND YEAR(tanggal_jatuh_tempo) = ?';
      params.push(tahun);
    }
    if (bulan) {
      whereClause += ' AND MONTH(tanggal_jatuh_tempo) = ?';
      params.push(bulan);
    }

    // Total per jenis pembayaran
    const [perJenis] = await db.query(
      `SELECT jenis_pembayaran,
              COUNT(*) as total_tagihan,
              SUM(CASE WHEN status = 'lunas' THEN 1 ELSE 0 END) as total_lunas,
              SUM(CASE WHEN status = 'lunas' THEN jumlah ELSE 0 END) as total_terbayar,
              SUM(CASE WHEN status != 'lunas' THEN jumlah ELSE 0 END) as total_belum
       FROM pembayaran
       WHERE 1=1 ${whereClause}
       GROUP BY jenis_pembayaran`,
      params
    );

    // Monthly trend
    const [monthlyTrend] = await db.query(
      `SELECT DATE_FORMAT(tanggal_bayar, '%Y-%m') as bulan,
              COUNT(*) as total_pembayaran,
              SUM(jumlah) as total_jumlah
       FROM pembayaran
       WHERE status = 'lunas'
         AND tanggal_bayar >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
       GROUP BY DATE_FORMAT(tanggal_bayar, '%Y-%m')
       ORDER BY bulan`,
      []
    );

    // Per kelas summary
    const [perKelas] = await db.query(
      `SELECT k.nama_kelas,
              COUNT(*) as total_tagihan,
              SUM(CASE WHEN p.status = 'lunas' THEN p.jumlah ELSE 0 END) as total_terbayar,
              SUM(CASE WHEN p.status != 'lunas' THEN p.jumlah ELSE 0 END) as total_belum
       FROM pembayaran p
       JOIN siswa s ON p.siswa_id = s.id
       JOIN kelas k ON s.kelas_id = k.id
       WHERE 1=1 ${whereClause}
       GROUP BY k.id, k.nama_kelas
       ORDER BY k.nama_kelas`,
      params
    );

    res.json({
      success: true,
      data: {
        per_jenis: perJenis,
        monthly_trend: monthlyTrend,
        per_kelas: perKelas
      }
    });
  } catch (error) {
    console.error('Get financial stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil statistik keuangan'
    });
  }
};

// Get attendance statistics
exports.getAttendanceStats = async (req, res) => {
  try {
    const { tahun, bulan, kelas_id } = req.query;

    let whereClause = '';
    const params = [];

    if (tahun) {
      whereClause += ' AND YEAR(p.tanggal) = ?';
      params.push(tahun);
    }
    if (bulan) {
      whereClause += ' AND MONTH(p.tanggal) = ?';
      params.push(bulan);
    }
    if (kelas_id) {
      whereClause += ' AND s.kelas_id = ?';
      params.push(kelas_id);
    }

    // Status distribution
    const [statusDist] = await db.query(
      `SELECT p.status,
              COUNT(*) as total,
              ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM presensi p2
                JOIN siswa s2 ON p2.siswa_id = s2.id
                WHERE 1=1 ${whereClause}), 2) as percentage
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       WHERE 1=1 ${whereClause}
       GROUP BY p.status`,
      [...params, ...params]
    );

    // Daily trend (last 30 days)
    const [dailyTrend] = await db.query(
      `SELECT tanggal,
              COUNT(*) as total,
              SUM(CASE WHEN status = 'hadir' THEN 1 ELSE 0 END) as hadir,
              SUM(CASE WHEN status = 'alpha' THEN 1 ELSE 0 END) as alpha
       FROM presensi
       WHERE tanggal >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
       GROUP BY tanggal
       ORDER BY tanggal`,
      []
    );

    // Per kelas
    const [perKelas] = await db.query(
      `SELECT k.nama_kelas,
              COUNT(*) as total,
              SUM(CASE WHEN p.status = 'hadir' THEN 1 ELSE 0 END) as hadir,
              ROUND(SUM(CASE WHEN p.status = 'hadir' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as persentase_hadir
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       JOIN kelas k ON s.kelas_id = k.id
       WHERE 1=1 ${whereClause}
       GROUP BY k.id, k.nama_kelas
       ORDER BY persentase_hadir DESC`,
      params
    );

    // Students with most absences
    const [topAbsences] = await db.query(
      `SELECT s.nis, s.nama, k.nama_kelas,
              COUNT(*) as total_alpha
       FROM presensi p
       JOIN siswa s ON p.siswa_id = s.id
       JOIN kelas k ON s.kelas_id = k.id
       WHERE p.status = 'alpha'
         ${whereClause.replace(/p\./g, 'p2.').replace(/s\./g, 's2.')}
       GROUP BY s.id, s.nis, s.nama, k.nama_kelas
       ORDER BY total_alpha DESC
       LIMIT 10`,
      params
    );

    res.json({
      success: true,
      data: {
        status_distribution: statusDist,
        daily_trend: dailyTrend,
        per_kelas: perKelas,
        top_absences: topAbsences
      }
    });
  } catch (error) {
    console.error('Get attendance stats error:', error);
    res.status(500).json({
      success: false,
      message: 'Terjadi kesalahan saat mengambil statistik presensi'
    });
  }
};
