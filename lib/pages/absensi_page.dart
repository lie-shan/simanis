import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/scan_modal.dart';
import 'pengumuman_page.dart';
import 'akun_page.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _C {
  static const primary          = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
  static const primaryFixed     = Color(0xFFA0F4CA);
  static const onPrimaryFixed   = Color(0xFF002114);
  static const surface          = Color(0xFFF8F9FA);
  static const surfaceLowest    = Color(0xFFFFFFFF);
  static const surfaceLow       = Color(0xFFF0F2F1);
  static const onSurface        = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline          = Color(0xFF6F7A72);
  static const outlineVariant   = Color(0xFFBEC9C1);
}

// ─── Attendance Status ────────────────────────────────────────────────────────
enum AttendanceStatus { hadir, sakit, izin, alpa, belumDiisi }

extension AttendanceStatusExt on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.hadir:      return 'Hadir';
      case AttendanceStatus.sakit:      return 'Sakit';
      case AttendanceStatus.izin:       return 'Izin';
      case AttendanceStatus.alpa:       return 'Alpa';
      case AttendanceStatus.belumDiisi: return '–';
    }
  }

  String get shortLabel {
    switch (this) {
      case AttendanceStatus.hadir:      return 'H';
      case AttendanceStatus.sakit:      return 'S';
      case AttendanceStatus.izin:       return 'I';
      case AttendanceStatus.alpa:       return 'A';
      case AttendanceStatus.belumDiisi: return '–';
    }
  }

  Color get bg {
    switch (this) {
      case AttendanceStatus.hadir:      return const Color(0xFFD1FAE5);
      case AttendanceStatus.sakit:      return const Color(0xFFFEF3C7);
      case AttendanceStatus.izin:       return const Color(0xFFDBEAFE);
      case AttendanceStatus.alpa:       return const Color(0xFFFEE2E2);
      case AttendanceStatus.belumDiisi: return const Color(0xFFE7E8E9);
    }
  }

  Color get fg {
    switch (this) {
      case AttendanceStatus.hadir:      return const Color(0xFF065F46);
      case AttendanceStatus.sakit:      return const Color(0xFF92400E);
      case AttendanceStatus.izin:       return const Color(0xFF1E40AF);
      case AttendanceStatus.alpa:       return const Color(0xFF991B1B);
      case AttendanceStatus.belumDiisi: return const Color(0xFF6F7A72);
    }
  }

  Color get border {
    switch (this) {
      case AttendanceStatus.hadir:      return const Color(0xFF6EE7B7);
      case AttendanceStatus.sakit:      return const Color(0xFFFCD34D);
      case AttendanceStatus.izin:       return const Color(0xFF93C5FD);
      case AttendanceStatus.alpa:       return const Color(0xFFFCA5A5);
      case AttendanceStatus.belumDiisi: return const Color(0xFFBEC9C1);
    }
  }
}

// ─── Student Model ────────────────────────────────────────────────────────────
class StudentAttendance {
  final String name;
  final String nis;
  final String? avatarUrl;
  final String? initials;
  AttendanceStatus status;

  StudentAttendance({
    required this.name,
    required this.nis,
    this.avatarUrl,
    this.initials,
    this.status = AttendanceStatus.belumDiisi,
  });
}

