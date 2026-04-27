import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFF004D34);
  static const surface   = Color(0xFFF8F9FA);
  static const card      = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1D);
  static const subtle    = Color(0xFF3F4943);
  static const border    = Color(0xFFBEC9C1);
  static const chip      = Color(0xFFEDEEEF);
  static const gold      = Color(0xFFE9C349);
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _JadwalItem {
  final String id;
  final String mapel;
  final String kode;
  final String guru;
  final String kelas;
  final String ruang;
  final String jamMulai;
  final String jamSelesai;
  final String hari;
  final Color warna;
  final IconData ikon;

  const _JadwalItem({
    required this.id,
    required this.mapel,
    required this.kode,
    required this.guru,
    required this.kelas,
    required this.ruang,
    required this.jamMulai,
    required this.jamSelesai,
    required this.hari,
    required this.warna,
    required this.ikon,
  });

  _JadwalItem copyWith({
    String? id, String? mapel, String? kode, String? guru, String? kelas,
    String? ruang, String? jamMulai, String? jamSelesai, String? hari,
    Color? warna, IconData? ikon,
  }) => _JadwalItem(
    id: id ?? this.id, mapel: mapel ?? this.mapel, kode: kode ?? this.kode,
    guru: guru ?? this.guru, kelas: kelas ?? this.kelas, ruang: ruang ?? this.ruang,
    jamMulai: jamMulai ?? this.jamMulai, jamSelesai: jamSelesai ?? this.jamSelesai,
    hari: hari ?? this.hari, warna: warna ?? this.warna, ikon: ikon ?? this.ikon,
  );
  // TODO: factory _JadwalItem.fromJson / toJson untuk API
}

