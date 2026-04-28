import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'scan_modal.dart';

class SIMANISBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const SIMANISBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _primary = Color(0xFF004D34);

  static const _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Beranda'},
    {'icon': Icons.how_to_reg_rounded, 'label': 'Presensi'},
    null, // Tombol Scan Tengah
    {'icon': Icons.notifications_none_rounded, 'label': 'Info'},
    {'icon': Icons.person_rounded, 'label': 'Akun'},
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final navbarHeight = 70.0;
    final totalHeight = navbarHeight + bottomInset;

    return Container(
      height: 90 + bottomInset, // Sesuaikan tinggi total dengan safe area
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. Background Putih Navbar
          Container(
            height: totalHeight,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: navbarHeight,
                  child: Row(
                    children: List.generate(_navItems.length, (index) {
                      if (_navItems[index] == null) {
                        return const Expanded(child: SizedBox()); // Ruang kosong untuk tombol scan
                      }
                      return _buildNavItem(index);
                    }),
                  ),
                ),
                SizedBox(height: bottomInset), // Padding gesture bar / home indicator
              ],
            ),
          ),

          // 2. Tombol Scan Mengambang (Floating)
          Positioned(
            top: 0, // Membuatnya menonjol ke atas
            child: GestureDetector(
              onTap: () => ScanModal.show(context),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scan',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
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

  Widget _buildNavItem(int index) {
    final isSelected = index == selectedIndex;
    final item = _navItems[index]!;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item['icon'] as IconData,
              color: isSelected ? _primary : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item['label'] as String,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? _primary : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}