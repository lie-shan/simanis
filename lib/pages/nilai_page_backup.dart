import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _PNC {
  static const primary = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
  static const amber = Color(0xFFD97706);
  static const amberLight = Color(0xFFFFFBEB);
  static const amberBorder = Color(0xFFFDE68A);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF0F2F1);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline = Color(0xFF6F7A72);
  static const outlineVariant = Color(0xFFBEC9C1);
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _SiswaData {
  final String nama;
  final String nis;
  final String? avatarUrl;
  final String kelas;
  final double nilaiHarian;
  final double nilaiUTS;
  final double nilaiUAS;

  const _SiswaData({
    required this.nama,
    required this.nis,
    this.avatarUrl,
    required this.kelas,
    required this.nilaiHarian,
    required this.nilaiUTS,
    required this.nilaiUAS,
  });

  double get nilaiAkhir =>
      (nilaiHarian * 0.4) + (nilaiUTS * 0.3) + (nilaiUAS * 0.3);

  String get grade {
    if (nilaiAkhir >= 90) return 'A';
    if (nilaiAkhir >= 80) return 'B';
    if (nilaiAkhir >= 70) return 'C';
    if (nilaiAkhir >= 60) return 'D';
    return 'E';
  }

  Color get gradeColor {
    if (nilaiAkhir >= 90) return const Color(0xFF065F46);
    if (nilaiAkhir >= 80) return const Color(0xFF1E40AF);
    if (nilaiAkhir >= 70) return const Color(0xFF92400E);
    if (nilaiAkhir >= 60) return const Color(0xFF7E22CE);
    return const Color(0xFF991B1B);
  }

  Color get gradeBg {
    if (nilaiAkhir >= 90) return const Color(0xFFD1FAE5);
    if (nilaiAkhir >= 80) return const Color(0xFFDBEAFE);
    if (nilaiAkhir >= 70) return const Color(0xFFFEF3C7);
    if (nilaiAkhir >= 60) return const Color(0xFFF3E8FF);
    return const Color(0xFFFEE2E2);
  }
}

// ─── Halaman Nilai Presensi ───────────────────────────────────────────────────
class PresensiNilaiPage extends StatefulWidget {
  const PresensiNilaiPage({super.key});

  @override
  State<PresensiNilaiPage> createState() => _PresensiNilaiPageState();
}

