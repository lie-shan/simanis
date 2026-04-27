import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pengumuman_page.dart';
import 'dashboard_page.dart';
import 'akun_page.dart';
import 'elearning_page.dart';
import 'data_siswa_page.dart';
import 'data_guru_page.dart';
import 'kelas_page.dart';
import 'absensi_page.dart';
import 'mapel_page.dart';
import 'jadwal_page.dart';
import 'izin_page.dart';
import 'pembayaran_page.dart';
import 'nilai_page.dart';
import 'data_pengguna_page.dart';
import '../widgets/bottom_navbar.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _AppColors {
  static const primary = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
  static const secondaryContainer = Color(0xFFFED65B);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline = Color(0xFF6F7A72);
  static const outlineVariant = Color(0xFFBEC9C1);
}

// ─── Presensi Page ────────────────────────────────────────────────────────────
class PresensiPage extends StatefulWidget {
  const PresensiPage({super.key});

  @override
  State<PresensiPage> createState() => _PresensiPageState();
}

class _PresensiPageState extends State<PresensiPage> {
  int _selectedIndex = 1;

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.school_rounded,
      'label': 'E-Learning',
      'color': Color(0xFF004D34),
      'bg': Color(0xFFE8F5EE),
    },
    {
      'icon': Icons.person_rounded,
      'label': 'Data Siswa',
      'color': Color(0xFF2563EB),
      'bg': Color(0xFFEFF6FF),
    },
    {
      'icon': Icons.person_search_rounded,
      'label': 'Data Guru',
      'color': Color(0xFFE11D48),
      'bg': Color(0xFFFFF1F2),
    },
    {
      'icon': Icons.class_rounded,
      'label': 'Kelas',
      'color': Color(0xFF0284C7),
      'bg': Color(0xFFF0F9FF),
    },
    {
      'icon': Icons.how_to_reg_rounded,
      'label': 'Absensi',
      'color': Color(0xFF7E22CE),
      'bg': Color(0xFFF3E8FF),
    },
    {
      'icon': Icons.account_balance_wallet_rounded,
      'label': 'Pembayaran',
      'color': Color(0xFF9333EA),
      'bg': Color(0xFFFAF5FF),
    },
    {
      'icon': Icons.menu_book_rounded,
      'label': 'Mapel',
      'color': Color(0xFFEA580C),
      'bg': Color(0xFFFFF7ED),
    },
    {
      'icon': Icons.calendar_month_rounded,
      'label': 'Jadwal',
      'color': Color(0xFF0284C7),
      'bg': Color(0xFFF0F9FF),
    },
    {
      'icon': Icons.event_busy_rounded,
      'label': 'Izin',
      'color': Color(0xFF0D9488),
      'bg': Color(0xFFF0FDFA),
    },
    {
      'icon': Icons.grade_rounded,
      'label': 'Nilai',
      'color': Color(0xFFD97706),
      'bg': Color(0xFFFFFBEB),
    },
    {
      'icon': Icons.manage_accounts_rounded,
      'label': 'Data Pengguna',
      'color': Color(0xFF7C3AED),
      'bg': Color(0xFFF5F3FF),
    },
  ];

  // ── Helper navigasi ────────────────────────────────────────────────────────
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

  void _navigateReplace(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.surface,
      // ── Menggunakan SiakadBottomNavBar dari widgets/bottom_navbar.dart ──
      bottomNavigationBar: SiakadBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) {
          if (i == 0) {
            _navigateReplace(const DashboardPage());
          } else if (i == 3) {
            _navigateReplace(const PengumumanPage());
          } else if (i == 4) {
            _navigateReplace(const AkunPage());
          }
        },
      ),
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(context),

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                children: [
                  // ── Menu Grid ──
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return GestureDetector(
                        onTap: () {
                          if (index == 0) {
                            _navigateTo(const ELearningPage());
                          } else if (index == 1) {
                            _navigateTo(const DataSiswaPage());
                          } else if (index == 2) {
                            _navigateTo(const DataGuruPage());
                          } else if (index == 3) {
                            _navigateTo(const KelasPage());
                          } else if (index == 4) {
                            _navigateTo(const AbsensiPage());
                          } else if (index == 5) {
                            _navigateTo(const PembayaranPage());
                          } else if (index == 6) {
                            _navigateTo(const MapelPage());
                          } else if (index == 7) {
                            _navigateTo(const JadwalPage());
                          } else if (index == 8) {
                            _navigateTo(const IzinPage());
                          } else if (index == 9) {
                            _navigateTo(const NilaiPage());
                          } else if (index == 10) {
                            _navigateTo(const DataPenggunaPage());
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: item['bg'] as Color,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: (item['color'] as Color)
                                        .withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: item['color'] as Color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['label'] as String,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: index == 6
                                    ? const Color(0xFF065F46)
                                    : _AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // ── Empty State ──
                  Opacity(
                    opacity: 0.1,
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 120,
                      color: _AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFF022C22).withValues(alpha: 0.9),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Presensi',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CATATAN: Class _BottomNavBar yang duplikat sudah dihapus.
//    Gunakan SiakadBottomNavBar dari '../widgets/bottom_navbar.dart' ──