import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_page.dart';
import 'presensi_page.dart';
import 'pengumuman_page.dart';
import 'data_pribadi_page.dart';
import 'notifikasi_page.dart';
import 'keamanan_akun_page.dart';
import 'bantuan_page.dart';
import '../widgets/bottom_navbar.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _AppColors {
  static const primary = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
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

// ─── Akun Page ────────────────────────────────────────────────────────────────
class AkunPage extends StatelessWidget {
  const AkunPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.surface,
      bottomNavigationBar: SiakadBottomNavBar(
        selectedIndex: 4,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const DashboardPage(),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 250),
                ));
          } else if (i == 1) {
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const PresensiPage(),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 250),
                ));
          } else if (i == 3) {
            Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, animation, __) => const PengumumanPage(),
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

          // ── Content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Profile Card ──
                  _ProfileCard(),
                  const SizedBox(height: 16),

                  // ── Academic Info ──
                  _AcademicInfo(),
                  const SizedBox(height: 24),

                  // ── Menu Pengaturan ──
                  _MenuSection(
                    title: 'Pengaturan Akun',
                    items: [
                      _MenuItem(
                        icon: Icons.person_rounded,
                        label: 'Data Pribadi',
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, animation, __) =>
                                const DataPribadiPage(),
                            transitionsBuilder:
                                (_, animation, __, child) =>
                                    FadeTransition(
                                        opacity: animation,
                                        child: child),
                            transitionDuration:
                                const Duration(milliseconds: 250),
                          ),
                        ),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        label: 'Pengaturan Notifikasi',
                        onTap: () => Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (_, a, __) => const NotifikasiPage(),
                          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                          transitionDuration: const Duration(milliseconds: 250),
                        )),
                      ),
                      _MenuItem(
                        icon: Icons.lock_rounded,
                        label: 'Keamanan Akun',
                        onTap: () => Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (_, a, __) => const KeamananAkunPage(),
                          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                          transitionDuration: const Duration(milliseconds: 250),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Menu Bantuan ──
                  _MenuSection(
                    title: 'Bantuan',
                    items: [
                      _MenuItem(
                        icon: Icons.help_rounded,
                        label: 'Bantuan & Dukungan',
                        onTap: () => Navigator.push(context, PageRouteBuilder(
                          pageBuilder: (_, a, __) => const BantuanPage(),
                          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                          transitionDuration: const Duration(milliseconds: 250),
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Version ──
                  Center(
                    child: Text(
                      'SIAKAD v.2.4.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color:
                            _AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                    'Akun',
                    style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              // Logout button
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: _AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top accent strip
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),

          // Avatar
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _AppColors.surfaceContainerLow,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _AppColors.surfaceContainerLowest,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nama
          Text(
            'Ahmad Fauzi',
            style: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _AppColors.primary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // NIS
          Text(
            'NIS: 0092384112',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Kelas badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(
                color: _AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.school_rounded,
                    color: Colors.green.shade900, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Kelas 3A',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Academic Info ────────────────────────────────────────────────────────────
class _AcademicInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _InfoItem(label: 'Kehadiran', value: '98.5%', showDivider: true),
          _InfoItem(label: 'Akhlak', value: 'A', showDivider: true),
          _InfoItem(label: 'Keaktifan', value: '92.5%', showDivider: false),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Container(
              width: 1,
              height: 36,
              color: _AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
        ],
      ),
    );
  }
}

// ─── Menu Section ─────────────────────────────────────────────────────────────
class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _AppColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: _AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: List.generate(items.length, (index) {
              return Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      color: _AppColors.outlineVariant.withValues(alpha: 0.3),
                      indent: 64,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Menu Item ────────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: _AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                size: 22,
              ),
            ],
          ),
        ),
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