class _PresensiNilaiPageState extends State<PresensiNilaiPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;
  String _searchQuery = '';
  String? _selectedKelas;
  String? _sortBy = 'Nama';
  bool _sortAsc = true;

  final _searchCtrl = TextEditingController();

  final List<String> _kelasList = [
    'Semua Kelas',
    'VII-A',
    'VII-B',
    'VIII-A',
    'VIII-B',
    'IX-A',
    'IX-B',
  ];

  final List<String> _sortOptions = ['Nama', 'Nilai Akhir', 'Grade'];

  final List<Map<String, dynamic>> _mapelList = [
    {'label': 'Fiqih Ibadah', 'guru': 'Ust. Ahmad Fathoni, S.Pd'},
    {'label': 'Bahasa Arab Dasar', 'guru': 'Ustadzah Siti Aminah, S.Pd.I'},
    {'label': "Tahfidz Al-Qur'an", 'guru': 'Ust. Hafidz Mubarok, Lc'},
    {'label': 'Matematika', 'guru': 'Bu Dewi Rahmawati, S.Pd'},
    {'label': 'Bahasa Indonesia', 'guru': 'Pak Budi Santoso, M.Pd'},
  ];

  final List<_SiswaData> _allSiswa = const [
    _SiswaData(
        nama: 'Ahmad Fauzi',
        nis: '20230001',
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
        kelas: 'VII-A',
        nilaiHarian: 88,
        nilaiUTS: 82,
        nilaiUAS: 90),
    _SiswaData(
        nama: 'Aisyah Putri',
        nis: '20230002',
        avatarUrl: 'https://i.pravatar.cc/150?img=5',
        kelas: 'VII-A',
        nilaiHarian: 92,
        nilaiUTS: 88,
        nilaiUAS: 94),
    _SiswaData(
        nama: 'Budi Santoso',
        nis: '20230003',
        kelas: 'VII-B',
        nilaiHarian: 75,
        nilaiUTS: 68,
        nilaiUAS: 72),
    _SiswaData(
        nama: 'Dewi Rahmawati',
        nis: '20230004',
        kelas: 'VII-B',
        nilaiHarian: 80,
        nilaiUTS: 76,
        nilaiUAS: 84),
    _SiswaData(
        nama: 'Farhan Maulana',
        nis: '20230005',
        avatarUrl: 'https://i.pravatar.cc/150?img=8',
        kelas: 'VIII-A',
        nilaiHarian: 95,
        nilaiUTS: 91,
        nilaiUAS: 97),
    _SiswaData(
        nama: 'Gita Permatasari',
        nis: '20230006',
        avatarUrl: 'https://i.pravatar.cc/150?img=9',
        kelas: 'VIII-A',
        nilaiHarian: 70,
        nilaiUTS: 65,
        nilaiUAS: 68),
    _SiswaData(
        nama: 'Hendra Kusuma',
        nis: '20230007',
        kelas: 'VIII-B',
        nilaiHarian: 85,
        nilaiUTS: 80,
        nilaiUAS: 88),
    _SiswaData(
        nama: 'Indah Sari',
        nis: '20230008',
        avatarUrl: 'https://i.pravatar.cc/150?img=4',
        kelas: 'IX-A',
        nilaiHarian: 60,
        nilaiUTS: 55,
        nilaiUAS: 62),
    _SiswaData(
        nama: 'Joko Widodo',
        nis: '20230009',
        kelas: 'IX-A',
        nilaiHarian: 78,
        nilaiUTS: 74,
        nilaiUAS: 80),
    _SiswaData(
        nama: 'Kartika Dewi',
        nis: '20230010',
        avatarUrl: 'https://i.pravatar.cc/150?img=7',
        kelas: 'IX-B',
        nilaiHarian: 93,
        nilaiUTS: 90,
        nilaiUAS: 95),
  ];

  List<_SiswaData> get _filteredSiswa {
    List<_SiswaData> result = List.from(_allSiswa);

    // Filter kelas
    if (_selectedKelas != null && _selectedKelas != 'Semua Kelas') {
      result = result.where((s) => s.kelas == _selectedKelas).toList();
    }

    // Filter search
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((s) =>
              s.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.nis.contains(_searchQuery))
          .toList();
    }

    // Sort
    result.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'Nilai Akhir':
          cmp = a.nilaiAkhir.compareTo(b.nilaiAkhir);
          break;
        case 'Grade':
          cmp = a.grade.compareTo(b.grade);
          break;
        default:
          cmp = a.nama.compareTo(b.nama);
      }
      return _sortAsc ? cmp : -cmp;
    });

    return result;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _mapelList.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _PNC.surface,
        body: Column(
          children: [
            _buildHeader(),
            _buildSearchFilter(),
            _buildTabBar(),
            Expanded(child: _buildContent()),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showInputBottomSheet(context),
          backgroundColor: _PNC.amber,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: Text(
            'Input Nilai',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final siswa = _filteredSiswa;
    final avg = siswa.isEmpty
        ? 0.0
        : siswa.fold(0.0, (s, e) => s + e.nilaiAkhir) / siswa.length;
    final lulus = siswa.where((s) => s.nilaiAkhir >= 70).length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB45309), Color(0xFFD97706), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Nilai Siswa',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // Export button
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Mengekspor data nilai...',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600)),
                            backgroundColor: _PNC.amber,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.file_download_outlined,
                          color: Colors.white, size: 18),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            // Stats row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Row(
                children: [
                  _statPill(
                      Icons.people_rounded, '${siswa.length} Siswa', ''),
                  const SizedBox(width: 8),
                  _statPill(Icons.star_rounded,
                      'Rata-rata ${avg.toStringAsFixed(1)}', ''),
                  const SizedBox(width: 8),
                  _statPill(Icons.check_circle_rounded,
                      '$lulus Lulus', ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String label, String _) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search & Filter ────────────────────────────────────────────────────────
  Widget _buildSearchFilter() {
    return Container(
      color: _PNC.surfaceLowest,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            style: GoogleFonts.inter(fontSize: 13, color: _PNC.onSurface),
            decoration: InputDecoration(
              hintText: 'Cari nama atau NIS siswa...',
              hintStyle: GoogleFonts.inter(
                  fontSize: 13, color: _PNC.outline.withValues(alpha: 0.7)),
              prefixIcon: const Icon(Icons.search_rounded,
                  size: 20, color: _PNC.outline),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: _PNC.outline),
                    )
                  : null,
              isDense: true,
              filled: true,
              fillColor: _PNC.surfaceLow,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: _PNC.outlineVariant.withValues(alpha: 0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: _PNC.amber, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Filter row
          Row(
            children: [
              // Kelas dropdown
              Expanded(
                child: GestureDetector(
                  onTap: () => _showKelasSheet(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: _PNC.surfaceLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              _PNC.outlineVariant.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.class_rounded,
                            size: 15, color: _PNC.outline),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedKelas ?? 'Semua Kelas',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _PNC.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.expand_more_rounded,
                            size: 16, color: _PNC.outline),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Sort dropdown
              GestureDetector(
                onTap: () => _showSortSheet(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: _PNC.surfaceLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: _PNC.outlineVariant.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _sortAsc
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 15,
                        color: _PNC.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _sortBy ?? 'Nama',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _PNC.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab Bar (Mapel) ────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: _PNC.surfaceLowest,
      child: Column(
        children: [
          Divider(height: 1, color: _PNC.outlineVariant.withValues(alpha: 0.3)),
          SizedBox(
            height: 42,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: _PNC.amber,
              indicatorWeight: 2.5,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w700),
              unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 12, fontWeight: FontWeight.w500),
              labelColor: _PNC.amber,
              unselectedLabelColor: _PNC.outline,
              tabs: _mapelList
                  .map((m) => Tab(text: m['label'] as String))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    final siswa = _filteredSiswa;

    if (siswa.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 72, color: _PNC.outlineVariant),
            const SizedBox(height: 16),
            Text('Tidak ada data ditemukan',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _PNC.onSurfaceVariant,
                )),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: siswa.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _buildSiswaCard(siswa[i]),
    );
  }

  // ── Siswa Card ─────────────────────────────────────────────────────────────
  Widget _buildSiswaCard(_SiswaData siswa) {
    return Container(
      decoration: BoxDecoration(
        color: _PNC.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
            color: _PNC.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showDetailBottomSheet(context, siswa),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(siswa),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siswa.nama,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _PNC.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('NIS: ${siswa.nis}',
                              style: GoogleFonts.inter(
                                  fontSize: 11, color: _PNC.outline)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5EE),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              siswa.kelas,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _PNC.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Mini score bar
                      Row(
                        children: [
                          _miniScore('H', siswa.nilaiHarian),
                          const SizedBox(width: 6),
                          _miniScore('UTS', siswa.nilaiUTS),
                          const SizedBox(width: 6),
                          _miniScore('UAS', siswa.nilaiUAS),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Grade badge
                Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: siswa.gradeBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          siswa.grade,
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: siswa.gradeColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      siswa.nilaiAkhir.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _PNC.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(_SiswaData siswa) {
    if (siswa.avatarUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(siswa.avatarUrl!),
        backgroundColor: _PNC.surfaceLow,
      );
    }
    final initials = siswa.nama
        .split(' ')
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: 24,
      backgroundColor: _PNC.amberLight,
      child: Text(initials,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _PNC.amber,
          )),
    );
  }

  Widget _miniScore(String label, double nilai) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _PNC.surfaceLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: _PNC.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: _PNC.outline)),
          const SizedBox(width: 3),
          Text(nilai.toStringAsFixed(0),
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: _PNC.onSurface)),
        ],
      ),
    );
  }

  // ── Bottom Sheets ──────────────────────────────────────────────────────────
  void _showKelasSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _PNC.surfaceLowest,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _PNC.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Pilih Kelas',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ..._kelasList.map((k) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(k,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: (_selectedKelas == k ||
                          (k == 'Semua Kelas' && _selectedKelas == null))
                      ? Icon(Icons.check_circle_rounded,
                          color: _PNC.amber)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedKelas =
                          k == 'Semua Kelas' ? null : k;
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _PNC.surfaceLowest,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _PNC.outlineVariant,
                      borderRadius: BorderRadius.circular(99))),
            ),
            const SizedBox(height: 16),
            Text('Urutkan',
                style: GoogleFonts.manrope(
                    fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ..._sortOptions.map((s) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s,
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  leading: Icon(
                    _sortBy == s
                        ? (_sortAsc
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded)
                        : Icons.swap_vert_rounded,
                    color: _sortBy == s ? _PNC.amber : _PNC.outline,
                    size: 20,
                  ),
                  onTap: () {
                    setState(() {
                      if (_sortBy == s) {
                        _sortAsc = !_sortAsc;
                      } else {
                        _sortBy = s;
                        _sortAsc = true;
                      }
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showDetailBottomSheet(BuildContext context, _SiswaData siswa) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _PNC.surfaceLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _PNC.outlineVariant,
                      borderRadius: BorderRadius.circular(99))),
            ),
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                _buildAvatar(siswa),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(siswa.nama,
                          style: GoogleFonts.manrope(
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      Text('NIS: ${siswa.nis} · ${siswa.kelas}',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _PNC.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: siswa.gradeBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(siswa.grade,
                        style: GoogleFonts.manrope(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: siswa.gradeColor)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: _PNC.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            // Score breakdown
            _scoreRow('Nilai Harian', siswa.nilaiHarian, '× 40%',
                const Color(0xFF065F46), const Color(0xFFD1FAE5)),
            const SizedBox(height: 10),
            _scoreRow('Nilai UTS', siswa.nilaiUTS, '× 30%',
                const Color(0xFF1E40AF), const Color(0xFFDBEAFE)),
            const SizedBox(height: 10),
            _scoreRow('Nilai UAS', siswa.nilaiUAS, '× 30%',
                const Color(0xFFEA580C), const Color(0xFFFFF7ED)),
            const SizedBox(height: 16),
            Divider(color: _PNC.outlineVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nilai Akhir',
                    style: GoogleFonts.manrope(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                Text(siswa.nilaiAkhir.toStringAsFixed(1),
                    style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: siswa.gradeColor)),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text('Edit Nilai',
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _PNC.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreRow(
      String label, double nilai, String bobot, Color color, Color bg) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _PNC.onSurfaceVariant)),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: nilai / 100,
                backgroundColor:
                    color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(nilai.toStringAsFixed(0),
                  style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color)),
              Text(bobot,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: color.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ],
    );
  }

  void _showInputBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _PNC.surfaceLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                      color: _PNC.outlineVariant,
                      borderRadius: BorderRadius.circular(99))),
            ),
            const SizedBox(height: 16),
            Text('Input Nilai Baru',
                style: GoogleFonts.manrope(
                    fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Text('Fitur input nilai akan tersedia segera.',
                style: GoogleFonts.inter(
                    fontSize: 13, color: _PNC.onSurfaceVariant)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _PNC.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Tutup',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
