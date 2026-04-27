import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';
import '../models/elearning_models.dart';
import 'tabs/materi_tab.dart';
import 'tabs/kelas_online_tab.dart';
import 'tabs/tugas_kuis_tab.dart';

// ─── Main Page ────────────────────────────────────────────────────────────────
class ELearningPage extends StatefulWidget {
  const ELearningPage({super.key});

  @override
  State<ELearningPage> createState() => _ELearningPageState();
}

class _ELearningPageState extends State<ELearningPage>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  MataPelajaran? _filterMapel;
  TipeKonten? _filterTipe;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  int _currentTab = 0;
  late List<MateriItem> _materiList;
  int _nextId = 7;

  @override
  void initState() {
    super.initState();
    _materiList = List.from(dummyMateri);
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MateriItem> get _filteredMateri {
    return _materiList.where((m) {
      // Hanya tampilkan video dan pdf di tab Materi
      if (m.tipe != TipeKonten.video && m.tipe != TipeKonten.pdf) return false;
      final matchMapel = _filterMapel == null || m.mapel == _filterMapel;
      final matchTipe = _filterTipe == null || m.tipe == _filterTipe;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          m.judul.toLowerCase().contains(q) ||
          mapelLabel(m.mapel).toLowerCase().contains(q) ||
          m.guru.toLowerCase().contains(q);
      return matchMapel && matchTipe && matchSearch;
    }).toList();
  }

  List<MateriItem> get _tugasDue =>
      _materiList.where((m) => m.isDue).toList();

  // Hanya hitung materi (video/pdf) untuk progress belajar
  int get _selesai => _materiList
      .where((m) => (m.tipe == TipeKonten.video || m.tipe == TipeKonten.pdf)
          && m.status == StatusMateri.selesai)
      .length;
  int get _total => _materiList
      .where((m) => m.tipe == TipeKonten.video || m.tipe == TipeKonten.pdf)
      .length;
  double get _progress => _total == 0 ? 0 : _selesai / _total;

  void _tambahMateri(MateriItem item) {
    final newId = 'M${_nextId++}';
    setState(() => _materiList.add(item.copyWith(id: newId)));
    // Pindah soal PENDING ke ID kuis yang baru
    if (soalDatabase.containsKey('PENDING')) {
      soalDatabase[newId] = soalDatabase.remove('PENDING')!;
    }
  }

  void _editMateri(MateriItem item) {
    setState(() {
      final idx = _materiList.indexWhere((m) => m.id == item.id);
      if (idx != -1) _materiList[idx] = item;
    });
  }

  void _updateStatusMateri(String id, StatusMateri status) {
    setState(() {
      final idx = _materiList.indexWhere((m) => m.id == id);
      if (idx != -1) {
        final old = _materiList[idx];
        _materiList[idx] = MateriItem(
          id: old.id, judul: old.judul, deskripsi: old.deskripsi,
          mapel: old.mapel, tipe: old.tipe, status: status,
          durasi: old.durasi, tanggalUpload: old.tanggalUpload,
          guru: old.guru, isDue: old.isDue, deadline: old.deadline,
          youtubeId: old.youtubeId, pdfUrl: old.pdfUrl,
          nilaiKuis: old.nilaiKuis,
        );
      }
    });
  }

  void _hapusMateri(String id, BuildContext ctx) {
    final deletedItem = _materiList.firstWhere((m) => m.id == id);
    final deletedIndex = _materiList.indexWhere((m) => m.id == id);
    bool undone = false;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _materiList.removeWhere((m) => m.id == id));
    if (!mounted) return;

    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Materi "${deletedItem.judul}" dihapus',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: Colors.white,
          onPressed: () {
            undone = true;
            if (!mounted) return;
            setState(() => _materiList.insert(deletedIndex, deletedItem));
            messenger.removeCurrentSnackBar();
          },
        ),
      ),
    );

    Timer(const Duration(seconds: 4), () {
      if (!undone) messenger.removeCurrentSnackBar();
    });
  }

  void _hapusTugasKuis(String id) {
    final deletedItem = _materiList.firstWhere((m) => m.id == id);
    final deletedIndex = _materiList.indexWhere((m) => m.id == id);
    bool undone = false;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _materiList.removeWhere((m) => m.id == id));
    if (!mounted) return;

    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '"" dihapus',
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Urungkan',
          textColor: Colors.white,
          onPressed: () {
            undone = true;
            if (!mounted) return;
            setState(() => _materiList.insert(deletedIndex, deletedItem));
            messenger.removeCurrentSnackBar();
          },
        ),
      ),
    );
    Timer(const Duration(seconds: 4), () {
      if (!undone) messenger.removeCurrentSnackBar();
    });
  }

  void _showEditTugasKuisForm(MateriItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TugasKuisFormSheet(materi: item, onSave: _editMateri),
    );
  }

  void _showTambahForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MateriFormSheet(onSave: _tambahMateri),
    );
  }

  void _showTambahTugasKuisForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TugasKuisFormSheet(onSave: _tambahMateri),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.surface,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // ── App Bar ──
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                  title: Text(
                    'E-Learning',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.green.shade900.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                  expandedHeight: topPadding + 180,
                  flexibleSpace: FlexibleSpaceBar(
                    background: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Progress Banner ──
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.18)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Progres Belajarmu',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white.withOpacity(0.7),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_selesai dari $_total materi selesai',
                                          style: GoogleFonts.manrope(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(99),
                                          child: LinearProgressIndicator(
                                            value: _progress,
                                            backgroundColor:
                                                Colors.white.withOpacity(0.2),
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                    Colors.greenAccent),
                                            minHeight: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${(_progress * 100).round()}%',
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      decoration: const BoxDecoration(color: AppColors.primary),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.greenAccent,
                        indicatorWeight: 3,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                        unselectedLabelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        tabs: const [
                          Tab(text: 'Materi'),
                          Tab(text: 'Kelas Online'),
                          Tab(text: 'Tugas & Kuis'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 0: Materi
                  MateriTab(
                    filteredMateri: _filteredMateri,
                    filterMapel: _filterMapel,
                    filterTipe: _filterTipe,
                    searchController: _searchController,
                    onSearchChanged: (v) => setState(() => _searchQuery = v),
                    onMapelFilter: (m) => setState(() => _filterMapel = m),
                    onTipeFilter: (t) => setState(() => _filterTipe = t),
                    onEdit: (item) => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MateriFormSheet(
                        materi: item,
                        onSave: _editMateri,
                      ),
                    ),
                    onHapus: (id) => _hapusMateri(id, context),
                    onStatusUpdate: _updateStatusMateri,
                  ),
                  // Tab 1: Kelas Online
                  const KelasOnlineTab(),
                  // Tab 2: Tugas & Kuis
                  TugasKuisTab(
                    allMateri: _materiList,
                    onTambah: _tambahMateri,
                    onEdit: _showEditTugasKuisForm,
                    onHapus: _hapusTugasKuis,
                    onStatusUpdate: _updateStatusMateri,
                  ),
                ],
              ),
            ),

            // ── Bottom Nav ──
            Align(
              alignment: Alignment.bottomCenter,
              child: SiakadBottomNavBar(
                selectedIndex: 0,
                onTap: (i) {
                  if (i != 0) Navigator.pop(context);
                },
              ),
            ),

            // ── FAB Tambah Materi (tab 0) ──
            if (_currentTab == 0)
              Positioned(
                bottom: 100 + MediaQuery.of(context).padding.bottom,
                right: 20,
                child: FloatingActionButton(
                  onPressed: _showTambahForm,
                  backgroundColor: AppColors.primary,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 26),
                ),
              ),

            // ── FAB Tambah Kuis/Tugas (tab 2) ──
            if (_currentTab == 2)
              Positioned(
                bottom: 100 + MediaQuery.of(context).padding.bottom,
                right: 20,
                child: FloatingActionButton(
                  onPressed: _showTambahTugasKuisForm,
                  backgroundColor: AppColors.purple,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.add_rounded,
                      color: Colors.white, size: 26),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
