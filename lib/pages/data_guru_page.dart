import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';
import 'presensi_page.dart';
import '../services/guru_service.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class _C {
  static const primary   = Color(0xFF004D34);
  static const accent    = Color(0xFF006747);
  static const gold      = Color(0xFFE9C349);
  static const surface   = Color(0xFFF8F9FA);
  static const card      = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1D);
  static const subtle    = Color(0xFF3F4943);
  static const border    = Color(0xFFBEC9C1);
  static const chip      = Color(0xFFEDEEEF);
}

// ─── Model ────────────────────────────────────────────────────────────────────
class _Guru {
  final String id;
  final String nama;
  final String nip;
  final String jenisKelamin;
  final String alamat;
  final String noHp;
  final String status;
  final String avatar;
  final String jabatan;

  const _Guru({
    required this.id,
    required this.nama,
    required this.nip,
    required this.jenisKelamin,
    required this.alamat,
    required this.noHp,
    required this.status,
    required this.avatar,
    required this.jabatan,
  });

  _Guru copyWith({
    String? id, String? nama, String? nip,
    String? jenisKelamin, String? alamat, String? noHp,
    String? status, String? avatar, String? jabatan,
  }) => _Guru(
    id: id ?? this.id, nama: nama ?? this.nama, nip: nip ?? this.nip,
    jenisKelamin: jenisKelamin ?? this.jenisKelamin,
    alamat: alamat ?? this.alamat, noHp: noHp ?? this.noHp,
    status: status ?? this.status, avatar: avatar ?? this.avatar,
    jabatan: jabatan ?? this.jabatan,
  );

  factory _Guru.fromJson(Map<String, dynamic> json) {
    return _Guru(
      id: json['id'].toString(),
      nama: json['nama'] ?? '',
      nip: json['nip'] ?? '',
      jenisKelamin: json['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan',
      alamat: json['alamat'] ?? '-',
      noHp: json['no_hp'] ?? '-',
      status: 'Aktif', // Default status
      avatar: json['foto_url'] ?? '',
      jabatan: json['is_wali_kelas'] == true ? 'Wali Kelas' : 'Guru',
    );
  }

  Map<String, dynamic> toJson() => {
    'nama': nama,
    'nip': nip,
    'jenis_kelamin': jenisKelamin == 'Laki-laki' ? 'L' : 'P',
    'alamat': alamat,
    'no_hp': noHp,
  };
}

// Data dummy dihapus - menggunakan API real

// ─── Halaman Utama ────────────────────────────────────────────────────────────
class DataGuruPage extends StatefulWidget {
  const DataGuruPage({super.key});

  @override
  State<DataGuruPage> createState() => _DataGuruPageState();
}

class _DataGuruPageState extends State<DataGuruPage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 1;
  String _searchQuery = '';
  String _filterJabatan = 'Semua';
  String _filterStatus = 'Semua';
  bool _isGridView = false;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _fabAnim;
  List<_Guru> _guruList = [];

  final GuruService _guruService = GuruService();

  final _searchController = TextEditingController();
  final _jabatanOptions = [
    'Semua',
    'Kepala Sekolah',
    'Wakil Kepala Sekolah',
    'Guru',
    'Guru Tetap',
    'Guru Honorer',
  ];
  final _statusOptions = ['Semua', 'Aktif', 'Tidak Aktif', 'Cuti'];

  @override
  void initState() {
    super.initState();
    _fabAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _loadGuru();
  }

