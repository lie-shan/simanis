import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';
import '../services/kelas_service.dart';
import '../services/guru_service.dart';
import 'pengumuman_page.dart';
import 'dashboard_page.dart';
import 'akun_page.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _C {
  static const primary          = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
  static const surface          = Color(0xFFF8F9FA);
  static const surfaceLowest    = Color(0xFFFFFFFF);
  static const surfaceLow       = Color(0xFFF0F2F1);
  static const onSurface        = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline          = Color(0xFF6F7A72);
  static const outlineVariant   = Color(0xFFBEC9C1);
}

// ─── Model ────────────────────────────────────────────────────────────────────
class KelasModel {
  final int id;
  final String namaKelas;
  final String tingkat;
  final String? waliKelas;
  final int? waliKelasId;
  final int jumlahLaki;
  final int jumlahPerempuan;
  final String tahunAjaran;
  final int? totalSiswa;
  final int? totalJadwal;

  const KelasModel({
    required this.id,
    required this.namaKelas,
    required this.tingkat,
    this.waliKelas,
    this.waliKelasId,
    this.jumlahLaki = 0,
    this.jumlahPerempuan = 0,
    required this.tahunAjaran,
    this.totalSiswa,
    this.totalJadwal,
  });

  int get jumlahSiswa => totalSiswa ?? (jumlahLaki + jumlahPerempuan);