// ─── Absensi Page ─────────────────────────────────────────────────────────────
class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeTab = 0;
  int _selectedNavIndex = 1;

  String? _selectedMapel;
  DateTime? _selectedTanggal;
  final TextEditingController _kodeController = TextEditingController();

  final List<String> _mapelList = [
    'Fiqih Ibadah',
    'Bahasa Arab Dasar',
    "Tahfidz Al-Qur'an",
    'Sejarah Kebudayaan Islam',
  ];

  final List<StudentAttendance> _students = [
    StudentAttendance(
      name: 'Ahmad Fauzi',
      nis: '20230001',
      avatarUrl: 'https://i.pravatar.cc/150?img=11',
      status: AttendanceStatus.hadir,
    ),
    StudentAttendance(
      name: 'Aisyah Putri',
      nis: '20230002',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      status: AttendanceStatus.sakit,
    ),
    StudentAttendance(
      name: 'Budi Santoso',
      nis: '20230003',
      initials: 'BS',
      status: AttendanceStatus.alpa,
    ),
    StudentAttendance(
      name: 'Dewi Rahmawati',
      nis: '20230004',
      initials: 'DR',
      status: AttendanceStatus.izin,
    ),
    StudentAttendance(
      name: 'Farhan Maulana',
      nis: '20230005',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
      status: AttendanceStatus.hadir,
    ),
  ];

  int _count(AttendanceStatus s) =>
      _students.where((st) => st.status == s).length;

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _kodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: _C.primary,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                  ),
                  title: Text(
                    'Absensi',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    AnimatedOpacity(
                      opacity: _activeTab == 1 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.green.shade900.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: IconButton(
                            onPressed: _activeTab == 1 ? () {} : null,
                            icon: const Icon(Icons.file_download_outlined,
                                color: Colors.white, size: 20),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // BAGIAN FLEXIBLESPACE DAN EXPANDEDHEIGHT SUDAH DIHAPUS
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Container(
                      color: _C.primary,
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            _tabPill(0, 'Input Manual',
                                Icons.edit_note_rounded),
                            _tabPill(1, 'Rekap Absensi',
                                Icons.bar_chart_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildInputManualTab(),
                  _buildRekapTab(),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SiakadBottomNavBar(
                selectedIndex: _selectedNavIndex,
                onTap: (i) {
                  if (i == 2) {
                    ScanModal.show(context);
                  } else if (i == 0) {
                    Navigator.popUntil(context, (r) => r.isFirst);
                  } else if (i == 3) {
                    _navigateTo(const PengumumanPage());
                  } else if (i == 4) {
                    _navigateTo(const AkunPage());
                  } else {
                    setState(() => _selectedNavIndex = i);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab Pill ──────────────────────────────────────────────────────────────
  Widget _tabPill(int index, String label, IconData icon) {
    final active = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
          setState(() => _activeTab = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? Border.all(color: Colors.white.withOpacity(0.25))
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 15,
                  color: active ? Colors.white : Colors.white54),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? Colors.white : Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TAB 0 — INPUT MANUAL ─────────────────────────────────────────────────
  Widget _buildInputManualTab() {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormCard(),
          const SizedBox(height: 16),
          _buildStudentCard(isRekap: false),
          const SizedBox(height: 16),
          _buildInfoBox(),
          const SizedBox(height: 20),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // ── TAB 1 — REKAP ────────────────────────────────────────────────────────
  Widget _buildRekapTab() {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 20, 16, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(),
          const SizedBox(height: 16),
          _buildFormCard(isRekap: true),
          const SizedBox(height: 16),
          _buildStudentCard(isRekap: true),
          const SizedBox(height: 16),
          _buildInfoBox(),
        ],
      ),
    );
  }

  Widget _buildFormCard({bool isRekap = false}) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Detail Sesi'),
          const SizedBox(height: 18),
          _fieldLabel('Mata Pelajaran'),
          const SizedBox(height: 8),
          _buildDropdown(),
          const SizedBox(height: 16),
          _fieldLabel('Kode Sesi'),
          const SizedBox(height: 8),
          _buildTextField(),
          if (isRekap) ...[
            const SizedBox(height: 16),
            _fieldLabel('Tanggal'),
            const SizedBox(height: 8),
            _buildTanggalPicker(),
          ],
        ],
      ),
    );
  }

  Widget _buildTanggalPicker() {
    final formatted = _selectedTanggal != null
        ? '${_selectedTanggal!.day.toString().padLeft(2, '0')}/'
          '${_selectedTanggal!.month.toString().padLeft(2, '0')}/'
          '${_selectedTanggal!.year}'
        : null;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedTanggal ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
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
          setState(() => _selectedTanggal = picked);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _C.surfaceLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _C.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: _C.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(
              formatted ?? 'Pilih Tanggal',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: formatted != null ? FontWeight.w600 : FontWeight.w400,
                color: formatted != null ? _C.onSurface : _C.outline.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _C.onSurfaceVariant,
        ),
      );

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: _C.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.outlineVariant.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMapel,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              'Pilih Mata Pelajaran',
              style: GoogleFonts.inter(fontSize: 13, color: _C.outline),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.keyboard_arrow_down_rounded,
                color: _C.onSurfaceVariant, size: 22),
          ),
          borderRadius: BorderRadius.circular(14),
          dropdownColor: _C.surfaceLowest,
          items: _mapelList.map((m) {
            return DropdownMenuItem(
              value: m,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(m,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _C.onSurface)),
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedMapel = v),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _kodeController,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _C.onSurface,
        letterSpacing: 1.5,
      ),
      decoration: InputDecoration(
        hintText: 'Contoh: AB-9921',
        hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: _C.outline.withOpacity(0.5),
            letterSpacing: 0),
        filled: true,
        fillColor: _C.surfaceLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: _C.outlineVariant.withOpacity(0.5))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: _C.outlineVariant.withOpacity(0.5))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: _C.primary, width: 1.5)),
        prefixIcon:
            const Icon(Icons.tag_rounded, color: _C.outline, size: 18),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rekap Kehadiran',
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _C.onSurface,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _C.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_students.length} Siswa',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _C.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _summaryCard('Hadir', _count(AttendanceStatus.hadir),
                const Color(0xFFECFDF5), const Color(0xFF065F46),
                const Color(0xFF6EE7B7)),
            const SizedBox(width: 8),
            _summaryCard('Sakit', _count(AttendanceStatus.sakit),
                const Color(0xFFFFFBEB), const Color(0xFF92400E),
                const Color(0xFFFDE68A)),
            const SizedBox(width: 8),
            _summaryCard('Izin', _count(AttendanceStatus.izin),
                const Color(0xFFEFF6FF), const Color(0xFF1E40AF),
                const Color(0xFFBFDBFE)),
            const SizedBox(width: 8),
            _summaryCard('Alpa', _count(AttendanceStatus.alpa),
                const Color(0xFFFFF1F2), const Color(0xFF991B1B),
                const Color(0xFFFECACA)),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(String label, int count, Color bg, Color text,
      Color borderColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text('$count',
                style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: text)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: text.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard({required bool isRekap}) {
    return _card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionLabel('Daftar Siswa'),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.surfaceLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_students.length} siswa',
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _C.outline),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
                height: 1, color: _C.outlineVariant.withOpacity(0.3)),
          ),
          ...List.generate(_students.length, (i) {
            return Column(
              children: [
                isRekap
                    ? _buildRekapRow(_students[i])
                    : _buildInputRow(_students[i]),
                if (i < _students.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                        height: 1,
                        color: _C.outlineVariant.withOpacity(0.2)),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInputRow(StudentAttendance student) {
    return Row(
      children: [
        _buildAvatar(student),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.name,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.onSurface)),
              const SizedBox(height: 2),
              Text('NIS: ${student.nis}',
                  style:
                      GoogleFonts.inter(fontSize: 11, color: _C.outline)),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Row(
          children: [
            AttendanceStatus.hadir,
            AttendanceStatus.sakit,
            AttendanceStatus.izin,
            AttendanceStatus.alpa,
          ].map((s) {
            final active = student.status == s;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => student.status = s);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 34,
                height: 34,
                margin: const EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? s.bg : _C.surfaceLow,
                  border: active
                      ? Border.all(color: s.border, width: 1.5)
                      : Border.all(
                          color: _C.outlineVariant.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    s.shortLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: active ? s.fg : _C.outline,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRekapRow(StudentAttendance student) {
    return Row(
      children: [
        _buildAvatar(student),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.name,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.onSurface)),
              const SizedBox(height: 2),
              Text('NIS: ${student.nis}',
                  style:
                      GoogleFonts.inter(fontSize: 11, color: _C.outline)),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: student.status.bg,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: student.status.border),
          ),
          child: Text(
            student.status.label,
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: student.status.fg),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.primary.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _C.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: _C.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Pastikan Kode Sesi yang dimasukkan sesuai dengan Kode Ruang Kelas untuk validasi presensi.',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _C.onSurfaceVariant,
                  height: 1.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Presensi berhasil dikonfirmasi!',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: _C.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_C.primary, _C.primaryContainer],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _C.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              'Konfirmasi Presensi',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: _C.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: _C.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(StudentAttendance student) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: student.avatarUrl != null
          ? Image.network(
              student.avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initialsAvatar(
                student.initials ??
                    student.name.substring(0, 2).toUpperCase(),
              ),
            )
          : _initialsAvatar(
              student.initials ??
                  student.name.substring(0, 2).toUpperCase(),
            ),
    );
  }

  Widget _initialsAvatar(String initials) {
    return Container(
      color: _C.primaryFixed,
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _C.onPrimaryFixed,
          ),
        ),
      ),
    );
  }
}