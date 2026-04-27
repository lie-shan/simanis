import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';
import 'presensi_page.dart';

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
class _Mapel {
  final String id;
  final String nama;
  final String kode;
  final String kategori;
  final String pengampu;
  final int jplPerMinggu;
  final String kelas;
  final String deskripsi;
  final Color warna;
  final IconData ikon;

  const _Mapel({
    required this.id,
    required this.nama,
    required this.kode,
    required this.kategori,
    required this.pengampu,
    required this.jplPerMinggu,
    required this.kelas,
    required this.deskripsi,
    required this.warna,
    required this.ikon,
  });

  _Mapel copyWith({
    String? id, String? nama, String? kode, String? kategori,
    String? pengampu, int? jplPerMinggu, String? kelas,
    String? deskripsi, Color? warna, IconData? ikon,
  }) => _Mapel(
    id: id ?? this.id, nama: nama ?? this.nama, kode: kode ?? this.kode,
    kategori: kategori ?? this.kategori, pengampu: pengampu ?? this.pengampu,
    jplPerMinggu: jplPerMinggu ?? this.jplPerMinggu, kelas: kelas ?? this.kelas,
    deskripsi: deskripsi ?? this.deskripsi, warna: warna ?? this.warna, ikon: ikon ?? this.ikon,
  );
  // TODO: factory _Mapel.fromJson / toJson untuk API
}

final _dummyMapel = [
  _Mapel(
    id: '1',
    nama: "Al-Qur'an & Tajwid",
    kode: 'QT-01',
    kategori: 'Inti',
    pengampu: 'H. Mochammad Soleh, S.Pd',
    jplPerMinggu: 4,
    kelas: 'Semua Kelas',
    deskripsi: 'Pembelajaran membaca dan memahami Al-Qur\'an dengan kaidah tajwid yang benar.',
    warna: Color(0xFF059669),
    ikon: Icons.auto_stories_rounded,
  ),
  _Mapel(
    id: '2',
    nama: 'Fiqih & Ibadah',
    kode: 'FI-02',
    kategori: 'Inti',
    pengampu: 'Ustadzah Nurul Hidayah, S.Ag',
    jplPerMinggu: 3,
    kelas: 'Kelas 1, 2, 3',
    deskripsi: 'Mempelajari hukum-hukum Islam dan tata cara pelaksanaan ibadah sehari-hari.',
    warna: Color(0xFF0284C7),
    ikon: Icons.mosque_rounded,
  ),
  _Mapel(
    id: '3',
    nama: 'Hadits & Sirah',
    kode: 'HS-03',
    kategori: 'Inti',
    pengampu: 'Ustadz Ikhwan Fauzi, S.Pd.I',
    jplPerMinggu: 2,
    kelas: 'Kelas 2, 3',
    deskripsi: 'Pembelajaran hadits-hadits pilihan dan sejarah perjalanan hidup Nabi Muhammad SAW.',
    warna: Color(0xFF7C3AED),
    ikon: Icons.history_edu_rounded,
  ),
  _Mapel(
    id: '4',
    nama: 'Akhlak & Tasawuf',
    kode: 'AT-04',
    kategori: 'Inti',
    pengampu: 'Siti Rohmah, S.Ag',
    jplPerMinggu: 2,
    kelas: 'Semua Kelas',
    deskripsi: 'Pembentukan karakter mulia dan pengenalan nilai-nilai tasawuf dalam kehidupan.',
    warna: Color(0xFFDB2777),
    ikon: Icons.favorite_rounded,
  ),
  _Mapel(
    id: '5',
    nama: 'Bahasa Arab',
    kode: 'BA-05',
    kategori: 'Pendukung',
    pengampu: 'Abdurrahman Wahid, Lc',
    jplPerMinggu: 3,
    kelas: 'Semua Kelas',
    deskripsi: 'Penguasaan keterampilan berbahasa Arab sebagai alat memahami sumber-sumber Islam.',
    warna: Color(0xFFEA580C),
    ikon: Icons.translate_rounded,
  ),
  _Mapel(
    id: '6',
    nama: 'Nahwu & Sharaf',
    kode: 'NS-06',
    kategori: 'Pendukung',
    pengampu: 'Hj. Fatimah Az-Zahra, S.Pd',
    jplPerMinggu: 2,
    kelas: 'Kelas 2, 3',
    deskripsi: 'Ilmu tata bahasa Arab yang menjadi pondasi dalam membaca kitab-kitab klasik.',
    warna: Color(0xFF0D9488),
    ikon: Icons.spellcheck_rounded,
  ),
  _Mapel(
    id: '7',
    nama: 'Tahfidz Al-Qur\'an',
    kode: 'TQ-07',
    kategori: 'Inti',
    pengampu: 'Muhammad Rizal, S.Pd.I',
    jplPerMinggu: 5,
    kelas: 'Semua Kelas',
    deskripsi: 'Program hafalan Al-Qur\'an secara bertahap dengan metode yang terstruktur.',
    warna: Color(0xFF065F46),
    ikon: Icons.menu_book_rounded,
  ),
  _Mapel(
    id: '8',
    nama: 'Aqidah & Tauhid',
    kode: 'AQ-08',
    kategori: 'Inti',
    pengampu: 'Dewi Rahmawati, S.Ag',
    jplPerMinggu: 2,
    kelas: 'Kelas 1, 2',
    deskripsi: 'Pemantapan keyakinan terhadap Allah SWT dan rukun-rukun iman.',
    warna: Color(0xFF9333EA),
    ikon: Icons.lightbulb_rounded,
  ),
  _Mapel(
    id: '9',
    nama: 'Sejarah Islam',
    kode: 'SI-09',
    kategori: 'Muatan Lokal',
    pengampu: 'Ustadz Zainul Arifin, S.Pd',
    jplPerMinggu: 2,
    kelas: 'Kelas 3',
    deskripsi: 'Menelaah peristiwa-peristiwa penting dalam sejarah peradaban Islam.',
    warna: Color(0xFF92400E),
    ikon: Icons.public_rounded,
  ),
];

