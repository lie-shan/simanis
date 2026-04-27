import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';
import 'dashboard_page.dart';
import 'presensi_page.dart';
import 'pengumuman_page.dart';
import 'akun_page.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _DPC {
  static const primary = Color(0xFF004D34);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFF5F3FF);
  static const purpleBorder = Color(0xFFDDD6FE);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF0F2F1);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline = Color(0xFF6F7A72);
  static const outlineVariant = Color(0xFFBEC9C1);
}

// ─── Models ───────────────────────────────────────────────────────────────────
class _UserData {
  final String nama;
  final String id;
  final String? avatarUrl;
  final String kelas;
  final String status;
  final String role;
  final String telepon;
  final String email;
  final String password;
  final String jenisKelamin;
  final String alamat;
  final bool aktif;

  const _UserData({
    required this.nama,
    required this.id,
    this.avatarUrl,
    required this.kelas,
    required this.status,
    required this.role,
    required this.telepon,
    required this.email,
    required this.password,
    required this.jenisKelamin,
    required this.alamat,
    this.aktif = true,
  });

  _UserData copyWith({
    String? nama,
    String? id,
    String? avatarUrl,
    String? kelas,
    String? status,
    String? role,
    String? telepon,
    String? email,
    String? password,
    String? jenisKelamin,
    String? alamat,
    bool? aktif,
  }) {
    return _UserData(
      nama: nama ?? this.nama,
      id: id ?? this.id,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      kelas: kelas ?? this.kelas,
      status: status ?? this.status,
      role: role ?? this.role,
      telepon: telepon ?? this.telepon,
      email: email ?? this.email,
      password: password ?? this.password,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      alamat: alamat ?? this.alamat,
      aktif: aktif ?? this.aktif,
    );
  }
}

// ─── Data Pengguna Page ───────────────────────────────────────────────────────
class DataPenggunaPage extends StatefulWidget {
  const DataPenggunaPage({super.key});

  @override
  State<DataPenggunaPage> createState() => _DataPenggunaPageState();
}

