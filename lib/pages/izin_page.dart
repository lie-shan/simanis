import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF004D34);
  static const primaryDark = Color(0xFF022C22);
  static const surface = Color(0xFFF8F9FA);
  static const card = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1D);
  static const subtle = Color(0xFF3F4943);
  static const border = Color(0xFFBEC9C1);
  static const chip = Color(0xFFEDEEEF);
  static const teal = Color(0xFF0D9488);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFE11D48);
}

// ─── Model ────────────────────────────────────────────────────────────────────
enum IzinStatus { menunggu, disetujui, ditolak }

class IzinItem {
  final String id;
  final String namaSiswa;
  final String kelas;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String jenisIzin;
  final String keterangan;
  final IzinStatus status;
  final String diajukanPada;

  const IzinItem({
    required this.id,
    required this.namaSiswa,
    required this.kelas,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.jenisIzin,
    required this.keterangan,
    required this.status,
    required this.diajukanPada,
  });
}

final _dummyIzin = [
  IzinItem(
    id: 'IZN-001',
    namaSiswa: 'Ahmad Fauzan',
    kelas: 'Kelas 2A',
    tanggalMulai: '10 Apr 2025',
    tanggalSelesai: '11 Apr 2025',
    jenisIzin: 'Sakit',
    keterangan: 'Demam tinggi dan dianjurkan dokter untuk istirahat 2 hari.',
    status: IzinStatus.disetujui,
    diajukanPada: '09 Apr 2025',
  ),
  IzinItem(
    id: 'IZN-002',
    namaSiswa: 'Siti Rahmawati',
    kelas: 'Kelas 1B',
    tanggalMulai: '12 Apr 2025',
    tanggalSelesai: '12 Apr 2025',
    jenisIzin: 'Keperluan Keluarga',
    keterangan: 'Menghadiri acara pernikahan saudara kandung.',
    status: IzinStatus.menunggu,
    diajukanPada: '10 Apr 2025',
  ),
  IzinItem(
    id: 'IZN-003',
    namaSiswa: 'Rizky Maulana',
    kelas: 'Kelas 3A',
    tanggalMulai: '07 Apr 2025',
    tanggalSelesai: '08 Apr 2025',
    jenisIzin: 'Izin Lainnya',
    keterangan: 'Mewakili sekolah dalam lomba olimpiade sains tingkat kota.',
    status: IzinStatus.ditolak,
    diajukanPada: '05 Apr 2025',
  ),
  IzinItem(
    id: 'IZN-004',
    namaSiswa: 'Nurul Hidayah',
    kelas: 'Kelas 2B',
    tanggalMulai: '13 Apr 2025',
    tanggalSelesai: '14 Apr 2025',
    jenisIzin: 'Sakit',
    keterangan: 'Sakit maag kambuh, melampirkan surat dokter.',
    status: IzinStatus.menunggu,
    diajukanPada: '12 Apr 2025',
  ),
  IzinItem(
    id: 'IZN-005',
    namaSiswa: 'Bagas Prasetyo',
    kelas: 'Kelas 1A',
    tanggalMulai: '03 Apr 2025',
    tanggalSelesai: '03 Apr 2025',
    jenisIzin: 'Keperluan Keluarga',
    keterangan: 'Mengantar orang tua ke rumah sakit untuk kontrol rutin.',
    status: IzinStatus.disetujui,
    diajukanPada: '02 Apr 2025',
  ),
  IzinItem(
    id: 'IZN-006',
    namaSiswa: 'Dewi Anggraini',
    kelas: 'Kelas 3B',
    tanggalMulai: '15 Apr 2025',
    tanggalSelesai: '16 Apr 2025',
    jenisIzin: 'Izin Lainnya',
    keterangan: 'Mengikuti seleksi paskibra tingkat kabupaten.',
    status: IzinStatus.menunggu,
    diajukanPada: '13 Apr 2025',
  ),
];

// ─── Halaman Izin ─────────────────────────────────────────────────────────────
class IzinPage extends StatefulWidget {
  const IzinPage({super.key});

  @override
  State<IzinPage> createState() => _IzinPageState();
}