final _dummyJadwal = [
  // ── Senin ──
  _JadwalItem(
    id: '1',
    mapel: "Al-Qur'an & Tajwid",
    kode: 'QT-01',
    guru: 'H. Mochammad Soleh, S.Pd',
    kelas: 'Kelas 1A',
    ruang: 'Ruang 101',
    jamMulai: '07:00',
    jamSelesai: '08:30',
    hari: 'Senin',
    warna: Color(0xFF059669),
    ikon: Icons.auto_stories_rounded,
  ),
  _JadwalItem(
    id: '2',
    mapel: 'Fiqih & Ibadah',
    kode: 'FI-02',
    guru: 'Ustadzah Nurul Hidayah, S.Ag',
    kelas: 'Kelas 1A',
    ruang: 'Ruang 102',
    jamMulai: '08:45',
    jamSelesai: '10:00',
    hari: 'Senin',
    warna: Color(0xFF0284C7),
    ikon: Icons.mosque_rounded,
  ),
  _JadwalItem(
    id: '3',
    mapel: 'Bahasa Arab',
    kode: 'BA-05',
    guru: 'Abdurrahman Wahid, Lc',
    kelas: 'Kelas 2B',
    ruang: 'Ruang 201',
    jamMulai: '10:15',
    jamSelesai: '11:30',
    hari: 'Senin',
    warna: Color(0xFFEA580C),
    ikon: Icons.translate_rounded,
  ),
  _JadwalItem(
    id: '4',
    mapel: 'Tahfidz Al-Qur\'an',
    kode: 'TQ-07',
    guru: 'Muhammad Rizal, S.Pd.I',
    kelas: 'Kelas 3A',
    ruang: 'Aula Utama',
    jamMulai: '13:00',
    jamSelesai: '14:30',
    hari: 'Senin',
    warna: Color(0xFF065F46),
    ikon: Icons.menu_book_rounded,
  ),

  // ── Selasa ──
  _JadwalItem(
    id: '5',
    mapel: 'Aqidah & Tauhid',
    kode: 'AQ-08',
    guru: 'Dewi Rahmawati, S.Ag',
    kelas: 'Kelas 1B',
    ruang: 'Ruang 103',
    jamMulai: '07:00',
    jamSelesai: '08:30',
    hari: 'Selasa',
    warna: Color(0xFF9333EA),
    ikon: Icons.lightbulb_rounded,
  ),
  _JadwalItem(
    id: '6',
    mapel: 'Akhlak & Tasawuf',
    kode: 'AT-04',
    guru: 'Siti Rohmah, S.Ag',
    kelas: 'Kelas 2A',
    ruang: 'Ruang 202',
    jamMulai: '08:45',
    jamSelesai: '10:00',
    hari: 'Selasa',
    warna: Color(0xFFDB2777),
    ikon: Icons.favorite_rounded,
  ),
  _JadwalItem(
    id: '7',
    mapel: 'Hadits & Sirah',
    kode: 'HS-03',
    guru: 'Ustadz Ikhwan Fauzi, S.Pd.I',
    kelas: 'Kelas 2B',
    ruang: 'Ruang 203',
    jamMulai: '10:15',
    jamSelesai: '11:30',
    hari: 'Selasa',
    warna: Color(0xFF7C3AED),
    ikon: Icons.history_edu_rounded,
  ),

  // ── Rabu ──
  _JadwalItem(
    id: '8',
    mapel: 'Nahwu & Sharaf',
    kode: 'NS-06',
    guru: 'Hj. Fatimah Az-Zahra, S.Pd',
    kelas: 'Kelas 2A',
    ruang: 'Ruang 204',
    jamMulai: '07:00',
    jamSelesai: '08:30',
    hari: 'Rabu',
    warna: Color(0xFF0D9488),
    ikon: Icons.spellcheck_rounded,
  ),
  _JadwalItem(
    id: '9',
    mapel: "Al-Qur'an & Tajwid",
    kode: 'QT-01',
    guru: 'H. Mochammad Soleh, S.Pd',
    kelas: 'Kelas 2B',
    ruang: 'Ruang 101',
    jamMulai: '08:45',
    jamSelesai: '10:00',
    hari: 'Rabu',
    warna: Color(0xFF059669),
    ikon: Icons.auto_stories_rounded,
  ),
  _JadwalItem(
    id: '10',
    mapel: 'Tahfidz Al-Qur\'an',
    kode: 'TQ-07',
    guru: 'Muhammad Rizal, S.Pd.I',
    kelas: 'Kelas 1A',
    ruang: 'Aula Utama',
    jamMulai: '10:15',
    jamSelesai: '11:30',
    hari: 'Rabu',
    warna: Color(0xFF065F46),
    ikon: Icons.menu_book_rounded,
  ),

  // ── Kamis ──
  _JadwalItem(
    id: '11',
    mapel: 'Fiqih & Ibadah',
    kode: 'FI-02',
    guru: 'Ustadzah Nurul Hidayah, S.Ag',
    kelas: 'Kelas 3A',
    ruang: 'Ruang 102',
    jamMulai: '07:00',
    jamSelesai: '08:30',
    hari: 'Kamis',
    warna: Color(0xFF0284C7),
    ikon: Icons.mosque_rounded,
  ),
  _JadwalItem(
    id: '12',
    mapel: 'Sejarah Islam',
    kode: 'SI-09',
    guru: 'Ustadz Zainul Arifin, S.Pd',
    kelas: 'Kelas 3B',
    ruang: 'Ruang 301',
    jamMulai: '08:45',
    jamSelesai: '10:00',
    hari: 'Kamis',
    warna: Color(0xFF92400E),
    ikon: Icons.public_rounded,
  ),
  _JadwalItem(
    id: '13',
    mapel: 'Bahasa Arab',
    kode: 'BA-05',
    guru: 'Abdurrahman Wahid, Lc',
    kelas: 'Kelas 1B',
    ruang: 'Ruang 201',
    jamMulai: '13:00',
    jamSelesai: '14:30',
    hari: 'Kamis',
    warna: Color(0xFFEA580C),
    ikon: Icons.translate_rounded,
  ),

  // ── Jumat ──
  _JadwalItem(
    id: '14',
    mapel: 'Tahfidz Al-Qur\'an',
    kode: 'TQ-07',
    guru: 'Muhammad Rizal, S.Pd.I',
    kelas: 'Kelas 2A',
    ruang: 'Aula Utama',
    jamMulai: '07:00',
    jamSelesai: '08:30',
    hari: 'Jumat',
    warna: Color(0xFF065F46),
    ikon: Icons.menu_book_rounded,
  ),
  _JadwalItem(
    id: '15',
    mapel: 'Akhlak & Tasawuf',
    kode: 'AT-04',
    guru: 'Siti Rohmah, S.Ag',
    kelas: 'Kelas 3A',
    ruang: 'Ruang 202',
    jamMulai: '08:45',
    jamSelesai: '10:00',
    hari: 'Jumat',
    warna: Color(0xFFDB2777),
    ikon: Icons.favorite_rounded,
  ),
];