// ─── Halaman Utama ────────────────────────────────────────────────────────────
class MapelPage extends StatefulWidget {
  const MapelPage({super.key});

  @override
  State<MapelPage> createState() => _MapelPageState();
}

class _MapelPageState extends State<MapelPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  String _searchQuery = '';
  String _filterKategori = 'Semua';
  bool _isGridView = false;
  late AnimationController _fabAnim;
  final _searchController = TextEditingController();
  late List<_Mapel> _mapelList;
  int _nextId = 10;

  final _kategoriOptions = ['Semua', 'Inti', 'Pendukung', 'Muatan Lokal'];

  @override
  void initState() {
    super.initState();
    _mapelList = List.from(_dummyMapel);
    // TODO: _loadMapel() untuk fetch dari API
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  void _tambahMapel(_Mapel m) {
    setState(() => _mapelList.add(m.copyWith(id: '${_nextId++}')));
    // TODO: POST http://your-api/mapel
  }
  void _editMapel(_Mapel m) {
    setState(() {
      final idx = _mapelList.indexWhere((e) => e.id == m.id);
      if (idx != -1) _mapelList[idx] = m;
    });
    // TODO: PUT http://your-api/mapel/{id}
  }
  void _hapusMapel(String id) {
    setState(() => _mapelList.removeWhere((e) => e.id == id));
    // TODO: DELETE http://your-api/mapel/{id}
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_Mapel> get _filtered {
    return _mapelList.where((m) {
      final matchSearch =
          m.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.kode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.pengampu.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchKategori =
          _filterKategori == 'Semua' || m.kategori == _filterKategori;
      return matchSearch && matchKategori;
    }).toList();
  }

  // Total JPL per minggu semua mapel
  int get _totalJpl =>
      _mapelList.fold(0, (sum, m) => sum + m.jplPerMinggu);

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
        body: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Sticky AppBar ──
                _StickyAppBar(onBack: () => Navigator.pop(context)),

                // ── Stats Card ──
                _StatsCard(
                  totalMapel: _mapelList.length,
                  totalJpl: _totalJpl,
                  totalKategori: _kategoriOptions.length - 1,
                ),

                // ── Search & Filter ──
                SliverToBoxAdapter(
                  child: _SearchFilterBar(
                    controller: _searchController,
                    onSearch: (v) => setState(() => _searchQuery = v),
                    selectedKategori: _filterKategori,
                    kategoriOptions: _kategoriOptions,
                    onKategoriChanged: (v) =>
                        setState(() => _filterKategori = v),
                    isGrid: _isGridView,
                    onToggleView: () =>
                        setState(() => _isGridView = !_isGridView),
                  ),
                ),

                // ── Hasil Count ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      '${filtered.length} mata pelajaran ditemukan',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _C.subtle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // ── List / Grid ──
                if (filtered.isEmpty)
                  const SliverFillRemaining(child: _EmptyState())
                else if (_isGridView)
                  SliverPadding(
                    padding:
                        EdgeInsets.fromLTRB(16, 0, 16, 110 + bottomPad),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _MapelGridCard(
                          mapel: filtered[i],
                          onTap: () =>
                              _showDetail(context, filtered[i]),
                        ),
                        childCount: filtered.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.88,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding:
                        EdgeInsets.fromLTRB(16, 0, 16, 110 + bottomPad),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => _MapelListCard(
                          mapel: filtered[i],
                          onTap: () =>
                              _showDetail(context, filtered[i]),
                        ),
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
                    'Tambah Mapel',
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
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, a, __) => const PresensiPage(),
                        transitionsBuilder: (_, a, __, child) =>
                            FadeTransition(opacity: a, child: child),
                        transitionDuration:
                            const Duration(milliseconds: 250),
                      ),
                    );
                  } else if (i == 0) {
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
    );
  }

  void _showDetail(BuildContext context, _Mapel mapel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        mapel: mapel,
        onEdit: () { Navigator.pop(context); _showForm(context, mapel); },
        onDelete: () {
          Navigator.pop(context);
          showDialog(context: context, builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Hapus Mapel', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
            content: Text('Yakin ingin menghapus "${mapel.nama}"?', style: GoogleFonts.inter(fontSize: 14)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: Text('Batal', style: GoogleFonts.inter(color: _C.subtle, fontWeight: FontWeight.w600))),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _hapusMapel(mapel.id);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${mapel.nama} berhasil dihapus', style: GoogleFonts.inter()),
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

  void _showForm(BuildContext context, _Mapel? mapel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MapelFormSheet(
        mapel: mapel,
        kategoriOptions: _kategoriOptions.where((k) => k != 'Semua').toList(),
        onSave: (data) => mapel == null ? _tambahMapel(data) : _editMapel(data),
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
          colors: [Color(0xFF3B1200), Color(0xFFEA580C)],
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
                    'MATA PELAJARAN',
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
  final int totalMapel, totalJpl, totalKategori;
  const _StatsCard({
    required this.totalMapel,
    required this.totalJpl,
    required this.totalKategori,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B1200), Color(0xFFEA580C)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          child: Row(
            children: [
              _StatPill(
                label: 'Total JPL',
                value: '$totalJpl',
                icon: Icons.schedule_rounded,
                accentColor: const Color(0xFF60A5FA),
              ),
              const SizedBox(width: 10),
              _StatPill(
                label: 'Kategori',
                value: '$totalKategori',
                icon: Icons.category_rounded,
                accentColor: const Color(0xFFF9A8D4),
              ),
              const SizedBox(width: 10),
              _StatPill(
                label: 'Mapel',
                value: '$totalMapel',
                icon: Icons.menu_book_rounded,
                highlight: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool highlight;
  final Color? accentColor;
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        highlight ? _C.gold : (accentColor ?? Colors.white.withOpacity(0.7));
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: highlight
              ? const Color(0xFFE9C349).withOpacity(0.18)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: highlight
                ? const Color(0xFFE9C349).withOpacity(0.4)
                : (accentColor?.withOpacity(0.25) ??
                    Colors.white.withOpacity(0.1)),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Search & Filter Bar ──────────────────────────────────────────────────────
class _SearchFilterBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final String selectedKategori;
  final List<String> kategoriOptions;
  final ValueChanged<String> onKategoriChanged;
  final bool isGrid;
  final VoidCallback onToggleView;

  const _SearchFilterBar({
    required this.controller,
    required this.onSearch,
    required this.selectedKategori,
    required this.kategoriOptions,
    required this.onKategoriChanged,
    required this.isGrid,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _C.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          // Search field
          Container(
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
              controller: controller,
              onChanged: onSearch,
              style: GoogleFonts.inter(fontSize: 14, color: _C.onSurface),
              decoration: InputDecoration(
                hintText: 'Cari nama mapel, kode, atau pengampu...',
                hintStyle:
                    GoogleFonts.inter(fontSize: 14, color: _C.border),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: _C.subtle, size: 20),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: _C.subtle),
                        onPressed: () {
                          controller.clear();
                          onSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter row
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: kategoriOptions.map((opt) {
                      final isActive = selectedKategori == opt;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => onKategoriChanged(opt),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFEA580C)
                                  : _C.chip,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFFEA580C)
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              opt,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    isActive ? Colors.white : _C.subtle,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onToggleView,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isGrid ? const Color(0xFFEA580C) : _C.chip,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isGrid
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                    color: isGrid ? Colors.white : _C.subtle,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Mapel List Card ──────────────────────────────────────────────────────────
class _MapelListCard extends StatelessWidget {
  final _Mapel mapel;
  final VoidCallback onTap;
  const _MapelListCard({required this.mapel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Ikon mapel
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: mapel.warna.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: mapel.warna.withOpacity(0.25), width: 1.5),
                  ),
                  child:
                      Icon(mapel.ikon, color: mapel.warna, size: 26),
                ),
                const SizedBox(width: 14),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mapel.nama,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _C.onSurface,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        mapel.pengampu,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _C.subtle,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _KategoriChip(kategori: mapel.kategori),
                          const SizedBox(width: 8),
                          _JplChip(jpl: mapel.jplPerMinggu),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Kode & chevron
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: mapel.warna.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        mapel.kode,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: mapel.warna,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Icon(Icons.chevron_right_rounded,
                        color: _C.border, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Mapel Grid Card ──────────────────────────────────────────────────────────
class _MapelGridCard extends StatelessWidget {
  final _Mapel mapel;
  final VoidCallback onTap;
  const _MapelGridCard({required this.mapel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              // Header berwarna
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: mapel.warna.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: mapel.warna.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: mapel.warna.withOpacity(0.3), width: 2),
                      ),
                      child: Icon(mapel.ikon,
                          color: mapel.warna, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: mapel.warna.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        mapel.kode,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: mapel.warna,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mapel.nama,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.onSurface,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          _KategoriChip(
                              kategori: mapel.kategori, small: true),
                          const Spacer(),
                          _JplChip(
                              jpl: mapel.jplPerMinggu, small: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Small Chips ─────────────────────────────────────────────────────────────
class _KategoriChip extends StatelessWidget {
  final String kategori;
  final bool small;
  const _KategoriChip({required this.kategori, this.small = false});

  Color get _color {
    switch (kategori) {
      case 'Inti':        return const Color(0xFF065F46);
      case 'Pendukung':   return const Color(0xFF0284C7);
      case 'Muatan Lokal': return const Color(0xFF7C3AED);
      default:            return _C.subtle;
    }
  }

  Color get _bg {
    switch (kategori) {
      case 'Inti':        return const Color(0xFFD1FAE5);
      case 'Pendukung':   return const Color(0xFFE0F2FE);
      case 'Muatan Lokal': return const Color(0xFFF5F3FF);
      default:            return _C.chip;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        kategori,
        style: GoogleFonts.inter(
          fontSize: small ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}

class _JplChip extends StatelessWidget {
  final int jpl;
  final bool small;
  const _JplChip({required this.jpl, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8, vertical: small ? 2 : 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: const Color(0xFFEA580C).withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded,
              size: small ? 9 : 10,
              color: const Color(0xFFEA580C)),
          const SizedBox(width: 3),
          Text(
            '$jpl JPL',
            style: GoogleFonts.inter(
              fontSize: small ? 9 : 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEA580C),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _C.chip,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: _C.border, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Mapel tidak ditemukan',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba ubah kata kunci atau filter pencarian',
            style: GoogleFonts.inter(fontSize: 13, color: _C.subtle),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final _Mapel mapel;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const _DetailSheet({required this.mapel, this.onEdit, this.onDelete});

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
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _C.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),

          // Header mapel
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: mapel.warna.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: mapel.warna.withOpacity(0.3), width: 2),
                  ),
                  child: Icon(mapel.ikon, color: mapel.warna, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mapel.nama,
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
                          _KategoriChip(kategori: mapel.kategori),
                          const SizedBox(width: 8),
                          _JplChip(jpl: mapel.jplPerMinggu),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Deskripsi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: mapel.warna.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: mapel.warna.withOpacity(0.15)),
              ),
              child: Text(
                mapel.deskripsi,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _C.subtle,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Divider(height: 1, color: _C.border.withOpacity(0.4)),
          const SizedBox(height: 16),

          // Detail rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.qr_code_rounded,
                    label: 'Kode Mapel',
                    value: mapel.kode),
                _DetailRow(
                    icon: Icons.person_rounded,
                    label: 'Guru Pengampu',
                    value: mapel.pengampu),
                _DetailRow(
                    icon: Icons.school_rounded,
                    label: 'Kelas',
                    value: mapel.kelas),
                _DetailRow(
                    icon: Icons.schedule_rounded,
                    label: 'JPL per Minggu',
                    value: '${mapel.jplPerMinggu} jam pelajaran'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tombol aksi
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
                      backgroundColor: const Color(0xFFEA580C), elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                    label: Text('Edit Data', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
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
                Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _C.subtle,
                      letterSpacing: 0.3,
                    )),
                Text(value,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.onSurface,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Bottom Sheet (Tambah & Edit) ────────────────────────────────────────
class _MapelFormSheet extends StatefulWidget {
  final _Mapel? mapel;
  final List<String> kategoriOptions;
  final void Function(_Mapel) onSave;

  const _MapelFormSheet({this.mapel, required this.kategoriOptions, required this.onSave});

  @override
  State<_MapelFormSheet> createState() => _MapelFormSheetState();
}

class _MapelFormSheetState extends State<_MapelFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nama, _kode, _pengampu, _kelas, _deskripsi, _jpl;
  late String _kategori;

  @override
  void initState() {
    super.initState();
    final m = widget.mapel;
    _nama      = TextEditingController(text: m?.nama ?? '');
    _kode      = TextEditingController(text: m?.kode ?? '');
    _pengampu  = TextEditingController(text: m?.pengampu ?? '');
    _kelas     = TextEditingController(text: m?.kelas ?? '');
    _deskripsi = TextEditingController(text: m?.deskripsi ?? '');
    _jpl       = TextEditingController(text: m != null ? '${m.jplPerMinggu}' : '');
    _kategori  = m?.kategori ?? widget.kategoriOptions.first;
  }

  @override
  void dispose() {
    _nama.dispose(); _kode.dispose(); _pengampu.dispose();
    _kelas.dispose(); _deskripsi.dispose(); _jpl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    final result = _Mapel(
      id: widget.mapel?.id ?? '',
      nama: _nama.text.trim(),
      kode: _kode.text.trim(),
      kategori: _kategori,
      pengampu: _pengampu.text.trim(),
      jplPerMinggu: int.tryParse(_jpl.text) ?? 0,
      kelas: _kelas.text.trim(),
      deskripsi: _deskripsi.text.trim(),
      warna: widget.mapel?.warna ?? const Color(0xFF004D34),
      ikon: widget.mapel?.ikon ?? Icons.menu_book_rounded,
    );
    Navigator.pop(context);
    widget.onSave(result);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.mapel == null ? 'Mapel berhasil ditambahkan' : 'Data berhasil diperbarui',
          style: GoogleFonts.inter()),
      backgroundColor: const Color(0xFFEA580C),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).viewPadding.bottom;
    final isEdit = widget.mapel != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: const BoxDecoration(color: _C.card, borderRadius: BorderRadius.all(Radius.circular(24))),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad + 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: _C.border, borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 16),
            Row(children: [
              Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFEA580C).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(isEdit ? Icons.edit_rounded : Icons.add_rounded, color: const Color(0xFFEA580C), size: 20)),
              const SizedBox(width: 12),
              Text(isEdit ? 'Edit Mata Pelajaran' : 'Tambah Mata Pelajaran',
                  style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: _C.onSurface)),
            ]),
            const SizedBox(height: 24),

            _MFormField(controller: _nama, label: 'Nama Mapel', icon: Icons.menu_book_rounded,
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null),
            _MFormField(controller: _kode, label: 'Kode Mapel', icon: Icons.qr_code_rounded,
                readOnly: isEdit,
                validator: (v) => v!.isEmpty ? 'Kode tidak boleh kosong' : null),
            _MFormField(controller: _pengampu, label: 'Guru Pengampu', icon: Icons.person_rounded,
                validator: (v) => v!.isEmpty ? 'Pengampu tidak boleh kosong' : null),
            _MFormField(controller: _kelas, label: 'Kelas', icon: Icons.class_rounded,
                validator: (v) => v!.isEmpty ? 'Kelas tidak boleh kosong' : null),
            _MFormField(controller: _jpl, label: 'JPL per Minggu', icon: Icons.schedule_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'JPL tidak boleh kosong';
                  if (int.tryParse(v) == null) return 'Masukkan angka yang valid';
                  return null;
                }),
            _MFormField(controller: _deskripsi, label: 'Deskripsi', icon: Icons.description_rounded,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null),

            DropdownButtonFormField<String>(
              value: _kategori,
              onChanged: (v) => setState(() => _kategori = v!),
              style: GoogleFonts.inter(fontSize: 14, color: _C.onSurface),
              decoration: InputDecoration(
                labelText: 'Kategori',
                labelStyle: GoogleFonts.inter(fontSize: 13, color: _C.subtle),
                prefixIcon: const Icon(Icons.category_rounded, size: 18, color: Color(0xFFEA580C)),
                filled: true, fillColor: _C.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _C.border.withOpacity(0.5))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _C.border.withOpacity(0.5))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEA580C), width: 1.5)),
              ),
              items: widget.kategoriOptions.map((k) => DropdownMenuItem(
                value: k, child: Text(k, style: GoogleFonts.inter(fontSize: 14)),
              )).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA580C), elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                icon: Icon(isEdit ? Icons.save_rounded : Icons.add_rounded, color: Colors.white, size: 18),
                label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Mapel',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _MFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final bool readOnly;

  const _MFormField({
    required this.controller, required this.label, required this.icon,
    this.validator, this.maxLines = 1, this.keyboardType = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller, validator: validator,
        maxLines: maxLines, keyboardType: keyboardType, readOnly: readOnly,
        style: GoogleFonts.inter(fontSize: 14, color: readOnly ? _C.subtle : _C.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 13, color: _C.subtle),
          prefixIcon: Icon(icon, size: 18, color: readOnly ? _C.border : const Color(0xFFEA580C)),
          suffixIcon: readOnly ? const Icon(Icons.lock_rounded, size: 16, color: _C.border) : null,
          filled: true, fillColor: readOnly ? _C.chip : _C.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _C.border.withOpacity(0.5))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _C.border.withOpacity(0.5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: readOnly ? _C.border : const Color(0xFFEA580C), width: readOnly ? 1 : 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE11D48))),
        ),
      ),
    );
  }
}