class _DataPenggunaPageState extends State<DataPenggunaPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;
  String _searchQuery = '';
  String? _filterKelas;
  final _searchCtrl = TextEditingController();
  int _nextId = 100;

  final List<String> _kelasList = [
    'Semua',
    'VII-A',
    'VII-B',
    'VIII-A',
    'VIII-B',
    'IX-A',
    'IX-B',
  ];

  List<_UserData> _siswaDummy = [
    _UserData(
      nama: 'Ahmad Fauzi',
      id: 'NIS-20230001',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      kelas: 'VII-A',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '081234567890',
      email: 'ahmad.fauzi@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Merdeka No. 45, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Aisyah Putri',
      id: 'NIS-20230002',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      kelas: 'VII-A',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '082198765432',
      email: 'aisyah.putri@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Sudirman No. 12, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Budi Santoso',
      id: 'NIS-20230003',
      kelas: 'VII-B',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '083112233445',
      email: 'budi.santoso@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Diponegoro No. 77, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Dewi Rahmawati',
      id: 'NIS-20230004',
      kelas: 'VIII-A',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '085799887766',
      email: 'dewi.rahmawati@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Gatot Subroto No. 3, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Farhan Maulana',
      id: 'NIS-20230005',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
      kelas: 'VIII-A',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '087800112233',
      email: 'farhan.maulana@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Ahmad Yani No. 20, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Gita Permatasari',
      id: 'NIS-20230006',
      avatarUrl: 'https://i.pravatar.cc/150?img=9',
      kelas: 'VIII-B',
      status: 'Tidak Aktif',
      role: 'Siswa',
      telepon: '089654321098',
      email: 'gita.permatasari@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Riau No. 55, Bandung',
      aktif: false,
    ),
    _UserData(
      nama: 'Hendra Kusuma',
      id: 'NIS-20230007',
      kelas: 'IX-A',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '081345678901',
      email: 'hendra.kusuma@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Pasteur No. 8, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Indah Sari',
      id: 'NIS-20230008',
      avatarUrl: 'https://i.pravatar.cc/150?img=4',
      kelas: 'IX-A',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '082233445566',
      email: 'indah.sari@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Cihampelas No. 100, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Joko Widodo',
      id: 'NIS-20230009',
      kelas: 'IX-B',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '085611223344',
      email: 'joko.widodo@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Ir. H. Juanda No. 30, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Kartika Dewi',
      id: 'NIS-20230010',
      avatarUrl: 'https://i.pravatar.cc/150?img=7',
      kelas: 'IX-B',
      status: 'Aktif',
      role: 'Siswa',
      telepon: '081700998877',
      email: 'kartika.dewi@siswa.siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Siliwangi No. 14, Bandung',
      aktif: true,
    ),
  ];

  final List<_UserData> _guruDummy = [
    _UserData(
      nama: 'Ust. Ahmad Fathoni, S.Pd',
      id: 'NIP-197501012005011001',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      kelas: 'Fiqih Ibadah',
      status: 'Aktif',
      role: 'Guru',
      telepon: '081298765432',
      email: 'ahmad.fathoni@guru.siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Kebon Jati No. 22, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Ustadzah Siti Aminah, S.Pd.I',
      id: 'NIP-198003152006022003',
      avatarUrl: 'https://i.pravatar.cc/150?img=6',
      kelas: 'Bahasa Arab',
      status: 'Aktif',
      role: 'Guru',
      telepon: '085612345678',
      email: 'siti.aminah@guru.siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Setiabudi No. 5, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Ust. Hafidz Mubarok, Lc',
      id: 'NIP-198507272010011004',
      avatarUrl: 'https://i.pravatar.cc/150?img=15',
      kelas: "Tahfidz Al-Qur'an",
      status: 'Aktif',
      role: 'Guru',
      telepon: '089900112233',
      email: 'hafidz.mubarok@guru.siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Dago No. 88, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Bu Dewi Rahmawati, S.Pd',
      id: 'NIP-199001012015012005',
      kelas: 'Matematika',
      status: 'Aktif',
      role: 'Guru',
      telepon: '082100223344',
      email: 'dewi.r@guru.siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Tubagus Ismail No. 9, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Pak Budi Santoso, M.Pd',
      id: 'NIP-196803041995031002',
      kelas: 'Bahasa Indonesia',
      status: 'Tidak Aktif',
      role: 'Guru',
      telepon: '081300445566',
      email: 'budi.santoso@guru.siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Cipaganti No. 16, Bandung',
      aktif: false,
    ),
  ];

  final List<_UserData> _adminDummy = [
    _UserData(
      nama: 'Rizky Aditya, S.Kom',
      id: 'ADM-001',
      avatarUrl: 'https://i.pravatar.cc/150?img=13',
      kelas: 'Super Admin',
      status: 'Aktif',
      role: 'Admin',
      telepon: '081312345678',
      email: 'rizky.aditya@siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Braga No. 10, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Lestari Handayani',
      id: 'ADM-002',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
      kelas: 'Admin Akademik',
      status: 'Aktif',
      role: 'Admin',
      telepon: '082398765432',
      email: 'lestari.h@siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Veteran No. 25, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Wahyu Prasetyo',
      id: 'ADM-003',
      kelas: 'Admin Kesiswaan',
      status: 'Tidak Aktif',
      role: 'Admin',
      telepon: '089611223311',
      email: 'wahyu.p@siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Cihampelas No. 60, Bandung',
      aktif: false,
    ),
  ];

  final List<_UserData> _bendaharaDummy = [
    _UserData(
      nama: 'Sari Melati, S.E',
      id: 'BND-001',
      avatarUrl: 'https://i.pravatar.cc/150?img=2',
      kelas: 'Bendahara Utama',
      status: 'Aktif',
      role: 'Bendahara',
      telepon: '081400556677',
      email: 'sari.melati@siakad.id',
      password: 'password123',
      jenisKelamin: 'Perempuan',
      alamat: 'Jl. Aceh No. 18, Bandung',
      aktif: true,
    ),
    _UserData(
      nama: 'Agus Firmansyah',
      id: 'BND-002',
      kelas: 'Bendahara Pembantu',
      status: 'Aktif',
      role: 'Bendahara',
      telepon: '085500112266',
      email: 'agus.f@siakad.id',
      password: 'password123',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jl. Karapitan No. 33, Bandung',
      aktif: true,
    ),
  ];

  List<_UserData> get _filteredSiswa {
    List<_UserData> result = List.from(_siswaDummy);
    if (_filterKelas != null && _filterKelas != 'Semua') {
      result = result.where((u) => u.kelas == _filterKelas).toList();
    }
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((u) =>
              u.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.id.contains(_searchQuery))
          .toList();
    }
    return result;
  }

  List<_UserData> get _filteredGuru {
    List<_UserData> result = List.from(_guruDummy);
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((u) =>
              u.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.id.contains(_searchQuery) ||
              u.kelas.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  List<_UserData> get _filteredAdmin {
    List<_UserData> result = List.from(_adminDummy);
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((u) =>
              u.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.id.contains(_searchQuery) ||
              u.kelas.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  List<_UserData> get _filteredBendahara {
    List<_UserData> result = List.from(_bendaharaDummy);
    if (_searchQuery.isNotEmpty) {
      result = result
          .where((u) =>
              u.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.id.contains(_searchQuery) ||
              u.kelas.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _activeTab = _tabController.index;
          _filterKelas = null;
          _searchQuery = '';
          _searchCtrl.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── CRUD Functions ─────────────────────────────────────────────────────────
  void _tambahPengguna(_UserData user) {
    setState(() {
      if (user.role == 'Siswa') {
        _siswaDummy.add(user.copyWith(id: 'NIS-${_nextId++}'));
      } else if (user.role == 'Guru') {
        _guruDummy.add(user.copyWith(id: 'GR-${_nextId++}'));
      } else if (user.role == 'Admin') {
        _adminDummy.add(user.copyWith(id: 'ADM-${_nextId++}'));
      } else if (user.role == 'Bendahara') {
        _bendaharaDummy.add(user.copyWith(id: 'BND-${_nextId++}'));
      }
    });
  }

  void _editPengguna(_UserData user) {
    setState(() {
      if (user.role == 'Siswa') {
        final idx = _siswaDummy.indexWhere((u) => u.id == user.id);
        if (idx != -1) _siswaDummy[idx] = user;
      } else if (user.role == 'Guru') {
        final idx = _guruDummy.indexWhere((u) => u.id == user.id);
        if (idx != -1) _guruDummy[idx] = user;
      } else if (user.role == 'Admin') {
        final idx = _adminDummy.indexWhere((u) => u.id == user.id);
        if (idx != -1) _adminDummy[idx] = user;
      } else if (user.role == 'Bendahara') {
        final idx = _bendaharaDummy.indexWhere((u) => u.id == user.id);
        if (idx != -1) _bendaharaDummy[idx] = user;
      }
    });
  }

  void _hapusPengguna(String id, String role) {
    setState(() {
      if (role == 'Siswa') {
        _siswaDummy.removeWhere((u) => u.id == id);
      } else if (role == 'Guru') {
        _guruDummy.removeWhere((u) => u.id == id);
      } else if (role == 'Admin') {
        _adminDummy.removeWhere((u) => u.id == id);
      } else if (role == 'Bendahara') {
        _bendaharaDummy.removeWhere((u) => u.id == id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _DPC.surface,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildTabBar(),
                if (_activeTab == 0) _buildKelasFilter(),
                Expanded(child: _buildContent()),
              ],
            ),
            
            // Floating Action Button
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => _showPilihRole(context),
                backgroundColor: _DPC.purple,
                foregroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.add_rounded, size: 28),
              ),
            ),
            
            // Bottom Navigation Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: SiakadBottomNavBar(
                selectedIndex: 1, // Presensi selected karena Data Pengguna diakses dari menu Presensi
                onTap: (i) {
                  if (i == 0) {
                    // Beranda - ke Dashboard
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) => const DashboardPage(),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 250),
                      ),
                    );
                  } else if (i == 1) {
                    // Presensi - kembali ke halaman Presensi
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) => const PresensiPage(),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 250),
                      ),
                    );
                  } else if (i == 3) {
                    // Info/Pengumuman
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) => const PengumumanPage(),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 250),
                      ),
                    );
                  } else if (i == 4) {
                    // Akun
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, animation, __) => const AkunPage(),
                        transitionsBuilder: (_, animation, __, child) =>
                            FadeTransition(opacity: animation, child: child),
                        transitionDuration: const Duration(milliseconds: 250),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final totalSiswa = _siswaDummy.length;
    final totalGuru = _guruDummy.length;
    final totalAdmin = _adminDummy.length;
    final totalBendahara = _bendaharaDummy.length;
    final totalSemua = totalSiswa + totalGuru + totalAdmin + totalBendahara;
    final aktif =
        _siswaDummy.where((u) => u.aktif).length +
            _guruDummy.where((u) => u.aktif).length +
            _adminDummy.where((u) => u.aktif).length +
            _bendaharaDummy.where((u) => u.aktif).length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFF8B5CF6)],
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
                      'Data Pengguna',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  // Action buttons
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
                            content: Text('Mengekspor data pengguna...',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600)),
                            backgroundColor: _DPC.purple,
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
                  _statCard(Icons.groups_rounded, '$totalSemua', 'Total',
                      const Color(0xFFDDD6FE)),
                  const SizedBox(width: 10),
                  _statCard(Icons.school_rounded, '$totalGuru', 'Guru',
                      const Color(0xFFDDD6FE)),
                  const SizedBox(width: 10),
                  _statCard(Icons.check_circle_rounded, '$aktif',
                      'Aktif', const Color(0xFFDDD6FE)),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      IconData icon, String value, String label, Color iconBg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1,
                    )),
                Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ─────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: _DPC.surfaceLowest,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.inter(fontSize: 13, color: _DPC.onSurface),
        decoration: InputDecoration(
          hintText: _activeTab == 0
              ? 'Cari nama atau NIS siswa...'
              : _activeTab == 1
                  ? 'Cari nama, NIP, atau mata pelajaran...'
                  : _activeTab == 2
                      ? 'Cari nama atau ID admin...'
                      : 'Cari nama atau ID bendahara...',

          hintStyle: GoogleFonts.inter(
              fontSize: 13,
              color: _DPC.outline.withValues(alpha: 0.7)),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: _DPC.outline),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: _DPC.outline),
                )
              : null,
          isDense: true,
          filled: true,
          fillColor: _DPC.surfaceLow,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: _DPC.outlineVariant.withValues(alpha: 0.3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _DPC.purple, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      color: _DPC.surfaceLowest,
      child: Column(
        children: [
          Divider(
              height: 1,
              color: _DPC.outlineVariant.withValues(alpha: 0.3)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _DPC.surfaceLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _tabBtn(0, Icons.person_rounded, 'Siswa'),
                  const SizedBox(width: 4),
                  _tabBtn(1, Icons.school_rounded, 'Guru'),
                  const SizedBox(width: 4),
                  _tabBtn(2, Icons.admin_panel_settings_rounded, 'Admin'),
                  const SizedBox(width: 4),
                  _tabBtn(3, Icons.account_balance_wallet_rounded, 'Bendahara'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(int index, IconData icon, String label) {
    final active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() => _activeTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            color: active ? _DPC.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: _DPC.purple.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color:
                      active ? Colors.white : _DPC.onSurfaceVariant),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? Colors.white
                        : _DPC.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }

  // ── Kelas Filter (Siswa only) ───────────────────────────────────────────────
  Widget _buildKelasFilter() {
    return Container(
      color: _DPC.surfaceLowest,
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _kelasList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final k = _kelasList[i];
          final isSelected =
              (k == 'Semua' && _filterKelas == null) ||
                  k == _filterKelas;
          return GestureDetector(
            onTap: () => setState(
                () => _filterKelas = k == 'Semua' ? null : k),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? _DPC.purple : _DPC.surfaceLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? _DPC.purple
                      : _DPC.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                k,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : _DPC.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Content ────────────────────────────────────────────────────────────────
  Widget _buildContent() {
    final list = _activeTab == 0
        ? _filteredSiswa
        : _activeTab == 1
            ? _filteredGuru
            : _activeTab == 2
                ? _filteredAdmin
                : _filteredBendahara;

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 72, color: _DPC.outlineVariant),
            const SizedBox(height: 16),
            Text('Tidak ada data ditemukan',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _DPC.onSurfaceVariant,
                )),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _buildUserCard(ctx, list[i]),
    );
  }

  // ── User Card ──────────────────────────────────────────────────────────────
  Widget _buildUserCard(BuildContext ctx, _UserData user) {
    return Container(
      decoration: BoxDecoration(
        color: _DPC.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
            color: _DPC.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showDetailSheet(ctx, user),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    _buildAvatar(user),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: user.aktif
                              ? const Color(0xFF22C55E)
                              : _DPC.outlineVariant,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: _DPC.surfaceLowest, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nama,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _DPC.onSurface,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.id,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: _DPC.outline),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _chip(
                            user.kelas,
                            _DPC.purple.withValues(alpha: 0.1),
                            _DPC.purple,
                          ),
                          const SizedBox(width: 6),
                          _chip(
                            user.jenisKelamin == 'Laki-laki'
                                ? '♂ L'
                                : '♀ P',
                            user.jenisKelamin == 'Laki-laki'
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFDF2F8),
                            user.jenisKelamin == 'Laki-laki'
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFDB2777),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status & arrow
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: user.aktif
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.aktif ? 'Aktif' : 'Nonaktif',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: user.aktif
                              ? const Color(0xFF166534)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Icon(Icons.chevron_right_rounded,
                        size: 18, color: _DPC.outlineVariant),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(_UserData user) {
    if (user.avatarUrl != null) {
      return CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(user.avatarUrl!),
        backgroundColor: _DPC.surfaceLow,
      );
    }
    final initials = user.nama
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: 26,
      backgroundColor: _DPC.purpleLight,
      child: Text(initials,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _DPC.purple,
          )),
    );
  }

  Widget _chip(String label, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }

  // ── Detail Bottom Sheet ────────────────────────────────────────────────────
  void _showDetailSheet(BuildContext ctx, _UserData user) {
    final bottomPad = MediaQuery.of(ctx).viewPadding.bottom;
    
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          decoration: BoxDecoration(
            color: _DPC.surfaceLowest,
            borderRadius: const BorderRadius.all(Radius.circular(24)),
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
                  color: _DPC.outlineVariant,
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
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: user.aktif 
                              ? _DPC.purple.withOpacity(0.5)
                              : _DPC.outlineVariant,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: user.aktif
                                ? _DPC.purple.withOpacity(0.2)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user.avatarUrl != null
                            ? Image.network(
                                user.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: _DPC.purpleLight,
                                  child: Center(
                                    child: Text(
                                      user.nama
                                          .split(' ')
                                          .where((e) => e.isNotEmpty)
                                          .take(2)
                                          .map((e) => e[0].toUpperCase())
                                          .join(),
                                      style: GoogleFonts.manrope(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: _DPC.purple,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: _DPC.purpleLight,
                                child: Center(
                                  child: Text(
                                    user.nama
                                        .split(' ')
                                        .where((e) => e.isNotEmpty)
                                        .take(2)
                                        .map((e) => e[0].toUpperCase())
                                        .join(),
                                    style: GoogleFonts.manrope(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: _DPC.purple,
                                    ),
                                  ),
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
                            user.nama,
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _DPC.onSurface,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _chip(user.role, _DPC.purpleLight, _DPC.purple),
                              const SizedBox(width: 6),
                              _chip(
                                user.aktif ? 'Aktif' : 'Nonaktif',
                                user.aktif
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFFEE2E2),
                                user.aktif
                                    ? const Color(0xFF166534)
                                    : const Color(0xFF991B1B),
                              ),
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
              Divider(
                  height: 1,
                  color: _DPC.outlineVariant.withOpacity(0.4)),
              const SizedBox(height: 16),
              
              // Detail rows
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _detailRow(Icons.badge_rounded, user.id.split('-')[0].toUpperCase(), user.id),
                    _detailRow(Icons.class_rounded, 'Kelas / Mapel', user.kelas),
                    _detailRow(Icons.wc_rounded, 'Jenis Kelamin', user.jenisKelamin),
                    _detailRow(Icons.phone_rounded, 'No. HP', user.telepon),
                    _detailRow(Icons.email_rounded, 'Email', user.email),
                    _detailRow(Icons.location_on_rounded, 'Alamat', user.alamat),
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
                        onPressed: () {
                          Navigator.pop(ctx);
                          _konfirmasiHapus(ctx, user);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFE11D48)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.delete_rounded,
                            size: 16, color: Color(0xFFE11D48)),
                        label: Text('Hapus',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFE11D48))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showForm(ctx, user, role: user.role);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _DPC.purple,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit_rounded,
                            size: 16, color: Colors.white),
                        label: Text('Edit Data',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showForm(BuildContext context, _UserData? user, {String? role}) {
    // Tentukan options berdasarkan role
    List<String> options;
    List<String> namaOptions = [];
    final selectedRole = role ?? user?.role ?? 'Siswa';
    
    if (selectedRole == 'Siswa') {
      options = _kelasList.where((k) => k != 'Semua').toList();
      // Ambil nama siswa dari data siswa page atau buat list nama siswa
      namaOptions = [
        'Ahmad Fauzi',
        'Aisyah Putri',
        'Budi Santoso',
        'Dewi Rahmawati',
        'Farhan Maulana',
        'Gita Permatasari',
        'Hendra Kusuma',
        'Indah Sari',
        'Joko Widodo',
        'Kartika Dewi',
      ];
    } else if (selectedRole == 'Guru') {
      options = [
        'Fiqih Ibadah',
        'Bahasa Arab',
        "Tahfidz Al-Qur'an",
        'Matematika',
        'Bahasa Indonesia',
        'IPA',
        'IPS',
        'Bahasa Inggris',
      ];
      namaOptions = [
        'Ust. Ahmad Fathoni, S.Pd',
        'Ustadzah Siti Aminah, S.Pd.I',
        'Ust. Hafidz Mubarok, Lc',
        'Dewi Rahmawati, S.Pd',
        'Budi Santoso, S.Pd',
      ];
    } else if (selectedRole == 'Admin') {
      options = [
        'Super Admin',
      ];
    } else if (selectedRole == 'Bendahara') {
      options = [
        'Bendahara Utama',
        'Bendahara Pembantu',
      ];
    } else {
      options = _kelasList.where((k) => k != 'Semua').toList();
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserFormSheet(
        user: user,
        role: selectedRole,
        kelasOptions: options,
        namaOptions: namaOptions,
        onSave: (data) {
          if (user == null) {
            _tambahPengguna(data);
          } else {
            _editPengguna(data);
          }
        },
      ),
    );
  }

  void _showPilihRole(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: _DPC.surfaceLowest,
          borderRadius: const BorderRadius.all(Radius.circular(24)),
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
                color: _DPC.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Pengguna Baru',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _DPC.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih jenis pengguna yang ingin ditambahkan',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _DPC.outline,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Role cards
                  _roleCard(
                    context,
                    Icons.person_rounded,
                    'Siswa',
                    'Tambah data siswa baru',
                    const Color(0xFF2563EB),
                    const Color(0xFFEFF6FF),
                  ),
                  const SizedBox(height: 12),
                  _roleCard(
                    context,
                    Icons.school_rounded,
                    'Guru',
                    'Tambah data guru baru',
                    _DPC.purple,
                    _DPC.purpleLight,
                  ),
                  const SizedBox(height: 12),
                  _roleCard(
                    context,
                    Icons.admin_panel_settings_rounded,
                    'Admin',
                    'Tambah data admin baru',
                    const Color(0xFFEA580C),
                    const Color(0xFFFFF7ED),
                  ),
                  const SizedBox(height: 12),
                  _roleCard(
                    context,
                    Icons.account_balance_wallet_rounded,
                    'Bendahara',
                    'Tambah data bendahara baru',
                    const Color(0xFF0D9488),
                    const Color(0xFFF0FDFA),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, IconData icon, String role,
      String subtitle, Color color, Color bg) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showForm(context, null, role: role);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _DPC.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _DPC.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: _DPC.outlineVariant, size: 24),
          ],
        ),
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context, _UserData user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Pengguna',
            style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
        content: Text(
          'Yakin ingin menghapus data "${user.nama}"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.inter(
                    color: _DPC.outline, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _hapusPengguna(user.id, user.role);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data ${user.nama} berhasil dihapus',
                      style: GoogleFonts.inter()),
                  backgroundColor: const Color(0xFFE11D48),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: Text('Hapus',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      Color color, Color bg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _DPC.outline,
                        fontWeight: FontWeight.w500,
                        height: 1.3)),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _DPC.onSurface,
                        height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _DPC.surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _DPC.purple, size: 17),
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
                    color: _DPC.outline,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _DPC.onSurface,
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
class _UserFormSheet extends StatefulWidget {
  final _UserData? user;
  final String role;
  final List<String> kelasOptions;
  final List<String> namaOptions;
  final void Function(_UserData) onSave;

  const _UserFormSheet({
    this.user,
    required this.role,
    required this.kelasOptions,
    required this.namaOptions,
    required this.onSave,
  });

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nama, _telepon, _email, _password, _alamat;
  late String _kelas, _jenisKelamin, _namaSelected;
  late bool _aktif;
  late bool _useDropdownNama;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    
    // Tentukan apakah menggunakan dropdown untuk nama (Siswa & Guru)
    _useDropdownNama = widget.namaOptions.isNotEmpty;
    
    if (_useDropdownNama) {
      // Jika edit dan nama ada dalam list, gunakan nama tersebut
      if (u?.nama != null && widget.namaOptions.contains(u!.nama)) {
        _namaSelected = u.nama;
      } else {
        _namaSelected = widget.namaOptions.first;
      }
      _nama = TextEditingController(); // Tidak digunakan untuk dropdown
    } else {
      _nama = TextEditingController(text: u?.nama ?? '');
      _namaSelected = '';
    }
    
    _telepon = TextEditingController(text: u?.telepon ?? '');
    _email = TextEditingController(text: u?.email ?? '');
    _password = TextEditingController(text: u?.password ?? '');
    _alamat = TextEditingController(text: u?.alamat ?? '');
    
    // Pastikan nilai _kelas ada dalam kelasOptions
    if (u?.kelas != null && widget.kelasOptions.contains(u!.kelas)) {
      _kelas = u.kelas;
    } else {
      _kelas = widget.kelasOptions.first;
    }
    
    _jenisKelamin = u?.jenisKelamin ?? 'Laki-laki';
    _aktif = u?.aktif ?? true;
  }

  @override
  void dispose() {
    _nama.dispose();
    _telepon.dispose();
    _email.dispose();
    _password.dispose();
    _alamat.dispose();
    super.dispose();
  }

  String get _roleLabel {
    switch (widget.role) {
      case 'Siswa':
        return 'Siswa';
      case 'Guru':
        return 'Guru';
      case 'Admin':
        return 'Admin';
      case 'Bendahara':
        return 'Bendahara';
      default:
        return 'Pengguna';
    }
  }

  String get _kelasLabel {
    switch (widget.role) {
      case 'Siswa':
        return 'Kelas';
      case 'Guru':
        return 'Mata Pelajaran';
      case 'Admin':
        return 'Divisi';
      case 'Bendahara':
        return 'Jabatan';
      default:
        return 'Kelas / Mapel';
    }
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;
    final result = _UserData(
      id: widget.user?.id ?? '',
      nama: _useDropdownNama ? _namaSelected : _nama.text.trim(),
      kelas: _kelas,
      jenisKelamin: _jenisKelamin,
      role: widget.role,
      telepon: _telepon.text.trim(),
      email: _email.text.trim(),
      password: _password.text.trim(),
      alamat: _alamat.text.trim(),
      status: _aktif ? 'Aktif' : 'Tidak Aktif',
      aktif: _aktif,
      avatarUrl: widget.user?.avatarUrl,
    );
    Navigator.pop(context);
    widget.onSave(result);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          widget.user == null
              ? '$_roleLabel berhasil ditambahkan'
              : 'Data berhasil diperbarui',
          style: GoogleFonts.inter()),
      backgroundColor: _DPC.purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final keyboardPad = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.user != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(16, 16, 16, 12 + bottomPad + keyboardPad),
      decoration: BoxDecoration(
        color: _DPC.surfaceLowest,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _DPC.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                isEdit ? 'Edit Data $_roleLabel' : 'Tambah $_roleLabel Baru',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _DPC.onSurface,
                ),
              ),
              Text(
                isEdit
                    ? 'Perbarui informasi data $_roleLabel'
                    : 'Isi data lengkap $_roleLabel baru',
                style: GoogleFonts.inter(fontSize: 11, color: _DPC.outline),
              ),
              const SizedBox(height: 16),

              // Jenis Kelamin
              Text('Jenis Kelamin',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DPC.onSurface)),
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
                  return Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: jk == 'Perempuan' ? 0 : 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _jenisKelamin = jk),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color : _DPC.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : _DPC.outlineVariant.withOpacity(0.5),
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
                                  color: isSelected ? Colors.white : _DPC.outline,
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

              // Status
              Text('Status',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DPC.onSurface)),
              const SizedBox(height: 6),
              Row(
                children: [true, false].map((aktif) {
                  final isSelected = _aktif == aktif;
                  final label = aktif ? 'Aktif' : 'Tidak Aktif';
                  final color = aktif
                      ? const Color(0xFF0D9488)
                      : const Color(0xFFF59E0B);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: aktif ? 8 : 0),
                      child: GestureDetector(
                        onTap: () => setState(() => _aktif = aktif),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color : _DPC.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : _DPC.outlineVariant.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            label,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : _DPC.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Nama
              Text('Nama Lengkap',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DPC.onSurface)),
              const SizedBox(height: 5),
              _useDropdownNama
                  ? Container(
                      decoration: BoxDecoration(
                        color: _DPC.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _DPC.outlineVariant.withOpacity(0.5)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _namaSelected,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: _DPC.outline),
                          style: GoogleFonts.inter(
                              fontSize: 13, color: _DPC.onSurface),
                          dropdownColor: _DPC.surfaceLowest,
                          borderRadius: BorderRadius.circular(12),
                          items: widget.namaOptions
                              .map((n) => DropdownMenuItem(
                                    value: n,
                                    child: Text(n),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _namaSelected = v!),
                        ),
                      ),
                    )
                  : TextFormField(
                      controller: _nama,
                      decoration: InputDecoration(
                        hintText: 'Nama lengkap',
                        filled: true,
                        fillColor: _DPC.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: _DPC.outlineVariant.withOpacity(0.5)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: _DPC.outlineVariant.withOpacity(0.5)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      style: GoogleFonts.inter(fontSize: 13),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama wajib diisi'
                          : null,
                    ),
              const SizedBox(height: 10),

              // Kelas/Mapel/Divisi/Jabatan
              Text(_kelasLabel,
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DPC.onSurface)),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: _DPC.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _DPC.outlineVariant.withOpacity(0.5)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _kelas,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: _DPC.outline),
                    style: GoogleFonts.inter(
                        fontSize: 13, color: _DPC.onSurface),
                    dropdownColor: _DPC.surfaceLowest,
                    borderRadius: BorderRadius.circular(12),
                    items: widget.kelasOptions
                        .map((k) => DropdownMenuItem(
                              value: k,
                              child: Text(k),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _kelas = v!),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Telepon
              Text('No. HP',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DPC.onSurface)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _telepon,
                decoration: InputDecoration(
                  hintText: '08123456789',
                  filled: true,
                  fillColor: _DPC.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _DPC.outlineVariant.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _DPC.outlineVariant.withOpacity(0.5)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: GoogleFonts.inter(fontSize: 13),
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'No. HP wajib diisi'
                    : null,
              ),
              const SizedBox(height: 10),

              // Email
              Text('Email',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DPC.onSurface)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _email,
                decoration: InputDecoration(
                  hintText: 'email@example.com',
                  filled: true,
                  fillColor: _DPC.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _DPC.outlineVariant.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _DPC.outlineVariant.withOpacity(0.5)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: GoogleFonts.inter(fontSize: 13),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 10),

              // Password
              Text('Password',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DPC.onSurface)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  filled: true,
                  fillColor: _DPC.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _DPC.outlineVariant.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _DPC.outlineVariant.withOpacity(0.5)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      size: 20,
                      color: _DPC.outline,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                style: GoogleFonts.inter(fontSize: 13),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Password wajib diisi'
                    : v.trim().length < 6
                        ? 'Password minimal 6 karakter'
                        : null,
              ),
              const SizedBox(height: 10),

              // Alamat
              Text('Alamat',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _DPC.onSurface)),
              const SizedBox(height: 5),
              TextFormField(
                controller: _alamat,
                decoration: InputDecoration(
                  hintText: 'Alamat lengkap',
                  filled: true,
                  fillColor: _DPC.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _DPC.outlineVariant.withOpacity(0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: _DPC.outlineVariant.withOpacity(0.5)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                style: GoogleFonts.inter(fontSize: 13),
                maxLines: 2,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Alamat wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _DPC.outlineVariant),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Batal',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _DPC.outline)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _simpan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _DPC.purple,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isEdit ? 'Simpan' : 'Tambah',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
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
}