// ─── Halaman Jadwal ───────────────────────────────────────────────────────────
class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  String _selectedHari = 'Senin';
  String _searchQuery = '';
  late AnimationController _fabAnim;
  final _searchController = TextEditingController();
  late List<_JadwalItem> _jadwalList;
  int _nextId = 16;

  final _hariOptions = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  @override
  void initState() {
    super.initState();
    _jadwalList = List.from(_dummyJadwal);
    // TODO: _loadJadwal() untuk fetch dari API
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  void _tambahJadwal(_JadwalItem item) {
    setState(() => _jadwalList.add(item.copyWith(id: '${_nextId++}')));
    // TODO: POST http://your-api/jadwal
  }
  void _editJadwal(_JadwalItem item) {
    setState(() {
      final idx = _jadwalList.indexWhere((j) => j.id == item.id);
      if (idx != -1) _jadwalList[idx] = item;
    });
    // TODO: PUT http://your-api/jadwal/{id}
  }
  void _hapusJadwal(String id) {
    setState(() => _jadwalList.removeWhere((j) => j.id == id));
    // TODO: DELETE http://your-api/jadwal/{id}
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_JadwalItem> get _filtered {
    return _jadwalList.where((j) {
      final matchHari = j.hari == _selectedHari;
      final matchSearch = _searchQuery.isEmpty ||
          j.mapel.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.guru.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.kelas.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          j.ruang.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchHari && matchSearch;
    }).toList()
      ..sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
  }

  // Total jadwal semua hari
  int get _totalJadwal => _jadwalList.length;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final filtered = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _C.surface,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Sticky AppBar ──
                _StickyAppBar(onBack: () => Navigator.pop(context)),

                // ── Stats Card ──
                _StatsCard(
                  totalJadwal: _totalJadwal,
                  totalHari: _hariOptions.length,
                  totalMapel: _jadwalList.map((j) => j.kode).toSet().length,
                ),

                // ── Search Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Container(
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
                          hintText: 'Cari mata pelajaran, guru, kelas...',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 13, color: _C.border),
                          prefixIcon: Icon(Icons.search_rounded,
                              color: _C.subtle, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.close_rounded,
                                      color: _C.subtle, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Hari Selector ──
                SliverToBoxAdapter(
                  child: Container(
                    color: _C.card,
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Hari',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(_hariOptions.length, (i) {
                            final hari = _hariOptions[i];
                            final isSelected = hari == _selectedHari;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectedHari = hari),
                                behavior: HitTestBehavior.opaque,
                                child: Column(
                                  children: [
                                    Text(
                                      // Singkat: 3 huruf pertama
                                      hari.substring(0, 3),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? _C.primary
                                            : Colors.grey.shade500,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? _C.primary
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Hasil Count ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 3,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _C.primary,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${filtered.length} jadwal pada hari $_selectedHari',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _C.subtle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── List Jadwal ──
                if (filtered.isEmpty)
                  SliverToBoxAdapter(child: _EmptyState(hari: _selectedHari))
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 110 + bottomPad),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filtered[index];
                          return _JadwalCard(
                            item: item,
                            isLast: index == filtered.length - 1,
                            onTap: () => _showDetailSheet(context, item),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),

            // ── FAB ──
            Positioned(
              bottom: 100 + bottomPad,
              right: 20,
              child: ScaleTransition(
                scale: CurvedAnimation(
                    parent: _fabAnim, curve: Curves.elasticOut),
                child: FloatingActionButton.extended(
                  onPressed: () => _showForm(context, null),
                  backgroundColor: _C.primary,
                  elevation: 6,
                  label: Text(
                    'Tambah Jadwal',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),

            // ── Bottom Nav ──
            Align(
              alignment: Alignment.bottomCenter,
              child: SiakadBottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: (i) {
                  if (i == 1) {
                    Navigator.pop(context);
                  } else {
                    setState(() => _selectedIndex = i);
                  }
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, _JadwalItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DetailSheet(
        item: item,
        onEdit: () { Navigator.pop(context); _showForm(context, item); },
        onDelete: () {
          Navigator.pop(context);
          showDialog(context: context, builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Hapus Jadwal', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
            content: Text('Yakin ingin menghapus jadwal "${item.mapel}" hari ${item.hari}?', style: GoogleFonts.inter(fontSize: 14)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.inter(color: _C.subtle, fontWeight: FontWeight.w600))),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _hapusJadwal(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Jadwal ${item.mapel} berhasil dihapus', style: GoogleFonts.inter()),
                    backgroundColor: const Color(0xFFE11D48),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                child: Text('Hapus', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ));
        },
      ),
    );
  }

  void _showForm(BuildContext context, _JadwalItem? item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JadwalFormSheet(
        item: item,
        hariOptions: _hariOptions,
        onSave: (data) => item == null ? _tambahJadwal(data) : _editJadwal(data),
      ),
    );
  }
}

// ─── Sticky AppBar ────────────────────────────────────────────────────────────
class _StickyAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _StickyAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _AppBarDelegate(onBack: onBack, topPad: topPad),
    );
  }
}

class _AppBarDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onBack;
  final double topPad;
  const _AppBarDelegate({required this.onBack, required this.topPad});

  double get _h => topPad + 64;
  @override double get minExtent => _h;
  @override double get maxExtent => _h;
  @override bool shouldRebuild(covariant _AppBarDelegate old) =>
      old.topPad != topPad;

  @override
  Widget build(BuildContext ctx, double shrinkOffset, bool overlaps) {
    return Container(
      height: _h,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00274D), Color(0xFF0284C7)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, topPad + 4, 8, 0),
        child: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(99),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JADWAL PELAJARAN',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'MDT Assalam Al Barokah',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.ios_share_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final int totalJadwal;
  final int totalHari;
  final int totalMapel;

  const _StatsCard({
    required this.totalJadwal,
    required this.totalHari,
    required this.totalMapel,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _StatItem(
                icon: Icons.calendar_month_rounded,
                value: '$totalJadwal',
                label: 'Total Jadwal',
                color: _C.primary,
              ),
              _StatDivider(),
              _StatItem(
                icon: Icons.today_rounded,
                value: '$totalHari',
                label: 'Hari Aktif',
                color: const Color(0xFF0284C7),
              ),
              _StatDivider(),
              _StatItem(
                icon: Icons.menu_book_rounded,
                value: '$totalMapel',
                label: 'Mata Pelajaran',
                color: const Color(0xFFEA580C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _C.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: _C.subtle,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: _C.border.withOpacity(0.4));
  }
}

// ─── Jadwal Card ──────────────────────────────────────────────────────────────
class _JadwalCard extends StatelessWidget {
  final _JadwalItem item;
  final bool isLast;
  final VoidCallback onTap;

  const _JadwalCard({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Material(
        color: _C.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.border.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Warna aksen kiri ──
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: item.warna,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // ── Waktu ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.jamMulai,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _C.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                          width: 1, height: 16, color: _C.border),
                      const SizedBox(height: 2),
                      Text(
                        item.jamSelesai,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.subtle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // ── Divider vertikal ──
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                      width: 1, color: _C.border.withOpacity(0.5)),
                ),
                const SizedBox(width: 14),
                // ── Konten ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: item.warna.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(item.ikon,
                                  color: item.warna, size: 15),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.mapel,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _C.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person_rounded,
                                size: 12, color: _C.subtle),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.guru,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: _C.subtle,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.school_rounded,
                              label: item.kelas,
                              color: _C.primary,
                            ),
                            const SizedBox(width: 6),
                            _InfoChip(
                              icon: Icons.door_back_door_rounded,
                              label: item.ruang,
                              color: const Color(0xFF0284C7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Chevron ──
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(Icons.chevron_right_rounded,
                      color: _C.border, size: 20),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

// ─── Info Chip ────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String hari;
  const _EmptyState({required this.hari});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.event_busy_rounded,
            size: 72,
            color: _C.border,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.subtle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Belum ada jadwal untuk hari $hari',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _C.border,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final _JadwalItem item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _DetailSheet({required this.item, this.onEdit, this.onDelete});

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
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _C.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: item.warna.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: item.warna.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(item.ikon, color: item.warna, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.mapel,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _C.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _HariChip(hari: item.hari),
                          const SizedBox(width: 6),
                          _WaktuChip(
                              jam: '${item.jamMulai} – ${item.jamSelesai}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
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
                    icon: Icons.qr_code_rounded,
                    label: 'Kode Mapel',
                    value: item.kode),
                _DetailRow(
                    icon: Icons.person_rounded,
                    label: 'Guru Pengampu',
                    value: item.guru),
                _DetailRow(
                    icon: Icons.school_rounded,
                    label: 'Kelas',
                    value: item.kelas),
                _DetailRow(
                    icon: Icons.door_back_door_rounded,
                    label: 'Ruangan',
                    value: item.ruang),
                _DetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Waktu',
                    value: '${item.jamMulai} – ${item.jamSelesai} WIB'),
                _DetailRow(
                    icon: Icons.today_rounded,
                    label: 'Hari',
                    value: item.hari),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Tombol Aksi ──
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomPad),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE11D48)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.delete_rounded, size: 16, color: Color(0xFFE11D48)),
                    label: Text('Hapus', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFFE11D48))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.primary, elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                    label: Text('Edit Jadwal', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
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

// ─── Hari Chip ────────────────────────────────────────────────────────────────
class _HariChip extends StatelessWidget {
  final String hari;
  const _HariChip({required this.hari});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _C.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        hari,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _C.primary,
        ),
      ),
    );
  }
}