  factory KelasModel.fromJson(Map<String, dynamic> json) {
    // Parse jumlah siswa per gender from database if available
    int laki = 0;
    int perempuan = 0;
    if (json['siswa'] != null && json['siswa'] is List) {
      final siswaList = json['siswa'] as List;
      for (var s in siswaList) {
        if (s['jenis_kelamin'] == 'L') laki++;
        else if (s['jenis_kelamin'] == 'P') perempuan++;
      }
    }

    return KelasModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      namaKelas: json['nama_kelas'] ?? '',
      tingkat: _parseTingkat(json['tingkat'] ?? '10'),
      waliKelas: json['nama_wali_kelas'],
      waliKelasId: json['wali_kelas_id'] is int ? json['wali_kelas_id'] : 
                   (json['wali_kelas_id'] != null ? int.tryParse(json['wali_kelas_id'].toString()) : null),
      jumlahLaki: laki,
      jumlahPerempuan: perempuan,
      tahunAjaran: json['tahun_ajaran'] ?? '2024/2025',
      totalSiswa: json['total_siswa'] is int ? json['total_siswa'] : 
                  (json['total_siswa'] != null ? int.tryParse(json['total_siswa'].toString()) : null),
      totalJadwal: json['total_jadwal'] is int ? json['total_jadwal'] : 
                   (json['total_jadwal'] != null ? int.tryParse(json['total_jadwal'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'nama_kelas': namaKelas,
    'tingkat': _tingkatToDb(tingkat),
    'wali_kelas_id': waliKelasId,
    'tahun_ajaran': tahunAjaran,
  };

  KelasModel copyWith({
    int? id, String? namaKelas, String? tingkat, String? waliKelas,
    int? waliKelasId, int? jumlahLaki, int? jumlahPerempuan, String? tahunAjaran,
    int? totalSiswa, int? totalJadwal,
  }) => KelasModel(
    id: id ?? this.id, namaKelas: namaKelas ?? this.namaKelas,
    tingkat: tingkat ?? this.tingkat, waliKelas: waliKelas ?? this.waliKelas,
    waliKelasId: waliKelasId ?? this.waliKelasId,
    jumlahLaki: jumlahLaki ?? this.jumlahLaki,
    jumlahPerempuan: jumlahPerempuan ?? this.jumlahPerempuan,
    tahunAjaran: tahunAjaran ?? this.tahunAjaran,
    totalSiswa: totalSiswa ?? this.totalSiswa,
    totalJadwal: totalJadwal ?? this.totalJadwal,
  );

  static String _parseTingkat(String dbTingkat) {
    switch (dbTingkat) {
      case '10': return 'Kelas 10';
      case '11': return 'Kelas 11';
      case '12': return 'Kelas 12';
      case 'X': return 'Kelas 10';
      case 'XI': return 'Kelas 11';
      case 'XII': return 'Kelas 12';
      default: return 'Kelas $dbTingkat';
    }
  }

  static String _tingkatToDb(String tingkat) {
    switch (tingkat) {
      case 'Kelas 10': return '10';
      case 'Kelas 11': return '11';
      case 'Kelas 12': return '12';
      default: return '10';
    }
  }
}

// ─── Kelas Page ───────────────────────────────────────────────────────────────
class KelasPage extends StatefulWidget {
  const KelasPage({super.key});

  @override
  State<KelasPage> createState() => _KelasPageState();
}

class _KelasPageState extends State<KelasPage> {
  int _selectedNavIndex = 1;
  String _searchQuery = '';
  String _selectedTingkat = 'Semua';

  final List<String> _tingkatList = ['Semua', 'Kelas 10', 'Kelas 11', 'Kelas 12'];

  List<KelasModel> _kelasList = [];
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _stats;

  final KelasService _kelasService = KelasService();
  final GuruService _guruService = GuruService();
  List<Map<String, dynamic>> _guruList = [];

  List<KelasModel> get _filtered => _kelasList.where((k) {
        final matchTingkat = _selectedTingkat == 'Semua' || k.tingkat == _selectedTingkat;
        final matchSearch = _searchQuery.isEmpty ||
            k.namaKelas.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (k.waliKelas?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        return matchTingkat && matchSearch;
      }).toList();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.wait([
        _loadKelas(),
        _loadStats(),
        _loadGuru(),
      ]);
    } catch (e) {
      debugPrint('❌ Error loading initial data: $e');
    }
  }

  Future<void> _loadKelas() async {
    try {
      final data = await _kelasService.getAllKelas();
      setState(() {
        _kelasList = data.map((json) => KelasModel.fromJson(json)).toList();
        _isLoading = false;
      });
      debugPrint('✅ Kelas loaded: ${_kelasList.length} kelas');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      debugPrint('❌ Failed to load kelas: $e');
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _kelasService.getKelasStats();
      setState(() => _stats = stats);
      debugPrint('✅ Stats loaded: $stats');
    } catch (e) {
      debugPrint('❌ Failed to load stats: $e');
    }
  }

  Future<void> _loadGuru() async {
    try {
      final guru = await _guruService.getAvailableGuru();
      setState(() => _guruList = guru);
      debugPrint('✅ Guru loaded: ${guru.length} guru');
    } catch (e) {
      debugPrint('❌ Failed to load guru: $e');
    }
  }

  Future<void> _tambahKelas(KelasModel k) async {
    try {
      final result = await _kelasService.createKelas(k.toJson());
      await _loadKelas();
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result['nama_kelas']} berhasil ditambahkan', style: GoogleFonts.inter()),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah kelas: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _editKelas(KelasModel k) async {
    try {
      await _kelasService.updateKelas(k.id, k.toJson());
      await _loadKelas();
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${k.namaKelas} berhasil diperbarui', style: GoogleFonts.inter()),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui kelas: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _hapusKelas(int id) async {
    try {
      await _kelasService.deleteKelas(id);
      await _loadKelas();
      await _loadStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kelas berhasil dihapus', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus kelas: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _navigateTo(Widget page) => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => page,
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );

  void _navigateReplace(Widget page) => Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, a, __) => page,
          transitionsBuilder: (_, a, __, child) =>
              FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 250),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _C.surface,
        body: Stack(
          children: [
            // ── Konten Utama ──
            Column(
              children: [
                _buildHeaderArea(),
                _buildSummary(filtered.length),
                Expanded(
                  child: _isLoading
                      ? _buildLoading()
                      : _errorMessage != null
                          ? _buildError()
                          : RefreshIndicator(
                              onRefresh: _loadInitialData,
                              color: _C.primary,
                              backgroundColor: Colors.white,
                              child: filtered.isEmpty
                                  ? _buildEmpty()
                                  : ListView.builder(
                                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: filtered.length,
                                      itemBuilder: (context, index) =>
                                          _buildKelasCard(filtered[index]),
                                    ),
                            ),
                ),
              ],
            ),

            // ── FAB Tambah ──
            Positioned(
              right: 16,
              bottom: 100,
              child: FloatingActionButton(
                onPressed: () => _showTambahKelasSheet(),
                backgroundColor: _C.primary,
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add_rounded, color: Colors.white),
              ),
            ),

            // ── Bottom Navbar (Stack, sesuai bottom_navbar.dart) ──
            Align(
              alignment: Alignment.bottomCenter,
              child: SiakadBottomNavBar(
                selectedIndex: _selectedNavIndex,
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
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading State ────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: _C.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data kelas...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _C.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Error State ───────────────────────────────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _C.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Coba Lagi', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header + Search + Filter ─────────────────────────────────────────────────
  Widget _buildHeaderArea() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF003828), Color(0xFF006747)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar Row
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'Data Kelas',
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

            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2)),
                ),
                child: TextField(
                  onChanged: (v) =>
                      setState(() => _searchQuery = v),
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cari kelas atau wali kelas...',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 13, color: Colors.white54),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: Colors.white54, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  // ── Summary ──────────────────────────────────────────────────────────────────
  Widget _buildSummary(int totalFiltered) {
    // Calculate from filtered data (real-time from database)
    final totalLaki = _filtered.fold<int>(0, (s, k) => s + k.jumlahLaki);
    final totalPerempuan = _filtered.fold<int>(0, (s, k) => s + k.jumlahPerempuan);
    final totalSiswa = totalLaki + totalPerempuan;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.outlineVariant.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _summaryItem(Icons.male_rounded, '$totalLaki', 'Laki-laki',
              const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
          _summaryDivider(),
          _summaryItem(Icons.female_rounded, '$totalPerempuan',
              'Perempuan', const Color(0xFFE11D48), const Color(0xFFFFF1F2)),
          _summaryDivider(),
          _summaryItem(Icons.people_rounded, '$totalSiswa',
              'Total Siswa', _C.primary, const Color(0xFFE8F5EE)),
        ],
      ),
    );
  }