  Future<void> _loadGuru() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _guruService.getAllGuru();
      setState(() {
        _guruList = data.map((json) => _Guru.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _tambahGuru(_Guru guru) async {
    try {
      await _guruService.createGuru(guru.toJson());
      await _loadGuru();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Guru ${guru.nama} berhasil ditambahkan'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah guru: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editGuru(_Guru guru) async {
    try {
      await _guruService.updateGuru(int.parse(guru.id), guru.toJson());
      await _loadGuru();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data ${guru.nama} berhasil diupdate'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengupdate guru: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _hapusGuru(String id) async {
    try {
      await _guruService.deleteGuru(int.parse(id));
      await _loadGuru();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data guru berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus guru: $e'), backgroundColor: Colors.red),
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

  List<_Guru> get _filtered {
    return _guruList.where((g) {
      final matchSearch =
          g.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              g.nip.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchJabatan =
          _filterJabatan == 'Semua' || g.jabatan == _filterJabatan;
      final matchStatus =
          _filterStatus == 'Semua' || g.status == _filterStatus;
      return matchSearch && matchJabatan && matchStatus;
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
                  totalGuru: _guruList.length,
                  totalLaki: _guruList
                      .where((g) => g.jenisKelamin == 'Laki-laki')
                      .length,
                  totalPerempuan: _guruList
                      .where((g) => g.jenisKelamin == 'Perempuan')
                      .length,
                ),

                // ── STICKY: Search & Filter Bar ──
                _SearchFilterBar(
                  controller: _searchController,
                  onSearch: (v) => setState(() => _searchQuery = v),
                  selectedJabatan: _filterJabatan,
                  selectedStatus: _filterStatus,
                  jabatanOptions: _jabatanOptions,
                  statusOptions: _statusOptions,
                  onJabatanChanged: (v) => setState(() => _filterJabatan = v),
                  onStatusChanged: (v) => setState(() => _filterStatus = v),
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
                        '${filtered.length} guru ditemukan',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _C.subtle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── SCROLLABLE: List / Grid ──
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (filtered.isEmpty)
                        const SliverFillRemaining(child: _EmptyState())
                      else if (_isGridView)
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 110 + bottomPad),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _GuruGridCard(
                                guru: filtered[i],
                                onTap: () => _showDetail(context, filtered[i]),
                              ),
                              childCount: filtered.length,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.80,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 110 + bottomPad),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _GuruListCard(
                                guru: filtered[i],
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

            // ── FAB Tambah Guru ──
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

  void _showDetail(BuildContext context, _Guru guru) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        guru: guru,
        onEdit: () { Navigator.pop(context); _showForm(context, guru); },
        onDelete: () { Navigator.pop(context); _konfirmasiHapus(context, guru); },
      ),
    );
  }

  void _showForm(BuildContext context, _Guru? guru) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GuruFormSheet(
        guru: guru,
        jabatanOptions: _jabatanOptions.where((j) => j != 'Semua').toList(),
        onSave: (data) => guru == null ? _tambahGuru(data) : _editGuru(data),
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context, _Guru guru) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Guru', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text('Yakin ingin menghapus data "${guru.nama}"?', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.inter(color: _C.subtle, fontWeight: FontWeight.w600))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _hapusGuru(guru.id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Data \${guru.nama} berhasil dihapus', style: GoogleFonts.inter()),
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
                    'DATA GURU',
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
  final int totalGuru, totalLaki, totalPerempuan;

  const _StatsCardWidget({
    required this.totalGuru,
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
              value: '$totalGuru',
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
  final String selectedJabatan, selectedStatus;
  final List<String> jabatanOptions, statusOptions;
  final ValueChanged<String> onJabatanChanged, onStatusChanged;
  final bool isGrid;
  final VoidCallback onToggleView;

  const _SearchFilterBar({
    required this.controller,
    required this.onSearch,
    required this.selectedJabatan,
    required this.selectedStatus,
    required this.jabatanOptions,
    required this.statusOptions,
    required this.onJabatanChanged,
    required this.onStatusChanged,
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
                hintText: 'Cari nama atau NIP...',
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
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 4),
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
                    children: [
                      _FilterChip(
                        label: selectedJabatan,
                        icon: Icons.work_rounded,
                        options: jabatanOptions,
                        onSelected: onJabatanChanged,
                        isActive: selectedJabatan != 'Semua',
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: selectedStatus,
                        icon: Icons.filter_list_rounded,
                        options: statusOptions,
                        onSelected: onStatusChanged,
                        isActive: selectedStatus != 'Semua',
                      ),
                    ],
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
                    color: isGrid ? _C.primary : _C.chip,
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
          builder: (_) =>
              _OptionSheet(options: options, selected: label),
        );
        if (result != null) onSelected(result);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            ...options.map((opt) => InkWell(
                  onTap: () => Navigator.pop(context, opt),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
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
                              color: opt == selected
                                  ? _C.primary
                                  : _C.onSurface,
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

// ─── Guru List Card ───────────────────────────────────────────────────────────
class _GuruListCard extends StatelessWidget {
  final _Guru guru;
  final VoidCallback onTap;

  const _GuruListCard({required this.guru, required this.onTap});

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
                // Avatar
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _statusColor(guru.status).withOpacity(0.4),
                          width: 2.5,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          guru.avatar,
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
                          color: _statusColor(guru.status),
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
                        guru.nama,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _C.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      _JabatanBadge(jabatan: guru.jabatan),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

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

// ─── Guru Grid Card ───────────────────────────────────────────────────────────
class _GuruGridCard extends StatelessWidget {
  final _Guru guru;
  final VoidCallback onTap;

  const _GuruGridCard({required this.guru, required this.onTap});

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
                            _statusColor(guru.status).withOpacity(0.2),
                            _statusColor(guru.status).withOpacity(0.05),
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
                          color:
                              _statusColor(guru.status).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          guru.avatar,
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
                          color: _statusColor(guru.status),
                          shape: BoxShape.circle,
                          border: Border.all(color: _C.card, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  guru.nama,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _C.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _JabatanBadge(jabatan: guru.jabatan, small: true),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Jabatan Badge ────────────────────────────────────────────────────────────
class _JabatanBadge extends StatelessWidget {
  final String jabatan;
  final bool small;

  const _JabatanBadge({required this.jabatan, this.small = false});

  Color get _color => _jabatanColor(jabatan);
  Color get _bg => _jabatanBg(jabatan);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Text(
        jabatan,
        style: GoogleFonts.inter(
          fontSize: small ? 9 : 10,
          fontWeight: FontWeight.w700,
          color: _color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
            child: const Icon(Icons.person_search_rounded,
                color: _C.border, size: 40),
          ),
          const SizedBox(height: 16),
          Text(
            'Guru tidak ditemukan',
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
  final _Guru guru;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _DetailSheet({required this.guru, this.onEdit, this.onDelete});

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

          // Profile header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _statusColor(guru.status).withOpacity(0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor(guru.status).withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.network(
                      guru.avatar,
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
                        guru.nama,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _C.onSurface,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _StatusBadge(status: guru.status),
                          const SizedBox(width: 8),
                          _JabatanBadge(jabatan: guru.jabatan),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Divider(height: 1, color: _C.border.withOpacity(0.4)),
          const SizedBox(height: 16),

          // Detail rows
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.wc_rounded,
                    label: 'Jenis Kelamin',
                    value: guru.jenisKelamin),
                _DetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Alamat',
                    value: guru.alamat),
                _DetailRow(
                    icon: Icons.phone_rounded,
                    label: 'No. HP',
                    value: guru.noHp),
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

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _statusColor(status).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _statusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _statusColor(status),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
Color _statusColor(String status) {
  switch (status) {
    case 'Aktif':
      return const Color(0xFF065F46);
    case 'Tidak Aktif':
      return const Color(0xFFB45309);
    case 'Cuti':
      return const Color(0xFF1D4ED8);
    default:
      return _C.subtle;
  }
}

Color _jabatanColor(String jabatan) {
  switch (jabatan) {
    case 'Kepala Sekolah':
      return const Color(0xFF7C3AED);
    case 'Wakil Kepala Sekolah':
      return const Color(0xFF0369A1);
    case 'Guru':
      return const Color(0xFF6B7280);
    case 'Guru Tetap':
      return const Color(0xFF065F46);
    case 'Guru Honorer':
      return const Color(0xFFB45309);
    default:
      return _C.subtle;
  }
}

Color _jabatanBg(String jabatan) {
  switch (jabatan) {
    case 'Kepala Sekolah':
      return const Color(0xFFF5F3FF);
    case 'Wakil Kepala Sekolah':
      return const Color(0xFFE0F2FE);
    case 'Guru':
      return const Color(0xFFF3F4F6);
    case 'Guru Tetap':
      return const Color(0xFFD1FAE5);
    case 'Guru Honorer':
      return const Color(0xFFFEF3C7);
    default:
      return _C.chip;
  }
}
// ─── Form Bottom Sheet (Tambah & Edit) ────────────────────────────────────────
class _GuruFormSheet extends StatefulWidget {
  final _Guru? guru;
  final List<String> jabatanOptions;
  final void Function(_Guru) onSave;

  const _GuruFormSheet({this.guru, required this.jabatanOptions, required this.onSave});

  @override
  State<_GuruFormSheet> createState() => _GuruFormSheetState();
}

class _GuruFormSheetState extends State<_GuruFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nama, _alamat, _noHp;
  late String _jenisKelamin, _status, _jabatan;

  @override
  void initState() {
    super.initState();
    final g = widget.guru;
    _nama  = TextEditingController(text: g?.nama ?? '');
    _alamat = TextEditingController(text: g?.alamat ?? '');
    _noHp  = TextEditingController(text: g?.noHp ?? '');
    _jenisKelamin = g?.jenisKelamin ?? 'Laki-laki';
    _status  = g?.status ?? 'Aktif';
    _jabatan = g?.jabatan ?? widget.jabatanOptions.first;
  }

  @override
  void dispose() {
    _nama.dispose(); _alamat.dispose(); _noHp.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    final result = _Guru(
      id: widget.guru?.id ?? '',
      nama: _nama.text.trim(),
      nip: widget.guru?.nip ?? '',
      jenisKelamin: _jenisKelamin,
      alamat: _alamat.text.trim(),
      noHp: _noHp.text.trim(),
      status: _status,
      jabatan: _jabatan,
      avatar: widget.guru?.avatar ?? 'https://i.pravatar.cc/150?img=50',
    );
    Navigator.pop(context);
    widget.onSave(result);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.guru == null ? 'Guru berhasil ditambahkan' : 'Data berhasil diperbarui',
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
    final isEdit = widget.guru != null;

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
                          isEdit ? 'Edit Data Guru' : 'Tambah Guru Baru',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.onSurface,
                          ),
                        ),
                        Text(
                          isEdit
                              ? 'Perbarui informasi data guru'
                              : 'Isi data lengkap guru baru',
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
              _GuruFormLabel('Jenis Kelamin'),
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

              // ── Status (pill selector) ──
              _GuruFormLabel('Status'),
              const SizedBox(height: 6),
              Row(
                children: ['Aktif', 'Tidak Aktif', 'Cuti'].map((st) {
                  final isSelected = _status == st;
                  final color = st == 'Aktif'
                      ? const Color(0xFF0D9488)
                      : st == 'Tidak Aktif'
                          ? const Color(0xFFE11D48)
                          : const Color(0xFFF59E0B);
                  final icon = st == 'Aktif'
                      ? Icons.check_circle_rounded
                      : st == 'Tidak Aktif'
                          ? Icons.cancel_rounded
                          : Icons.beach_access_rounded;
                  final isLast = st == 'Cuti';
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _status = st),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color : _C.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : _C.border.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(icon,
                                  size: 16,
                                  color: isSelected ? Colors.white : color),
                              const SizedBox(height: 3),
                              Text(
                                st,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : _C.subtle,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

              // ── Nama Lengkap ──
              _GuruFormLabel('Nama Lengkap'),
              const SizedBox(height: 5),
              _GuruFormField(
                controller: _nama,
                hint: 'Nama lengkap guru',
                icon: Icons.person_rounded,
                inputType: TextInputType.name,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nama wajib diisi'
                    : null,
              ),
              const SizedBox(height: 10),

              // ── Jabatan ──
              _GuruFormLabel('Jabatan'),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _jabatan,
                    icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade400,
                        size: 18),
                    style: GoogleFonts.inter(fontSize: 12, color: _C.onSurface),
                    dropdownColor: _C.card,
                    borderRadius: BorderRadius.circular(12),
                    items: widget.jabatanOptions
                        .map((j) => DropdownMenuItem(
                              value: j,
                              child: Text(j,
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: _C.onSurface),
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _jabatan = v!),
                  ),
                ),
              ),
              const SizedBox(height: 10),


              // ── Alamat ──
              _GuruFormLabel('Alamat'),
              const SizedBox(height: 5),
              _GuruFormField(
                controller: _alamat,
                hint: 'Jl. Contoh No. 1, Kota',
                icon: Icons.location_on_rounded,
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Alamat wajib diisi'
                    : null,
              ),
              const SizedBox(height: 10),

              // ── No. HP ──
              _GuruFormLabel('No. HP'),
              const SizedBox(height: 5),
              _GuruFormField(
                controller: _noHp,
                hint: '0812-3456-7890',
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
                    isEdit ? 'Simpan Perubahan' : 'Simpan Guru',
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
class _GuruFormLabel extends StatelessWidget {
  final String text;
  const _GuruFormLabel(this.text);

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

class _GuruFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;

  const _GuruFormField({
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
        border: Border.all(
            color: _C.border.withOpacity(readOnly ? 0.4 : 0.5)),
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
              color: Colors.grey.shade400, size: 16),
          suffixIcon: readOnly
              ? Icon(Icons.lock_rounded,
                  size: 14, color: Colors.grey.shade400)
              : null,
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