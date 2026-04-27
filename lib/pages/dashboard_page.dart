import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pengumuman_page.dart';
import 'presensi_page.dart';
import 'akun_page.dart';
import 'elearning_page.dart';        // ← Import E-Learning page
import 'school_schedule_page.dart';  // ← Import Jadwal Sekolah page
import 'absensi_page.dart';          // ← Import Absensi page
import 'pembayaran_page.dart';       // ← Import Pembayaran page
import 'data_siswa_page.dart';       // ← Import Data Siswa page
import 'data_guru_page.dart';        // ← Import Data Guru page
import 'mapel_page.dart';            // ← Import Mapel page
import 'izin_page.dart';             // ← Import Izin page
import '../widgets/bottom_navbar.dart';
import '../widgets/scan_modal.dart';
import '../services/api_service.dart';
import '../main.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF735C00);
  static const secondaryContainer = Color(0xFFFED65B);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline = Color(0xFF6F7A72);
  static const outlineVariant = Color(0xFFBEC9C1);
  static const error = Color(0xFFBA1A1A);
}

// ─── Dashboard Page ───────────────────────────────────────────────────────────
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Clear token
              await ApiService().removeToken();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Top App Bar ──
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.primary,
                elevation: 0,
                toolbarHeight: 64,
                expandedHeight: 64,
                forceElevated: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Profile
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.greenAccent.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    'https://i.pravatar.cc/150?img=11',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'SELAMAT DATANG,',
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.greenAccent.withOpacity(0.7),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  Text(
                                    'Ahmad Fauzi',
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Notification & Logout buttons
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade900.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.logout_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () => _showLogoutDialog(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Content ──
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Jadwal horizontal scroll ──
                    _JadwalScrollList(),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _IconGrid(
                        onELearningTap: () => _navigateTo(const ELearningPage()),
                        onJadwalTap: () => _navigateTo(const SchoolSchedulePage()),
                        onAbsensiTap: () => _navigateTo(const AbsensiPage()),
                        onPembayaranTap: () => _navigateTo(const PembayaranPage()),
                        onDataSiswaTap: () => _navigateTo(const DataSiswaPage()),
                        onDataGuruTap: () => _navigateTo(const DataGuruPage()),
                        onMapelTap: () => _navigateTo(const MapelPage()),
                        onIzinTap: () => _navigateTo(const IzinPage()),
                        onLainnyaTap: () => _navigateTo(const PresensiPage()),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Berita Section ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BERITA',
                            style: GoogleFonts.manrope(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    _InformasiScrollList(),
                    const SizedBox(height: 20),

                    // ── Informasi Section ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SectionHeader(title: 'INFORMASI', onViewAll: () => _navigateTo(const PengumumanPage())),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _AnnouncementList(),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // ── Bottom Nav ──
          Align(
            alignment: Alignment.bottomCenter,
            child: SiakadBottomNavBar(
              selectedIndex: _selectedIndex,
              onTap: (i) {
                if (i == 1) {
                  _navigateTo(const PresensiPage());
                } else if (i == 3) {
                  _navigateTo(const PengumumanPage());
                } else if (i == 4) {
                  _navigateTo(const AkunPage());
                } else {
                  setState(() => _selectedIndex = i);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Jadwal Scroll List ───────────────────────────────────────────────────────
class _JadwalScrollList extends StatelessWidget {
  final List<Map<String, dynamic>> jadwal = [
    {
      'mapel': 'Ilmu Pengetahuan Alam',
      'kelas': 'Kelas 3A',
      'jam': '09:30 - 12:00',
      'isLive': true,
    },
    {
      'mapel': 'Matematika',
      'kelas': 'Kelas 3A',
      'jam': '11:00 - 12:30',
      'isLive': false,
    },
    {
      'mapel': 'Bahasa Indonesia',
      'kelas': 'Kelas 3A',
      'jam': '13:00 - 14:30',
      'isLive': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: jadwal.length,
        itemBuilder: (context, index) {
          final item = jadwal[index];
          final isLive = item['isLive'] as bool;
          return Container(
            width: MediaQuery.of(context).size.width - 32,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLive ? 'LIVE NOW' : 'UPCOMING',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.greenAccent.withOpacity(0.8),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['mapel'] as String,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            item['kelas'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            item['jam'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isLive)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      elevation: 0,
                    ),
                    child: Text(
                      'Hadir',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Informasi Scroll List ────────────────────────────────────────────────────
class _InformasiScrollList extends StatelessWidget {
  final List<Map<String, dynamic>> informasi = [
    {
      'title': 'Celebrating Academic Excellence: Happy New Year 2024!',
      'kategori': 'Event',
      'tanggal': '24 Dec 2023',
      'image':
          'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=800',
    },
    {
      'title': 'Pendaftaran Ekstrakurikuler Semester Genap 2024',
      'kategori': 'Akademik',
      'tanggal': '20 Jan 2024',
      'image':
          'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=800',
    },
    {
      'title': 'Jadwal Ujian Tengah Semester (UTS) 2024',
      'kategori': 'Ujian',
      'tanggal': '15 Jan 2024',
      'image':
          'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=800',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: informasi.length,
        itemBuilder: (context, index) {
          final item = informasi[index];
          return Container(
            width: MediaQuery.of(context).size.width - 32,
            margin: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item['image'] as String,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFF022C22),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white24,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF022C22),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.white24,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF022C22).withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['kategori'] as String,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item['tanggal'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['title'] as String,
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Icon Grid ────────────────────────────────────────────────────────────────
class _IconGrid extends StatelessWidget {
  final VoidCallback? onELearningTap;
  final VoidCallback? onJadwalTap;
  final VoidCallback? onAbsensiTap;
  final VoidCallback? onPembayaranTap;
  final VoidCallback? onDataSiswaTap;
  final VoidCallback? onDataGuruTap;
  final VoidCallback? onMapelTap;
  final VoidCallback? onIzinTap;
  final VoidCallback? onLainnyaTap;

  const _IconGrid({
    this.onELearningTap,
    this.onJadwalTap,
    this.onAbsensiTap,
    this.onPembayaranTap,
    this.onDataSiswaTap,
    this.onDataGuruTap,
    this.onMapelTap,
    this.onIzinTap,
    this.onLainnyaTap,
  });

  final List<Map<String, dynamic>> items = const [
    {
      'icon': Icons.school_rounded,
      'label': 'E-Learning',
      'color': Color(0xFF004D34),
      'bg': Color(0xFFE8F5EE),
      'isElearning': true,
      'isJadwal': false,
      'isAbsensi': false,
      'isPembayaran': false,
      'isDataSiswa': false,
      'isDataGuru': false,
      'isMapel': false,
    },
    {
      'icon': Icons.person_rounded,
      'label': 'Data Siswa',
      'color': Color(0xFF2563EB),
      'bg': Color(0xFFEFF6FF),
      'isElearning': false,
      'isJadwal': false,
      'isAbsensi': false,
      'isPembayaran': false,
      'isDataSiswa': true,
      'isDataGuru': false,
      'isMapel': false,
    },
    {
      'icon': Icons.person_search_rounded,
      'label': 'Data Guru',
      'color': Color(0xFFE11D48),
      'bg': Color(0xFFFFF1F2),
      'isElearning': false,
      'isJadwal': false,
      'isAbsensi': false,
      'isPembayaran': false,
      'isDataSiswa': false,
      'isDataGuru': true,
      'isMapel': false,
    },
    {
      'icon': Icons.how_to_reg_rounded,
      'label': 'Absensi',
      'color': Color(0xFF7E22CE),
      'bg': Color(0xFFF3E8FF),
      'isElearning': false,
      'isJadwal': false,
      'isAbsensi': true,
      'isPembayaran': false,
      'isDataSiswa': false,
      'isDataGuru': false,
      'isMapel': false,
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'label': 'Pembayaran',
      'color': Color(0xFF9333EA),
      'bg': Color(0xFFFAF5FF),
      'isElearning': false,
      'isJadwal': false,
      'isAbsensi': false,
      'isPembayaran': true,
      'isDataSiswa': false,
      'isDataGuru': false,
      'isMapel': false,
    },
    {
      'icon': Icons.menu_book_rounded,
      'label': 'Mapel',
      'color': Color(0xFFEA580C),
      'bg': Color(0xFFFFF7ED),
      'isElearning': false,
      'isJadwal': false,
      'isAbsensi': false,
      'isPembayaran': false,
      'isDataSiswa': false,
      'isDataGuru': false,
      'isMapel': true,
    },
    {
      'icon': Icons.event_busy_rounded,
      'label': 'Izin',
      'color': Color(0xFF0D9488),
      'bg': Color(0xFFF0FDFA),
      'isElearning': false,
      'isJadwal': false,
      'isAbsensi': false,
      'isPembayaran': false,
      'isDataSiswa': false,
      'isDataGuru': false,
      'isMapel': false,
      'isIzin': true,
    },
    {
      'icon': Icons.grid_view_rounded,
      'label': 'Lainnya',
      'color': Color(0xFF52525B),
      'bg': Color(0xFFF4F4F5),
      'isElearning': false,
      'isJadwal': false,
      'isAbsensi': false,
      'isPembayaran': false,
      'isDataSiswa': false,
      'isDataGuru': false,
      'isMapel': false,
      'isLainnya': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isElearning = item['isElearning'] as bool;
        final isJadwal = (item['isJadwal'] ?? false) as bool;
        final isAbsensi = (item['isAbsensi'] ?? false) as bool;
        final isPembayaran = (item['isPembayaran'] ?? false) as bool;
        final isDataSiswa = (item['isDataSiswa'] ?? false) as bool;
        final isDataGuru = (item['isDataGuru'] ?? false) as bool;
        final isMapel = (item['isMapel'] ?? false) as bool;
        final isIzin = (item['isIzin'] ?? false) as bool;
        final isLainnya = (item['isLainnya'] ?? false) as bool;
        return GestureDetector(
          onTap: isElearning
              ? onELearningTap
              : isJadwal
                  ? onJadwalTap
                  : isAbsensi
                      ? onAbsensiTap
                      : isPembayaran
                          ? onPembayaranTap
                          : isDataSiswa
                              ? onDataSiswaTap
                              : isDataGuru
                                  ? onDataGuruTap
                                  : isMapel
                                      ? onMapelTap
                                      : isIzin
                                          ? onIzinTap
                                          : isLainnya
                                              ? onLainnyaTap
                                              : () {},
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item['bg'] as Color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: 26,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item['label'] as String,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text(
            'LIHAT SEMUA',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Announcement List ────────────────────────────────────────────────────────
class _AnnouncementList extends StatelessWidget {
  final List<Map<String, dynamic>> announcements = [
    {
      'icon': Icons.campaign_rounded,
      'title': 'Pendaftaran Ekstrakurikuler Semester Genap',
      'category': 'Akademik',
      'date': '20 Jan 2024',
    },
    {
      'icon': Icons.notifications_active_rounded,
      'title': 'Jadwal Ujian Tengah Semester (UTS)',
      'category': 'Ujian',
      'date': '15 Jan 2024',
    },
    {
      'icon': Icons.event_available_rounded,
      'title': 'Libur Nasional Hari Raya Nyepi',
      'category': 'Info Libur',
      'date': '10 Jan 2024',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: announcements.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          item['category'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4D4D8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['date'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}