// ─── Waktu Chip ───────────────────────────────────────────────────────────────
class _WaktuChip extends StatelessWidget {
  final String jam;
  const _WaktuChip({required this.jam});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF0284C7).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        jam,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0284C7),
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
// ─── Form Bottom Sheet (Tambah & Edit) ────────────────────────────────────────
class _JadwalFormSheet extends StatefulWidget {
  final _JadwalItem? item;
  final List<String> hariOptions;
  final void Function(_JadwalItem) onSave;

  const _JadwalFormSheet({this.item, required this.hariOptions, required this.onSave});

  @override
  State<_JadwalFormSheet> createState() => _JadwalFormSheetState();
}

class _JadwalFormSheetState extends State<_JadwalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _mapel, _kode, _guru, _kelas, _ruang, _jamMulai, _jamSelesai;
  late String _hari;

  @override
  void initState() {
    super.initState();
    final j = widget.item;
    _mapel     = TextEditingController(text: j?.mapel ?? '');
    _kode      = TextEditingController(text: j?.kode ?? '');
    _guru      = TextEditingController(text: j?.guru ?? '');
    _kelas     = TextEditingController(text: j?.kelas ?? '');
    _ruang     = TextEditingController(text: j?.ruang ?? '');
    _jamMulai  = TextEditingController(text: j?.jamMulai ?? '');
    _jamSelesai = TextEditingController(text: j?.jamSelesai ?? '');
    _hari = j?.hari ?? widget.hariOptions.first;
  }

  @override
  void dispose() {
    _mapel.dispose(); _kode.dispose(); _guru.dispose();
    _kelas.dispose(); _ruang.dispose(); _jamMulai.dispose(); _jamSelesai.dispose();
    super.dispose();
  }

  Future<void> _pilihWaktu(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final init = TimeOfDay(
      hour: parts.length == 2 ? int.tryParse(parts[0]) ?? 7 : 7,
      minute: parts.length == 2 ? int.tryParse(parts[1]) ?? 0 : 0,
    );
    final picked = await showTimePicker(context: context, initialTime: init);
    if (picked != null) {
      ctrl.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    final result = _JadwalItem(
      id: widget.item?.id ?? '',
      mapel: _mapel.text.trim(),
      kode: _kode.text.trim(),
      guru: _guru.text.trim(),
      kelas: _kelas.text.trim(),
      ruang: _ruang.text.trim(),
      jamMulai: _jamMulai.text.trim(),
      jamSelesai: _jamSelesai.text.trim(),
      hari: _hari,
      warna: widget.item?.warna ?? const Color(0xFF004D34),
      ikon: widget.item?.ikon ?? Icons.menu_book_rounded,
    );
    Navigator.pop(context);
    widget.onSave(result);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.item == null ? 'Jadwal berhasil ditambahkan' : 'Jadwal berhasil diperbarui',
          style: GoogleFonts.inter()),
      backgroundColor: _C.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom;
    final isEdit = widget.item != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: const BoxDecoration(color: _C.card, borderRadius: BorderRadius.all(Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad + 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Handle
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 16),

            // Judul
            Row(children: [
              Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: _C.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(isEdit ? Icons.edit_rounded : Icons.add_rounded, color: _C.primary, size: 20)),
              const SizedBox(width: 12),
              Text(isEdit ? 'Edit Jadwal' : 'Tambah Jadwal Baru',
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: _C.onSurface)),
            ]),
            const SizedBox(height: 24),

            _JFormField(controller: _mapel, label: 'Mata Pelajaran', icon: Icons.menu_book_rounded,
                validator: (v) => v!.isEmpty ? 'Mata pelajaran tidak boleh kosong' : null),
            _JFormField(controller: _kode, label: 'Kode Mapel', icon: Icons.qr_code_rounded,
                readOnly: isEdit,
                validator: (v) => v!.isEmpty ? 'Kode tidak boleh kosong' : null),
            _JFormField(controller: _guru, label: 'Guru Pengampu', icon: Icons.person_rounded,
                validator: (v) => v!.isEmpty ? 'Guru tidak boleh kosong' : null),
            _JFormField(controller: _kelas, label: 'Kelas', icon: Icons.school_rounded,
                validator: (v) => v!.isEmpty ? 'Kelas tidak boleh kosong' : null),
            _JFormField(controller: _ruang, label: 'Ruangan', icon: Icons.door_back_door_rounded,
                validator: (v) => v!.isEmpty ? 'Ruangan tidak boleh kosong' : null),

            // Jam Mulai & Selesai — pakai time picker
            Row(children: [
              Expanded(
                child: _JFormField(
                  controller: _jamMulai, label: 'Jam Mulai', icon: Icons.access_time_rounded,
                  readOnly: true,
                  onTap: () => _pilihWaktu(_jamMulai),
                  validator: (v) => v!.isEmpty ? 'Jam mulai wajib diisi' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _JFormField(
                  controller: _jamSelesai, label: 'Jam Selesai', icon: Icons.access_time_filled_rounded,
                  readOnly: true,
                  onTap: () => _pilihWaktu(_jamSelesai),
                  validator: (v) => v!.isEmpty ? 'Jam selesai wajib diisi' : null,
                ),
              ),
            ]),
            const SizedBox(height: 4),

            // Hari dropdown
            DropdownButtonFormField<String>(
              value: _hari,
              onChanged: (v) => setState(() => _hari = v!),
              style: GoogleFonts.inter(fontSize: 14, color: _C.onSurface),
              decoration: InputDecoration(
                labelText: 'Hari',
                labelStyle: GoogleFonts.inter(fontSize: 13, color: _C.subtle),
                prefixIcon: const Icon(Icons.today_rounded, size: 18, color: _C.primary),
                filled: true, fillColor: _C.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _C.border.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _C.border.withOpacity(0.5))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _C.primary, width: 1.5)),
              ),
              items: widget.hariOptions.map((h) => DropdownMenuItem(
                value: h, child: Text(h, style: GoogleFonts.inter(fontSize: 14)),
              )).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(backgroundColor: _C.primary, elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded, color: Colors.white, size: 18),
                label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Jadwal',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _JFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const _JFormField({
    required this.controller, required this.label, required this.icon,
    this.validator, this.maxLines = 1, this.keyboardType = TextInputType.text,
    this.readOnly = false, this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller, validator: validator,
        maxLines: maxLines, keyboardType: keyboardType,
        readOnly: readOnly, onTap: onTap,
        style: GoogleFonts.inter(fontSize: 14, color: readOnly && onTap == null ? _C.subtle : _C.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13, color: _C.subtle),
          prefixIcon: Icon(icon, size: 18, color: readOnly && onTap == null ? _C.border : _C.primary),
          suffixIcon: readOnly && onTap == null ? const Icon(Icons.lock_rounded, size: 16, color: _C.border) : null,
          filled: true, fillColor: readOnly && onTap == null ? _C.chip : _C.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _C.border.withOpacity(0.5))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _C.border.withOpacity(0.5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: readOnly && onTap == null ? _C.border : _C.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE11D48))),
        ),
      ),
    );
  }
}