  Widget _summaryItem(IconData icon, String value, String label,
      Color color, Color bg) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.onSurface)),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: _C.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() => Container(
        width: 1,
        height: 36,
        color: _C.outlineVariant.withOpacity(0.4));

  // ── Kelas Card ───────────────────────────────────────────────────────────────
  Widget _buildKelasCard(KelasModel kelas) {
    final colors = _kelasColor(kelas.tingkat);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: _C.outlineVariant.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor:
              (colors['color'] as Color).withOpacity(0.06),
          highlightColor:
              (colors['color'] as Color).withOpacity(0.03),
          onTap: () => _showDetailSheet(kelas),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon inisial kelas
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: colors['bg'] as Color,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      kelas.namaKelas.split(' ').last,
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: colors['color'] as Color,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            kelas.namaKelas,
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: _C.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors['bg'] as Color,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(
                              kelas.tingkat,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: colors['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                              Icons.person_outline_rounded,
                              size: 12,
                              color: _C.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              kelas.waliKelas ?? 'Belum ada wali kelas',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _C.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _chip(
                            Icons.male_rounded,
                            '${kelas.jumlahLaki} L',
                            const Color(0xFF2563EB),
                            const Color(0xFFEFF6FF),
                          ),
                          const SizedBox(width: 6),
                          _chip(
                            Icons.female_rounded,
                            '${kelas.jumlahPerempuan} P',
                            const Color(0xFFE11D48),
                            const Color(0xFFFFF1F2),
                          ),
                          const SizedBox(width: 6),
                          _chip(
                            Icons.people_rounded,
                            '${kelas.jumlahSiswa} Total',
                            _C.primary,
                            const Color(0xFFE8F5EE),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: _C.outlineVariant, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(
      IconData icon, String label, Color color, Color bg) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(7)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }

  Map<String, Color> _kelasColor(String tingkat) {
    switch (tingkat) {
      case 'Kelas 10':
        return {
          'color': const Color(0xFF2563EB),
          'bg': const Color(0xFFEFF6FF)
        };
      case 'Kelas 11':
        return {
          'color': const Color(0xFFEA580C),
          'bg': const Color(0xFFFFF7ED)
        };
      case 'Kelas 12':
        return {
          'color': const Color(0xFF004D34),
          'bg': const Color(0xFFE8F5EE)
        };
      default:
        return {
          'color': const Color(0xFF52525B),
          'bg': const Color(0xFFF4F4F5)
        };
    }
  }

  // ── Empty State ──────────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.12,
            child:
                Icon(Icons.class_rounded, size: 90, color: _C.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada kelas ditemukan',
            style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba ubah filter atau kata pencarian',
            style:
                GoogleFonts.inter(fontSize: 12, color: _C.outline),
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheet — Detail ────────────────────────────────────────────────────
  void _showDetailSheet(KelasModel kelas) {
    final colors = _kelasColor(kelas.tingkat);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: _C.outlineVariant,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: colors['bg'],
                  borderRadius: BorderRadius.circular(18)),
              child: Center(
                child: Text(
                  kelas.namaKelas.split(' ').last,
                  style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: colors['color']),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(kelas.namaKelas,
                style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _C.onSurface)),
            const SizedBox(height: 2),
            Text(kelas.tingkat,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: _C.onSurfaceVariant)),
            const SizedBox(height: 20),
            _detailRow(Icons.person_rounded, 'Wali Kelas',
                kelas.waliKelas ?? 'Belum ditentukan'),
            _detailRow(Icons.male_rounded, 'Laki-laki',
                '${kelas.jumlahLaki} Siswa'),
            _detailRow(Icons.female_rounded, 'Perempuan',
                '${kelas.jumlahPerempuan} Siswa'),
            _detailRow(Icons.people_rounded, 'Total Siswa',
                '${kelas.jumlahSiswa} Siswa'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(context: context, builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text('Hapus Kelas', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
                        content: Text('Yakin ingin menghapus "${kelas.namaKelas}"?', style: GoogleFonts.inter(fontSize: 14)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context),
                              child: Text('Batal', style: GoogleFonts.inter(color: _C.onSurfaceVariant, fontWeight: FontWeight.w600))),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _hapusKelas(kelas.id);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${kelas.namaKelas} berhasil dihapus', style: GoogleFonts.inter()),
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
                    icon: const Icon(Icons.delete_rounded, size: 16, color: Color(0xFFE11D48)),
                    label: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Color(0xFFE11D48))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE11D48)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showTambahKelasSheet(kelas: kelas);
                    },
                    icon: const Icon(Icons.edit_rounded, size: 16),
                    label: Text('Edit', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 18, color: _C.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _C.onSurfaceVariant)),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.onSurface)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheet — Tambah/Edit ────────────────────────────────────────────────
  void _showTambahKelasSheet({KelasModel? kelas}) {
    final namaController =
        TextEditingController(text: kelas?.namaKelas ?? '');
    final tahunAjaranController =
        TextEditingController(text: kelas?.tahunAjaran ?? '2024/2025');
    final isEdit = kelas != null;

    // State for dropdown selections
    String? selectedTingkat = kelas?.tingkat ?? 'Kelas 10';
    int? selectedWaliKelasId = kelas?.waliKelasId;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  MediaQuery.of(context).padding.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: _C.outlineVariant,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE8F5EE),
                            borderRadius: BorderRadius.circular(11)),
                        child: const Icon(Icons.class_rounded,
                            size: 20, color: _C.primary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEdit ? 'Edit Kelas' : 'Tambah Kelas',
                        style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: _C.onSurface),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _formField(
                      'Nama Kelas', 'Contoh: XI IPA 1', namaController),
                  const SizedBox(height: 14),
                  // Tingkat Dropdown
                  _dropdownField<String>(
                    label: 'Tingkat',
                    value: selectedTingkat,
                    items: const ['Kelas 10', 'Kelas 11', 'Kelas 12'],
                    onChanged: (value) {
                      setModalState(() => selectedTingkat = value);
                    },
                    hint: 'Pilih tingkat',
                  ),
                  const SizedBox(height: 14),
                  // Wali Kelas Dropdown from Guru list
                  Builder(
                    builder: (context) {
                      // Build items list
                      final guruItems = _guruList.map((g) => g['id'] as int).toList();
                      final guruLabels = _guruList.map((g) => g['nama'] as String).toList();
                      
                      // Check if current value exists in items
                      final items = [null, ...guruItems];
                      final labels = ['Tanpa Wali Kelas', ...guruLabels];
                      
                      // If selected value not in items, reset to null
                      if (selectedWaliKelasId != null && !guruItems.contains(selectedWaliKelasId)) {
                        // Reset on next frame
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setModalState(() => selectedWaliKelasId = null);
                        });
                      }
                      
                      return _dropdownField<int?>(
                        label: 'Wali Kelas',
                        value: items.contains(selectedWaliKelasId) ? selectedWaliKelasId : null,
                        items: items,
                        itemLabels: labels,
                        onChanged: (value) {
                          setModalState(() => selectedWaliKelasId = value);
                        },
                        hint: 'Pilih wali kelas',
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _formField(
                      'Tahun Ajaran', 'Contoh: 2024/2025', tahunAjaranController),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (namaController.text.isEmpty || selectedTingkat == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Nama kelas dan tingkat wajib diisi', style: GoogleFonts.inter()),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ));
                          return;
                        }
                        final result = KelasModel(
                          id: isEdit ? kelas!.id : 0,
                          namaKelas: namaController.text.trim(),
                          tingkat: selectedTingkat!,
                          waliKelasId: selectedWaliKelasId,
                          tahunAjaran: tahunAjaranController.text.trim(),
                        );
                        Navigator.pop(context);
                        if (isEdit) { _editKelas(result); } else { _tambahKelas(result); }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isEdit ? 'Simpan Perubahan' : 'Tambah Kelas',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w700),
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

  // Custom dropdown field
  Widget _dropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    List<String>? itemLabels,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.onSurfaceVariant)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: _C.surfaceLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.outlineVariant.withOpacity(0.5)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(hint,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _C.outline.withOpacity(0.5))),
              ),
              icon: const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.arrow_drop_down, color: _C.primary),
              ),
              items: items.asMap().entries.map((entry) {
                final index = entry.key;
                final itemValue = entry.value;
                final label = itemLabels != null && index < itemLabels.length
                    ? itemLabels[index]
                    : itemValue.toString();
                return DropdownMenuItem<T>(
                  value: itemValue,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text(label,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: _C.onSurface)),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _formField(
    String label,
    String hint,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.onSurfaceVariant)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style:
              GoogleFonts.inter(fontSize: 13, color: _C.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: _C.outline.withOpacity(0.5)),
            filled: true,
            fillColor: _C.surfaceLow,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: _C.outlineVariant.withOpacity(0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: _C.outlineVariant.withOpacity(0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _C.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}