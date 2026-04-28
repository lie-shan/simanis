import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'presensi_page.dart';
import 'dashboard_page.dart';
import 'akun_page.dart';
import '../widgets/bottom_navbar.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _AppColors {
  static const primary = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
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
}

// ─── Data Model ───────────────────────────────────────────────────────────────
class PengumumanItem {
  final String judul;
  final String kategori;
  final String tanggal;
  final String deskripsi;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final bool isNew;

  const PengumumanItem({
    required this.judul,
    required this.kategori,
    required this.tanggal,
    required this.deskripsi,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isNew = false,
  });
}

// ─── Pengumuman Page ──────────────────────────────────────────────────────────
class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  int _selectedKategori = 0;

  final List<String> kategoriList = [
    'Semua',
    'Akademik',
    'Ujian',
    'Acara',
    'Libur',
  ];

  final List<PengumumanItem> semuaPengumuman = [
    PengumumanItem(
      judul: 'Pendaftaran Ekstrakurikuler Semester Genap',
      kategori: 'Akademik',
      tanggal: '20 Jan 2024',
      deskripsi:
          'Pendaftaran ekstrakurikuler semester genap telah dibuka. Siswa dapat mendaftar melalui wali kelas masing-masing.',
      icon: Icons.campaign_rounded,
      iconColor: _AppColors.primary,
      iconBg: Color(0xFFE8F5EE),
      isNew: true,
    ),
    PengumumanItem(
      judul: 'Jadwal Ujian Tengah Semester (UTS)',
      kategori: 'Ujian',
      tanggal: '15 Jan 2024',
      deskripsi:
          'UTS akan dilaksanakan mulai tanggal 22 Januari 2024. Harap mempersiapkan diri dengan baik.',
      icon: Icons.notifications_active_rounded,
      iconColor: Color(0xFF7E22CE),
      iconBg: Color(0xFFF3E8FF),
      isNew: true,
    ),
    PengumumanItem(
      judul: 'Libur Nasional Hari Raya Nyepi',
      kategori: 'Libur',
      tanggal: '10 Jan 2024',
      deskripsi:
          'Diberitahukan bahwa pada tanggal 11 Maret 2024 merupakan hari libur nasional Hari Raya Nyepi.',
      icon: Icons.event_available_rounded,
      iconColor: Color(0xFF065F46),
      iconBg: Color(0xFFD1FAE5),
      isNew: false,
    ),
    PengumumanItem(
      judul: 'Peringatan Maulid Nabi Muhammad SAW',
      kategori: 'Acara',
      tanggal: '08 Jan 2024',
      deskripsi:
          'Dalam rangka memperingati Maulid Nabi Muhammad SAW, madrasah akan mengadakan acara istimewa pada tanggal 15 Januari 2024.',
      icon: Icons.star_rounded,
      iconColor: Color(0xFFC2410C),
      iconBg: Color(0xFFFFEDD5),
      isNew: false,
    ),
    PengumumanItem(
      judul: 'Pembagian Rapor Semester Ganjil',
      kategori: 'Akademik',
      tanggal: '05 Jan 2024',
      deskripsi:
          'Pembagian rapor semester ganjil akan dilaksanakan pada tanggal 20 Januari 2024. Orang tua/wali diharap hadir.',
      icon: Icons.menu_book_rounded,
      iconColor: Color(0xFF1D4ED8),
      iconBg: Color(0xFFDBEAFE),
      isNew: false,
    ),
    PengumumanItem(
      judul: 'Libur Semester Ganjil',
      kategori: 'Libur',
      tanggal: '01 Jan 2024',
      deskripsi:
          'Libur semester ganjil dimulai tanggal 21 Desember 2023 sampai dengan 1 Januari 2024.',
      icon: Icons.beach_access_rounded,
      iconColor: Color(0xFF0F766E),
      iconBg: Color(0xFFCCFBF1),
      isNew: false,
    ),
  ];

  List<PengumumanItem> get filteredPengumuman {
    if (_selectedKategori == 0) return semuaPengumuman;
    final kategori = kategoriList[_selectedKategori];
    return semuaPengumuman.where((p) => p.kategori == kategori).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.surface,
      bottomNavigationBar: SIMANISBottomNavBar(
        selectedIndex: 3,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, animation, __) => const DashboardPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 250),
              ),
            );
          } else if (i == 1) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, animation, __) => const PresensiPage(),
                transitionsBuilder: (_, animation, __, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 250),
              ),
            );
          } else if (i == 4) {
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const AkunPage(),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 250),
                ));
          }
        },
      ),
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(context),
          // ── Filter Kategori ──
          _buildKategoriFilter(),
          // ── List Pengumuman ──
          Expanded(
            child: filteredPengumuman.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filteredPengumuman.length,
                    itemBuilder: (context, index) {
                      return _PengumumanCard(
                        item: filteredPengumuman[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _AppColors.primary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${semuaPengumuman.length} informasi tersedia',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Notification badge
              Stack(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKategoriFilter() {
    return Container(
      color: _AppColors.primary,
      child: Container(
        decoration: const BoxDecoration(
          color: _AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
          child: SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: kategoriList.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedKategori == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedKategori = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _AppColors.primary
                          : _AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      kategoriList[index],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : _AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: _AppColors.outline.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pengumuman',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada pengumuman untuk kategori ini',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pengumuman Card ──────────────────────────────────────────────────────────
class _PengumumanCard extends StatelessWidget {
  final PengumumanItem item;

  const _PengumumanCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetail(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.judul,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _AppColors.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (item.isNew)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Text(
                                'Baru',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: _AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.deskripsi,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              item.kategori,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: _AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.tanggal,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right_rounded,
                  color: _AppColors.outline,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PengumumanDetail(item: item),
    );
  }
}

// ─── Pengumuman Detail Bottom Sheet ──────────────────────────────────────────
class _PengumumanDetail extends StatelessWidget {
  final PengumumanItem item;

  const _PengumumanDetail({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Icon + Kategori
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      item.kategori,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: _AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.tanggal,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Judul
          Text(
            item.judul,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _AppColors.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0x1FBEC9C1)),
          const SizedBox(height: 12),
          // Deskripsi
          Text(
            item.deskripsi,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // Tombol tutup
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                'Tutup',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Bottom Navigation Bar ────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.how_to_reg_rounded, 'label': 'Presensi'},
      null, // Scan button
      {'icon': Icons.notifications_rounded, 'label': 'Info'},
      {'icon': Icons.person_rounded, 'label': 'Akun'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              if (items[index] == null) {
                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Transform.translate(
                    offset: const Offset(0, -18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF006747),
                                Color(0xFF004D34),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    _AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Scan',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _AppColors.primary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? _AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index]!['icon'] as IconData,
                        color: isSelected ? Colors.white : Colors.grey.shade400,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[index]!['label'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}