import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';
import 'presensi_page.dart';
import '../services/siswa_service.dart';
import '../services/kelas_service.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class _C {
  static const primary    = Color(0xFF004D34);
  static const accent     = Color(0xFF006747);
  static const gold       = Color(0xFFE9C349);
  static const surface    = Color(0xFFF8F9FA);
  static const card       = Color(0xFFFFFFFF);
  static const onSurface  = Color(0xFF191C1D);
  static const subtle     = Color(0xFF3F4943);
  static const border     = Color(0xFFBEC9C1);
  static const chip       = Color(0xFFEDEEEF);
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _Siswa {
  final String id;
  final String nama;
  final String nis;
  final String kelas;
  final String jenisKelamin;
  final String alamat;
  final String noHp;  // no_hp_ortu
  final String tahunMasuk;
  final String tempatLahir;
  final String tanggalLahir;
  final String namaAyah;
  final String namaIbu;
  final String avatar;
  final double nilaiRata;

  const _Siswa({
    required this.id,
    required this.nama,
    required this.nis,
    required this.kelas,
    required this.jenisKelamin,
    required this.alamat,
    required this.noHp,
    required this.tahunMasuk,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.namaAyah,
    required this.namaIbu,
    required this.avatar,
    required this.nilaiRata,
  });

  _Siswa copyWith({
    String? id, String? nama, String? nis, String? kelas,
    String? jenisKelamin, String? alamat, String? noHp,
    String? tahunMasuk, String? tempatLahir, String? tanggalLahir,
    String? namaAyah, String? namaIbu, String? avatar, double? nilaiRata,
  }) => _Siswa(
    id: id ?? this.id, nama: nama ?? this.nama, nis: nis ?? this.nis,
    kelas: kelas ?? this.kelas, jenisKelamin: jenisKelamin ?? this.jenisKelamin,
    alamat: alamat ?? this.alamat, noHp: noHp ?? this.noHp,
    tahunMasuk: tahunMasuk ?? this.tahunMasuk,
    tempatLahir: tempatLahir ?? this.tempatLahir,
    tanggalLahir: tanggalLahir ?? this.tanggalLahir,
    namaAyah: namaAyah ?? this.namaAyah,
    namaIbu: namaIbu ?? this.namaIbu,
    avatar: avatar ?? this.avatar,
    nilaiRata: nilaiRata ?? this.nilaiRata,
  );

  factory _Siswa.fromJson(Map<String, dynamic> json) {
    String kelasName = 'Belum ada kelas';
    if (json['nama_kelas'] != null) {
      kelasName = json['nama_kelas'];
    } else if (json['kelas_id'] != null) {
      kelasName = 'Kelas ${json['kelas_id']}';
    }

    // Convert YYYY-MM-DD from API to DD-MM-YYYY for display
    String tanggalLahir = json['tanggal_lahir']?.toString().split('T')[0] ?? '';
    if (tanggalLahir.isNotEmpty && tanggalLahir.contains('-')) {
      final parts = tanggalLahir.split('-');
      if (parts.length == 3) {
        // parts[0]=YYYY, parts[1]=MM, parts[2]=DD
        tanggalLahir = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    return _Siswa(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      nis: json['nis'] ?? '',
      kelas: kelasName,
      jenisKelamin: json['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan',
      alamat: json['alamat'] ?? '-',
      noHp: json['no_hp_ortu'] ?? '-',
      tahunMasuk: json['tahun_masuk']?.toString() ?? '',
      tempatLahir: json['tempat_lahir'] ?? '-',
      tanggalLahir: tanggalLahir.isEmpty ? '-' : tanggalLahir,
      namaAyah: json['nama_ayah'] ?? '-',
      namaIbu: json['nama_ibu'] ?? '-',
      avatar: json['foto_url'] ?? '',
      nilaiRata: 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert DD-MM-YYYY to YYYY-MM-DD for API
    String? formattedTanggalLahir;
    if (tanggalLahir.isNotEmpty) {
      final parts = tanggalLahir.split('-');
      if (parts.length == 3) {
        // parts[0]=DD, parts[1]=MM, parts[2]=YYYY
        formattedTanggalLahir = '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    }

    return {
      'nama': nama,
      'nis': nis,
      'jenis_kelamin': jenisKelamin == 'Laki-laki' ? 'L' : 'P',
      'alamat': alamat,
      'no_hp_ortu': noHp,
      'tahun_masuk': int.tryParse(tahunMasuk),
      'tempat_lahir': tempatLahir,
      'tanggal_lahir': formattedTanggalLahir ?? tanggalLahir,
      'nama_ayah': namaAyah,
      'nama_ibu': namaIbu,
    };
  }
}

// Data dummy dihapus - sekarang menggunakan API real

// ─── Halaman Utama ────────────────────────────────────────────────────────────
class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  String _searchQuery = '';
  String _filterKelas = 'Semua';
  bool _isGridView = false;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _fabAnim;
  List<_Siswa> _siswaList = [];

  final SiswaService _siswaService = SiswaService();
  final KelasService _kelasService = KelasService();

  final _searchController = TextEditingController();
  List<String> _kelasOptions = ['Semua'];

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadKelasOptions(),
      _loadSiswa(),
    ]);
  }

  Future<void> _loadKelasOptions() async {
    try {
      final kelasList = await _kelasService.getAvailableKelas();
      setState(() {
        _kelasOptions = ['Semua', ...kelasList.map((k) => k['nama_kelas'] as String)];
      });
      debugPrint('✅ Kelas loaded from API: ${kelasList.length} kelas');
      debugPrint('📋 Kelas: ${kelasList.map((k) => k['nama_kelas']).toList()}');
    } catch (e) {
      debugPrint('❌ Failed to load kelas from API: $e');
      // Keep default options if API fails
    }
  }

  Future<void> _loadSiswa() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _siswaService.getAllSiswa();
      setState(() {
        _siswaList = data.map((json) => _Siswa.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _tambahSiswa(_Siswa siswa) async {
    try {
      final data = siswa.toJson();
      // Add kelas_id if selected
      if (siswa.kelas != 'Belum ada kelas') {
        // Find kelas_id from name
        final kelasList = await _kelasService.getAllKelas();
        final kelas = kelasList.firstWhere(
          (k) => k['nama_kelas'] == siswa.kelas,
          orElse: () => {},
        );
        if (kelas.isNotEmpty) {
          data['kelas_id'] = kelas['id'];
        }
      }
      await _siswaService.createSiswa(data);
      await _loadSiswa(); // Reload list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Siswa ${siswa.nama} berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah siswa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editSiswa(_Siswa siswa) async {
    try {
      final data = siswa.toJson();
      // Find kelas_id if needed
      if (siswa.kelas != 'Belum ada kelas') {
        final kelasList = await _kelasService.getAllKelas();
        final kelas = kelasList.firstWhere(
          (k) => k['nama_kelas'] == siswa.kelas,
          orElse: () => {},
        );
        if (kelas.isNotEmpty) {
          data['kelas_id'] = kelas['id'];
        }
      }
      await _siswaService.updateSiswa(int.parse(siswa.id), data);
      await _loadSiswa(); // Reload list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data ${siswa.nama} berhasil diupdate'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate siswa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _hapusSiswa(String id) async {
    try {
      await _siswaService.deleteSiswa(int.parse(id));
      await _loadSiswa(); // Reload list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data siswa berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus siswa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fabAnim.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<_Siswa> get _filtered {
    return _siswaList.where((s) {
      final matchSearch = s.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.nis.contains(_searchQuery);
      final matchKelas = _filterKelas == 'Semua' || s.kelas == _filterKelas;
      return matchSearch && matchKelas;
    }).toList();
  }

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
            Column(
              children: [
                // ── STICKY: AppBar ──
                _StickyAppBarWidget(
                  onBack: () => Navigator.pop(context),
                ),

                // ── STICKY: Stats ──
                _StatsCardWidget(
                  totalSiswa: _siswaList.length,
                  totalLaki: _siswaList.where((s) => s.jenisKelamin == 'Laki-laki').length,
                  totalPerempuan: _siswaList.where((s) => s.jenisKelamin == 'Perempuan').length,
                ),

                // ── STICKY: Search & Filter Bar ──
                _SearchFilterBar(
                  controller: _searchController,
                  onSearch: (v) => setState(() => _searchQuery = v),
                  selectedKelas: _filterKelas,
                  kelasOptions: _kelasOptions,
                  onKelasChanged: (v) => setState(() => _filterKelas = v),
                  isGrid: _isGridView,
                  onToggleView: () => setState(() => _isGridView = !_isGridView),
                ),

                // ── STICKY: Hasil Count ──
                Container(
                  color: _C.surface,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} siswa ditemukan',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _C.subtle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_isLoading)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(_C.primary),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── SCROLLABLE: List / Grid ──
                Expanded(
                  child: _isLoading && _siswaList.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat data',
                                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadSiswa,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        )
                      : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (filtered.isEmpty && !_isLoading)
                        const SliverFillRemaining(child: _EmptyState())
                      else if (_isGridView)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 110 + bottomPad),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _SiswaGridCard(
                                siswa: filtered[i],
                                onTap: () => _showDetail(context, filtered[i]),
                              ),
                              childCount: filtered.length,
                            ),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.82,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 110 + bottomPad),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _SiswaListCard(
                                siswa: filtered[i],
                                index: i,
                                onTap: () => _showDetail(context, filtered[i]),
                              ),
                              childCount: filtered.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // ── FAB Tambah Siswa ──
            Positioned(
              bottom: 100 + bottomPad,
              right: 20,
              child: ScaleTransition(
                scale: CurvedAnimation(parent: _fabAnim, curve: Curves.elasticOut),
                child: FloatingActionButton(
                  onPressed: () => _showForm(context, null),
                  backgroundColor: _C.primary,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.person_add_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ),

            // ── Bottom Nav ──
            Align(
              alignment: Alignment.bottomCenter,
              child: SIMANISBottomNavBar(
                selectedIndex: _selectedIndex,
                onTap: (i) {
                  if (i == 1) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) => const PresensiPage(),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 250),
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

  void _showDetail(BuildContext context, _Siswa siswa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        siswa: siswa,
        onEdit: () {
          Navigator.pop(context);
          _showForm(context, siswa);
        },
        onDelete: () {
          Navigator.pop(context);
          _konfirmasiHapus(context, siswa);
        },
      ),
    );
  }

  Future<void> _showForm(BuildContext context, _Siswa? siswa) async {
    // Tunggu data kelas ter-load jika masih kosong
    if (_kelasOptions.length <= 1) {
      await _loadKelasOptions();
    }

    // Jika masih kosong, gunakan semua kelas dari database (8 kelas)
    var availableKelas = _kelasOptions.where((k) => k != 'Semua').toList();
    final isFromApi = availableKelas.isNotEmpty;
    if (!isFromApi) {
      availableKelas = [
        'X IPA 1', 'X IPA 2', 'X IPS 1',
        'XI IPA 1', 'XI IPA 2', 'XI IPS 1',
        'XII IPA 1', 'XII IPS 1',
      ];
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SiswaFormSheet(
        siswa: siswa,
        kelasOptions: availableKelas,
        onSave: (data) {
          if (siswa == null) {
            _tambahSiswa(data);
          } else {
            _editSiswa(data);
          }
        },
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context, _Siswa siswa) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Siswa', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text(
          'Yakin ingin menghapus data "${siswa.nama}"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.inter(color: _C.subtle, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _hapusSiswa(siswa.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data ${siswa.nama} berhasil dihapus', style: GoogleFonts.inter()),
                  backgroundColor: const Color(0xFFE11D48),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48), elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Hapus', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky AppBar (widget biasa, tidak ikut scroll) ─────────────────────────
class _StickyAppBarWidget extends StatelessWidget {
  final VoidCallback onBack;

  const _StickyAppBarWidget({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).viewPadding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF003828), Color(0xFF006747)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, topPad + 4, 8, 12),
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
                    'DATA SISWA',
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

// ─── Stats Card (sticky, tidak ikut scroll) ───────────────────────────────────
class _StatsCardWidget extends StatelessWidget {
  final int totalSiswa, totalLaki, totalPerempuan;

  const _StatsCardWidget({
    required this.totalSiswa,
    required this.totalLaki,
    required this.totalPerempuan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF003828), Color(0xFF006747)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        child: Row(
          children: [
            _StatPill(
              label: 'Laki-laki',
              value: '$totalLaki',
              icon: Icons.male_rounded,
              accentColor: const Color(0xFF60A5FA),
            ),
            const SizedBox(width: 10),
            _StatPill(
              label: 'Perempuan',
              value: '$totalPerempuan',
              icon: Icons.female_rounded,
              accentColor: const Color(0xFFF9A8D4),
            ),
            const SizedBox(width: 10),
            _StatPill(
              label: 'Jumlah',
              value: '$totalSiswa',
              icon: Icons.groups_rounded,
              highlight: true,
            ),
          ],
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
    final iconColor = highlight
        ? _C.gold
        : (accentColor ?? Colors.white.withOpacity(0.7));

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
            width: 1,
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
  final String selectedKelas;
  final List<String> kelasOptions;
  final ValueChanged<String> onKelasChanged;
  final bool isGrid;
  final VoidCallback onToggleView;

  const _SearchFilterBar({
    required this.controller,
    required this.onSearch,
    required this.selectedKelas,
    required this.kelasOptions,
    required this.onKelasChanged,
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
                hintText: 'Cari nama atau NIS siswa...',
                hintStyle: GoogleFonts.inter(
                    fontSize: 14, color: _C.border),
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
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 4),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Filter chips row
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Kelas dropdown
                      _FilterChip(
                        label: selectedKelas,
                        icon: Icons.class_rounded,
                        options: kelasOptions,
                        onSelected: onKelasChanged,
                        isActive: selectedKelas != 'Semua',
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Toggle view
              GestureDetector(
                onTap: onToggleView,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isGrid ? _C.primary : _C.chip,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final ValueChanged<String> onSelected;
  final bool isActive;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.options,
    required this.onSelected,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _OptionSheet(options: options, selected: label),
        );
        if (result != null) onSelected(result);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _C.primary : _C.chip,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: isActive ? Colors.white : _C.subtle),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : _C.subtle,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded,
                size: 14,
                color: isActive ? Colors.white70 : _C.border),
          ],
        ),
      ),
    );
  }
}

// ─── Option Sheet ─────────────────────────────────────────────────────────────
class _OptionSheet extends StatelessWidget {
  final List<String> options;
  final String selected;

  const _OptionSheet({required this.options, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((opt) => InkWell(
              onTap: () => Navigator.pop(context, opt),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        opt,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: opt == selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: opt == selected ? _C.primary : _C.onSurface,
                        ),
                      ),
                    ),
                    if (opt == selected)
                      const Icon(Icons.check_rounded,
                          color: _C.primary, size: 18),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Siswa List Card ──────────────────────────────────────────────────────────
class _SiswaListCard extends StatelessWidget {
  final _Siswa siswa;
  final int index;
  final VoidCallback onTap;

  const _SiswaListCard({
    required this.siswa,
    required this.index,
    required this.onTap,
  });

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
                // Avatar dengan border status
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _genderColor(siswa.jenisKelamin).withOpacity(0.4),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          siswa.avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _C.chip,
                            child: const Icon(Icons.person_rounded,
                                color: _C.subtle, size: 28),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: _genderColor(siswa.jenisKelamin),
                          shape: BoxShape.circle,
                          border: Border.all(color: _C.card, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

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
                          color: _C.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            'NIS: ${siswa.nis}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: _C.subtle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 3, height: 3,
                            decoration: const BoxDecoration(
                              color: _C.border,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            siswa.kelas,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                const Icon(Icons.chevron_right_rounded,
                    color: _C.border, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Siswa Grid Card ──────────────────────────────────────────────────────────
class _SiswaGridCard extends StatelessWidget {
  final _Siswa siswa;
  final VoidCallback onTap;

  const _SiswaGridCard({required this.siswa, required this.onTap});

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
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            _genderColor(siswa.jenisKelamin).withOpacity(0.2),
                            _genderColor(siswa.jenisKelamin).withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _genderColor(siswa.jenisKelamin).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          siswa.avatar,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: _C.chip,
                            child: const Icon(Icons.person_rounded,
                                color: _C.subtle, size: 28),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: _genderColor(siswa.jenisKelamin),
                          shape: BoxShape.circle,
                          border: Border.all(color: _C.card, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  siswa.nama,
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _C.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  siswa.kelas,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _C.primary,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
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
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _C.chip,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.search_off_rounded,
                color: _C.border, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Siswa tidak ditemukan',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _C.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba ubah kata kunci atau filter',
            style: GoogleFonts.inter(fontSize: 13, color: _C.subtle),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final _Siswa siswa;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DetailSheet({required this.siswa, this.onEdit, this.onDelete});

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
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: _C.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),

          // Profile header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Avatar besar
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _genderColor(siswa.jenisKelamin).withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _genderColor(siswa.jenisKelamin).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      siswa.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _C.chip,
                        child: const Icon(Icons.person_rounded,
                            color: _C.subtle, size: 36),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        siswa.nama,
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _C.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _GenderBadge(jenisKelamin: siswa.jenisKelamin),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Divider
          Divider(height: 1, color: _C.border.withOpacity(0.4)),
          const SizedBox(height: 16),

          // Detail rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _DetailRow(icon: Icons.badge_rounded, label: 'NIS', value: siswa.nis),
                _DetailRow(icon: Icons.class_rounded, label: 'Kelas', value: siswa.kelas),
                _DetailRow(icon: Icons.wc_rounded, label: 'Jenis Kelamin', value: siswa.jenisKelamin),
                _DetailRow(icon: Icons.calendar_today_rounded, label: 'Tahun Masuk', value: siswa.tahunMasuk),
                _DetailRow(icon: Icons.location_city_rounded, label: 'Tempat Lahir', value: siswa.tempatLahir),
                _DetailRow(icon: Icons.cake_rounded, label: 'Tanggal Lahir', value: siswa.tanggalLahir),
                _DetailRow(icon: Icons.location_on_rounded, label: 'Alamat', value: siswa.alamat),
                _DetailRow(icon: Icons.phone_rounded, label: 'No. HP Ortu', value: siswa.noHp),
                _DetailRow(icon: Icons.man_rounded, label: 'Nama Ayah', value: siswa.namaAyah),
                _DetailRow(icon: Icons.woman_rounded, label: 'Nama Ibu', value: siswa.namaIbu),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
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

class _GenderBadge extends StatelessWidget {
  final String jenisKelamin;

  const _GenderBadge({required this.jenisKelamin});

  @override
  Widget build(BuildContext context) {
    final isMale = jenisKelamin == 'Laki-laki';
    final color = isMale ? const Color(0xFF3B82F6) : const Color(0xFFEC4899);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMale ? Icons.male_rounded : Icons.female_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            jenisKelamin,
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

// ─── Helper ───────────────────────────────────────────────────────────────────
Color _genderColor(String jenisKelamin) {
  switch (jenisKelamin) {
    case 'Laki-laki':
      return const Color(0xFF3B82F6); // Blue
    case 'Perempuan':
      return const Color(0xFFEC4899); // Pink
    default:
      return _C.subtle;
  }
}
// ─── Form Bottom Sheet (Tambah & Edit) ────────────────────────────────────────
class _SiswaFormSheet extends StatefulWidget {
  final _Siswa? siswa;
  final List<String> kelasOptions;
  final void Function(_Siswa) onSave;

  const _SiswaFormSheet({this.siswa, required this.kelasOptions, required this.onSave});

  @override
  State<_SiswaFormSheet> createState() => _SiswaFormSheetState();
}

class _SiswaFormSheetState extends State<_SiswaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nama, _nis, _alamat, _noHp;
  late TextEditingController _tahunMasuk, _tempatLahir, _tanggalLahir, _namaAyah, _namaIbu;
  late String _kelas, _jenisKelamin;

  @override
  void initState() {
    super.initState();
    final s = widget.siswa;
    _nama         = TextEditingController(text: s?.nama ?? '');
    _nis          = TextEditingController(text: s?.nis ?? '');
    _alamat       = TextEditingController(text: s?.alamat ?? '');
    _noHp         = TextEditingController(text: s?.noHp ?? '');
    _tahunMasuk   = TextEditingController(text: s?.tahunMasuk ?? DateTime.now().year.toString());
    _tempatLahir  = TextEditingController(text: s?.tempatLahir ?? '');
    // Parse tanggal from DD-MM-YYYY to DateTime for display
    _tanggalLahir = TextEditingController(text: s?.tanggalLahir ?? '');
    _namaAyah     = TextEditingController(text: s?.namaAyah ?? '');
    _namaIbu      = TextEditingController(text: s?.namaIbu ?? '');
    _kelas        = s?.kelas ?? (widget.kelasOptions.isNotEmpty ? widget.kelasOptions.first : 'X IPA 1');
    _jenisKelamin = s?.jenisKelamin ?? 'Laki-laki';
  }

  // Date Picker for Tahun Masuk (Year only)
  Future<void> _pickTahunMasuk() async {
    final currentYear = int.tryParse(_tahunMasuk.text) ?? DateTime.now().year;
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(currentYear, 1, 1),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _C.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _C.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tahunMasuk.text = picked.year.toString();
      });
    }
  }

  // Date Picker for Tanggal Lahir (DD-MM-YYYY format)
  Future<void> _pickTanggalLahir() async {
    // Parse existing date
    DateTime initialDate = DateTime.now().subtract(const Duration(days: 365 * 16)); // Default to ~16 years ago
    if (_tanggalLahir.text.isNotEmpty) {
      final parts = _tanggalLahir.text.split('-');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = int.tryParse(parts[1]) ?? 1;
        final year = int.tryParse(parts[2]) ?? 2000;
        initialDate = DateTime(year, month, day);
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _C.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _C.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        // Format: DD-MM-YYYY
        final day = picked.day.toString().padLeft(2, '0');
        final month = picked.month.toString().padLeft(2, '0');
        final year = picked.year.toString();
        _tanggalLahir.text = '$day-$month-$year';
      });
    }
  }

  @override
  void dispose() {
    _nama.dispose(); _nis.dispose(); _alamat.dispose(); _noHp.dispose();
    _tahunMasuk.dispose(); _tempatLahir.dispose(); _tanggalLahir.dispose();
    _namaAyah.dispose(); _namaIbu.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    final result = _Siswa(
      id: widget.siswa?.id ?? '',
      nama: _nama.text.trim(),
      nis: _nis.text.trim(),
      kelas: _kelas,
      jenisKelamin: _jenisKelamin,
      alamat: _alamat.text.trim(),
      noHp: _noHp.text.trim(),
      tahunMasuk: _tahunMasuk.text.trim(),
      tempatLahir: _tempatLahir.text.trim(),
      tanggalLahir: _tanggalLahir.text.trim(),
      namaAyah: _namaAyah.text.trim(),
      namaIbu: _namaIbu.text.trim(),
      avatar: widget.siswa?.avatar ?? 'https://i.pravatar.cc/150?img=10',
      nilaiRata: widget.siswa?.nilaiRata ?? 0,
    );
    Navigator.pop(context);
    widget.onSave(result);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.siswa == null ? 'Siswa berhasil ditambahkan' : 'Data berhasil diperbarui',
          style: GoogleFonts.inter()),
      backgroundColor: _C.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final keyboardPad = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.siswa != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 12 + bottomPad + keyboardPad),
      decoration: const BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              Center(
                child: Container(
                  width: 32, height: 4,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Title row ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Data Siswa' : 'Tambah Siswa Baru',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.onSurface,
                          ),
                        ),
                        Text(
                          isEdit
                              ? 'Perbarui informasi data siswa'
                              : 'Isi data lengkap siswa baru',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Jenis Kelamin (pill selector) ──
              _SiswaFormLabel('Jenis Kelamin'),
              const SizedBox(height: 6),
              Row(
                children: ['Laki-laki', 'Perempuan'].map((jk) {
                  final isSelected = _jenisKelamin == jk;
                  final color = jk == 'Laki-laki'
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFDB2777);
                  final icon = jk == 'Laki-laki'
                      ? Icons.male_rounded
                      : Icons.female_rounded;
                  final isLast = jk == 'Perempuan';
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _jenisKelamin = jk),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color : _C.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : _C.border.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon,
                                  size: 16,
                                  color: isSelected ? Colors.white : color),
                              const SizedBox(width: 6),
                              Text(
                                jk,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : _C.subtle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // ── Row 1: Nama Lengkap & NIS ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SiswaFormLabel('Nama Lengkap'),
                        const SizedBox(height: 5),
                        _SiswaFormField(
                          controller: _nama,
                          hint: 'Nama siswa',
                          icon: Icons.person_rounded,
                          inputType: TextInputType.name,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama wajib diisi'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SiswaFormLabel('NIS'),
                        const SizedBox(height: 5),
                        _SiswaFormField(
                          controller: _nis,
                          hint: '2024001',
                          icon: Icons.badge_rounded,
                          inputType: TextInputType.number,
                          readOnly: widget.siswa != null,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'NIS wajib diisi'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Row 2: Tempat Lahir & Tanggal Lahir ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SiswaFormLabel('Tempat Lahir'),
                        const SizedBox(height: 5),
                        _SiswaFormField(
                          controller: _tempatLahir,
                          hint: 'Jakarta',
                          icon: Icons.location_city_rounded,
                          inputType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SiswaFormLabel('Tanggal Lahir'),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: _pickTanggalLahir,
                          child: AbsorbPointer(
                            child: _SiswaFormField(
                              controller: _tanggalLahir,
                              hint: '01-01-2008',
                              icon: Icons.cake_rounded,
                              readOnly: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Row 3: Tahun Masuk & Kelas ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SiswaFormLabel('Tahun Masuk'),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: _pickTahunMasuk,
                          child: AbsorbPointer(
                            child: _SiswaFormField(
                              controller: _tahunMasuk,
                              hint: '2024',
                              icon: Icons.calendar_today_rounded,
                              readOnly: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SiswaFormLabel('Kelas'),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: _C.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _C.border.withOpacity(0.5)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: _kelas,
                              icon: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey.shade400),
                              style: GoogleFonts.inter(fontSize: 13, color: _C.onSurface),
                              dropdownColor: _C.card,
                              borderRadius: BorderRadius.circular(12),
                              items: widget.kelasOptions
                                  .map((k) => DropdownMenuItem(
                                        value: k,
                                        child: Row(
                                          children: [
                                            Icon(Icons.class_rounded,
                                                color: _C.primary, size: 16),
                                            const SizedBox(width: 8),
                                            Text(k,
                                                style: GoogleFonts.inter(
                                                    fontSize: 13, color: _C.onSurface)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _kelas = v!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Row 4: Alamat (full width) ──
              _SiswaFormLabel('Alamat'),
              const SizedBox(height: 5),
              _SiswaFormField(
                controller: _alamat,
                hint: 'Jl. Contoh No. 1, Kota',
                icon: Icons.location_on_rounded,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Alamat wajib diisi'
                    : null,
              ),
              const SizedBox(height: 10),

              // ── Row 5: Nama Ayah & Nama Ibu ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SiswaFormLabel('Nama Ayah'),
                        const SizedBox(height: 5),
                        _SiswaFormField(
                          controller: _namaAyah,
                          hint: 'Nama ayah',
                          icon: Icons.man_rounded,
                          inputType: TextInputType.name,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SiswaFormLabel('Nama Ibu'),
                        const SizedBox(height: 5),
                        _SiswaFormField(
                          controller: _namaIbu,
                          hint: 'Nama ibu',
                          icon: Icons.woman_rounded,
                          inputType: TextInputType.name,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Row 6: No. HP Orang Tua (full width) ──
              _SiswaFormLabel('No. HP Orang Tua'),
              const SizedBox(height: 5),
              _SiswaFormField(
                controller: _noHp,
                hint: '081234567890',
                icon: Icons.phone_rounded,
                inputType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'No. HP wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // ── Tombol Simpan ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _simpan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(
                      isEdit ? Icons.save_rounded : Icons.add_rounded,
                      size: 17,
                      color: Colors.white),
                  label: Text(
                    isEdit ? 'Simpan Perubahan' : 'Simpan Siswa',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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

// ─── Form Helper Widgets (gaya tagihan) ──────────────────────────────────────
class _SiswaFormLabel extends StatelessWidget {
  final String text;
  const _SiswaFormLabel(this.text);

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

class _SiswaFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;

  const _SiswaFormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.inputType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? _C.chip : _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border.withOpacity(readOnly ? 0.4 : 0.5)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        maxLines: maxLines,
        readOnly: readOnly,
        style: GoogleFonts.inter(
            fontSize: 13,
            color: readOnly ? _C.subtle : _C.onSurface),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(icon,
              color: readOnly ? Colors.grey.shade400 : Colors.grey.shade400,
              size: 16),
          suffixIcon: null,
          prefixIconConstraints:
              const BoxConstraints(minWidth: 40, minHeight: 40),
          isDense: true,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}