class _IzinPageState extends State<IzinPage>
    with SingleTickerProviderStateMixin {
  IzinStatus? _filterStatus; // null = semua
  String _searchQuery = '';
  final _searchController = TextEditingController();
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<IzinItem> get _filtered {
    return _dummyIzin.where((item) {
      final matchStatus =
          _filterStatus == null || item.status == _filterStatus;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          item.namaSiswa.toLowerCase().contains(q) ||
          item.kelas.toLowerCase().contains(q) ||
          item.jenisIzin.toLowerCase().contains(q);
      return matchStatus && matchSearch;
    }).toList();
  }

  // ── Summary counts
  int get _totalSemua => _dummyIzin.length;
  int get _totalMenunggu =>
      _dummyIzin.where((e) => e.status == IzinStatus.menunggu).length;
  int get _totalDisetujui =>
      _dummyIzin.where((e) => e.status == IzinStatus.disetujui).length;
  int get _totalDitolak =>
      _dummyIzin.where((e) => e.status == IzinStatus.ditolak).length;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: _C.surface,
      floatingActionButton: _buildFab(context),
      bottomNavigationBar: SiakadBottomNavBar(
        selectedIndex: 1, // Tetap highlight tab Presensi karena ini sub-halaman Presensi
        onTap: (i) {
          if (i == 1) {
            // Kembali ke PresensiPage
            Navigator.pop(context);
          } else {
            // Untuk tab lain, pop dulu lalu navigasi dari PresensiPage
            Navigator.pop(context);
          }
        },
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: AnimatedBuilder(
              animation: _animCtrl,
              builder: (_, child) => FadeTransition(
                opacity: _animCtrl,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: _animCtrl, curve: Curves.easeOut)),
                  child: child,
                ),
              ),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Summary Cards ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                      child: _buildSummaryRow(),
                    ),
                  ),

                  // ── Search Bar ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildSearchBar(),
                    ),
                  ),

                  // ── Filter Chips ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 0, 4),
                      child: _buildFilterChips(),
                    ),
                  ),

                  // ── Label Hasil ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_filtered.length} Pengajuan',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _C.subtle,
                            ),
                          ),
                          Text(
                            'Terbaru',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _C.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── List Izin ──
                  _filtered.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) => Padding(
                              padding: EdgeInsets.fromLTRB(
                                  20, 0, 20, i == _filtered.length - 1 ? 100 : 12),
                              child: _IzinCard(
                                item: _filtered[i],
                                onTap: () => _showDetail(context, _filtered[i]),
                              ),
                            ),
                            childCount: _filtered.length,
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

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _C.primaryDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Izin Siswa',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Kelola pengajuan izin & sakit',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Icon notifikasi badge
              Stack(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded,
                        color: Colors.white, size: 26),
                  ),
                  if (_totalMenunggu > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$_totalMenunggu',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  // ── Summary Row ─────────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        _SummaryChip(
          label: 'Semua',
          count: _totalSemua,
          color: _C.primary,
          bg: _C.primary.withOpacity(0.08),
          isSelected: _filterStatus == null,
          onTap: () => setState(() => _filterStatus = null),
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          label: 'Menunggu',
          count: _totalMenunggu,
          color: _C.amber,
          bg: _C.amber.withOpacity(0.1),
          isSelected: _filterStatus == IzinStatus.menunggu,
          onTap: () =>
              setState(() => _filterStatus = IzinStatus.menunggu),
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          label: 'Disetujui',
          count: _totalDisetujui,
          color: _C.teal,
          bg: _C.teal.withOpacity(0.1),
          isSelected: _filterStatus == IzinStatus.disetujui,
          onTap: () =>
              setState(() => _filterStatus = IzinStatus.disetujui),
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          label: 'Ditolak',
          count: _totalDitolak,
          color: _C.red,
          bg: _C.red.withOpacity(0.08),
          isSelected: _filterStatus == IzinStatus.ditolak,
          onTap: () =>
              setState(() => _filterStatus = IzinStatus.ditolak),
        ),
      ],
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.inter(fontSize: 14, color: _C.onSurface),
        decoration: InputDecoration(
          hintText: 'Cari nama siswa, kelas, jenis izin…',
          hintStyle: GoogleFonts.inter(
              fontSize: 13, color: Colors.grey.shade400),
          prefixIcon:
              Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close_rounded,
                      color: Colors.grey.shade400, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── Filter Chips ────────────────────────────────────────────────────────────
  Widget _buildFilterChips() {
    final jenisOptions = ['Sakit', 'Keperluan Keluarga', 'Izin Lainnya'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: jenisOptions.map((jenis) {
          final isActive = _searchQuery == jenis;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_searchQuery == jenis) {
                    _searchQuery = '';
                    _searchController.clear();
                  } else {
                    _searchQuery = jenis;
                    _searchController.text = jenis;
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? _C.primary : _C.card,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isActive ? _C.primary : _C.border.withOpacity(0.6),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: _C.primary.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  jenis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight:
                        isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? Colors.white : _C.subtle,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────────────
  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showFormIzin(context),
      backgroundColor: _C.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        'Ajukan Izin',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.12,
            child: Icon(Icons.event_busy_rounded,
                size: 100, color: _C.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data izin',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _C.subtle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail Bottom Sheet ──────────────────────────────────────────────────────
  void _showDetail(BuildContext context, IzinItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(item: item),
    );
  }

  // ── Form Ajukan Izin ────────────────────────────────────────────────────────
  void _showFormIzin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _FormIzinSheet(),
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;
  final bool isSelected;
  final VoidCallback onTap;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : _C.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : _C.border.withOpacity(0.5),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withOpacity(0.85)
                      : _C.subtle,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Izin Card ────────────────────────────────────────────────────────────────
class _IzinCard extends StatelessWidget {
  final IzinItem item;
  final VoidCallback onTap;

  const _IzinCard({required this.item, required this.onTap});

  Color get _statusColor {
    switch (item.status) {
      case IzinStatus.menunggu:
        return _C.amber;
      case IzinStatus.disetujui:
        return _C.teal;
      case IzinStatus.ditolak:
        return _C.red;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case IzinStatus.menunggu:
        return 'Menunggu';
      case IzinStatus.disetujui:
        return 'Disetujui';
      case IzinStatus.ditolak:
        return 'Ditolak';
    }
  }

  IconData get _statusIcon {
    switch (item.status) {
      case IzinStatus.menunggu:
        return Icons.hourglass_top_rounded;
      case IzinStatus.disetujui:
        return Icons.check_circle_rounded;
      case IzinStatus.ditolak:
        return Icons.cancel_rounded;
    }
  }

  IconData get _jenisIcon {
    switch (item.jenisIzin) {
      case 'Sakit':
        return Icons.local_hospital_rounded;
      case 'Keperluan Keluarga':
        return Icons.family_restroom_rounded;
      default:
        return Icons.assignment_rounded;
    }
  }

  Color get _jenisColor {
    switch (item.jenisIzin) {
      case 'Sakit':
        return _C.red;
      case 'Keperluan Keluarga':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF0284C7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top accent bar ──
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: Nama + Status ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ikon jenis izin
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _jenisColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _jenisColor.withOpacity(0.2)),
                        ),
                        child: Icon(_jenisIcon,
                            color: _jenisColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.namaSiswa,
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: _C.onSurface,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                _Chip(
                                  label: item.kelas,
                                  color: _C.primary,
                                  bg: _C.primary.withOpacity(0.08),
                                ),
                                const SizedBox(width: 6),
                                _Chip(
                                  label: item.jenisIzin,
                                  color: _jenisColor,
                                  bg: _jenisColor.withOpacity(0.08),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_statusIcon,
                                size: 12, color: _statusColor),
                            const SizedBox(width: 4),
                            Text(
                              _statusLabel,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(height: 1, color: _C.border.withOpacity(0.4)),
                  const SizedBox(height: 10),

                  // ── Row 2: Tanggal + ID ──
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 5),
                      Text(
                        item.tanggalMulai == item.tanggalSelesai
                            ? item.tanggalMulai
                            : '${item.tanggalMulai} – ${item.tanggalSelesai}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _C.subtle,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        item.id,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ── Row 3: Keterangan preview ──
                  Text(
                    item.keterangan,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chip kecil ───────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _Chip(
      {required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final IzinItem item;
  const _DetailSheet({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case IzinStatus.menunggu:
        return _C.amber;
      case IzinStatus.disetujui:
        return _C.teal;
      case IzinStatus.ditolak:
        return _C.red;
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case IzinStatus.menunggu:
        return 'Menunggu Persetujuan';
      case IzinStatus.disetujui:
        return 'Disetujui';
      case IzinStatus.ditolak:
        return 'Ditolak';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: const BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _C.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),

          // ── Status Banner ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: _statusColor.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Icon(
                    item.status == IzinStatus.menunggu
                        ? Icons.hourglass_top_rounded
                        : item.status == IzinStatus.disetujui
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                    color: _statusColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _statusColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.id,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor.withOpacity(0.7),
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: _C.border.withOpacity(0.4)),
          const SizedBox(height: 16),

          // ── Detail Rows ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.person_rounded,
                    label: 'Nama Siswa',
                    value: item.namaSiswa),
                _DetailRow(
                    icon: Icons.school_rounded,
                    label: 'Kelas',
                    value: item.kelas),
                _DetailRow(
                    icon: Icons.category_rounded,
                    label: 'Jenis Izin',
                    value: item.jenisIzin),
                _DetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Tanggal Mulai',
                    value: item.tanggalMulai),
                _DetailRow(
                    icon: Icons.event_rounded,
                    label: 'Tanggal Selesai',
                    value: item.tanggalSelesai),
                _DetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Keterangan',
                    value: item.keterangan),
                _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Diajukan Pada',
                    value: item.diajukanPada),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Action Buttons ──
          Padding(
            padding:
                EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomPad),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: _C.border),
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.close_rounded,
                        size: 16, color: _C.onSurface),
                    label: Text(
                      'Tutup',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _C.onSurface,
                      ),
                    ),
                  ),
                ),
                if (item.status == IzinStatus.menunggu) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side:
                            const BorderSide(color: _C.red, width: 1.5),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.cancel_outlined,
                          size: 16, color: _C.red),
                      label: Text(
                        'Tolak',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.teal,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white),
                      label: Text(
                        'Setujui',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Ajukan Izin Sheet ───────────────────────────────────────────────────
class _FormIzinSheet extends StatefulWidget {
  const _FormIzinSheet();

  @override
  State<_FormIzinSheet> createState() => _FormIzinSheetState();
}

class _FormIzinSheetState extends State<_FormIzinSheet> {
  String _jenisIzin = 'Sakit';
  final _namaController = TextEditingController();
  final _kelasController = TextEditingController();
  final _keteranganController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _kelasController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final keyboardPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding:
          EdgeInsets.fromLTRB(20, 20, 20, 16 + bottomPad + keyboardPad),
      decoration: const BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _C.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Ajukan Izin',
              style: GoogleFonts.manrope(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _C.onSurface,
              ),
            ),
            Text(
              'Isi form di bawah ini dengan lengkap',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),

            // Jenis Izin
            _FormLabel('Jenis Izin'),
            const SizedBox(height: 8),
            Row(
              children: ['Sakit', 'Keperluan Keluarga', 'Izin Lainnya']
                  .map((jenis) {
                final isSelected = _jenisIzin == jenis;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _jenisIzin = jenis),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _C.primary
                              : _C.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? _C.primary
                                : _C.border.withOpacity(0.5),
                          ),
                        ),
                        child: Text(
                          jenis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : _C.subtle,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            _FormLabel('Nama Siswa'),
            const SizedBox(height: 8),
            _FormField(
              controller: _namaController,
              hint: 'Masukkan nama lengkap',
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 14),

            _FormLabel('Kelas'),
            const SizedBox(height: 8),
            _FormField(
              controller: _kelasController,
              hint: 'Contoh: Kelas 2A',
              icon: Icons.school_rounded,
            ),
            const SizedBox(height: 14),

            _FormLabel('Keterangan'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _keteranganController,
                maxLines: 3,
                style:
                    GoogleFonts.inter(fontSize: 13, color: _C.onSurface),
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan izin secara singkat…',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.send_rounded,
                    size: 18, color: Colors.white),
                label: Text(
                  'Kirim Pengajuan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _C.subtle,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(fontSize: 13, color: _C.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.chip,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _C.primary, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _C.subtle,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.onSurface,
                    height: 1.4,
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
