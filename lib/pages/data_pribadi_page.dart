import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _C {
  static const primary          = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
  static const secondaryContainer = Color(0xFFFED65B);
  static const surface          = Color(0xFFF8F9FA);
  static const surfaceLowest    = Color(0xFFFFFFFF);
  static const surfaceLow       = Color(0xFFF3F4F5);
  static const onSurface        = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline          = Color(0xFF6F7A72);
  static const outlineVariant   = Color(0xFFBEC9C1);
  static const error            = Color(0xFFBA1A1A);
}

// ─── Data Pribadi Page ────────────────────────────────────────────────────────
class DataPribadiPage extends StatefulWidget {
  const DataPribadiPage({super.key});

  @override
  State<DataPribadiPage> createState() => _DataPribadiPageState();
}

class _DataPribadiPageState extends State<DataPribadiPage> {
  bool _isEditing = false;

  // ── Controllers ──
  final _namaController        = TextEditingController(text: 'Ahmad Fauzi');
  final _nisController         = TextEditingController(text: '0092384112');
  final _nissnController       = TextEditingController(text: '3271234560012001');
  final _tempatLahirController = TextEditingController(text: 'Bandung');
  final _tanggalLahirController = TextEditingController(text: '12 Maret 2008');
  final _agamaController       = TextEditingController(text: 'Islam');
  final _jenisKelaminController = TextEditingController(text: 'Laki-laki');
  final _alamatController      = TextEditingController(text: 'Jl. Merdeka No. 45, RT 03/RW 08, Kel. Sukajadi, Kec. Sukajadi, Kota Bandung');
  final _teleponController     = TextEditingController(text: '081234567890');
  final _emailController       = TextEditingController(text: 'ahmad.fauzi@siswa.siakad.id');
  final _namaAyahController    = TextEditingController(text: 'Budi Santoso');
  final _namaIbuController     = TextEditingController(text: 'Siti Rahayu');
  final _teleponOrtuController = TextEditingController(text: '082198765432');
  final _pekerjaanAyahController = TextEditingController(text: 'Wiraswasta');
  final _pekerjaanIbuController  = TextEditingController(text: 'Ibu Rumah Tangga');

  @override
  void dispose() {
    _namaController.dispose();
    _nisController.dispose();
    _nissnController.dispose();
    _tempatLahirController.dispose();
    _tanggalLahirController.dispose();
    _agamaController.dispose();
    _jenisKelaminController.dispose();
    _alamatController.dispose();
    _teleponController.dispose();
    _emailController.dispose();
    _namaAyahController.dispose();
    _namaIbuController.dispose();
    _teleponOrtuController.dispose();
    _pekerjaanAyahController.dispose();
    _pekerjaanIbuController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Simpan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text('Data berhasil disimpan',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
          backgroundColor: _C.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
    setState(() => _isEditing = !_isEditing);
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
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Foto Profil ──
                    _buildPhotoSection(),
                    const SizedBox(height: 24),

                    // ── Data Diri ──
                    _buildSectionCard(
                      icon: Icons.person_rounded,
                      title: 'Data Diri',
                      color: _C.primary,
                      bg: const Color(0xFFE8F5EE),
                      children: [
                        _buildField('Nama Lengkap', Icons.badge_rounded,
                            _namaController),
                        _buildField('NIS', Icons.numbers_rounded,
                            _nisController,
                            readOnly: true),
                        _buildField('NISSN', Icons.fingerprint_rounded,
                            _nissnController,
                            readOnly: true),
                        _buildField('Jenis Kelamin', Icons.wc_rounded,
                            _jenisKelaminController),
                        _buildField('Tempat Lahir', Icons.location_city_rounded,
                            _tempatLahirController),
                        _buildField('Tanggal Lahir', Icons.cake_rounded,
                            _tanggalLahirController,
                            isDate: true),
                        _buildField('Agama', Icons.mosque_rounded,
                            _agamaController),
                        _buildField('Alamat Lengkap', Icons.home_rounded,
                            _alamatController,
                            maxLines: 3),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Kontak ──
                    _buildSectionCard(
                      icon: Icons.contact_phone_rounded,
                      title: 'Kontak',
                      color: const Color(0xFF2563EB),
                      bg: const Color(0xFFEFF6FF),
                      children: [
                        _buildField('No. Telepon / WA', Icons.phone_rounded,
                            _teleponController,
                            keyboardType: TextInputType.phone),
                        _buildField('Email', Icons.email_rounded,
                            _emailController,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Data Orang Tua ──
                    _buildSectionCard(
                      icon: Icons.family_restroom_rounded,
                      title: 'Data Orang Tua / Wali',
                      color: const Color(0xFFEA580C),
                      bg: const Color(0xFFFFF7ED),
                      children: [
                        _buildField('Nama Ayah', Icons.man_rounded,
                            _namaAyahController),
                        _buildField('Pekerjaan Ayah', Icons.work_rounded,
                            _pekerjaanAyahController),
                        _buildField('Nama Ibu', Icons.woman_rounded,
                            _namaIbuController),
                        _buildField('Pekerjaan Ibu', Icons.work_rounded,
                            _pekerjaanIbuController),
                        _buildField('No. Telepon Orang Tua',
                            Icons.phone_in_talk_rounded,
                            _teleponOrtuController,
                            keyboardType: TextInputType.phone),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Tombol Simpan (mode edit) ──
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  setState(() => _isEditing = false),
                              icon: const Icon(Icons.close_rounded,
                                  size: 18),
                              label: Text('Batal',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _C.onSurfaceVariant,
                                side: BorderSide(
                                    color: _C.outlineVariant
                                        .withValues(alpha: 0.6)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: _toggleEdit,
                              icon: const Icon(
                                  Icons.save_rounded,
                                  size: 18),
                              label: Text('Simpan Perubahan',
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  'Data Pribadi',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              // Tombol Edit / Selesai
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isEditing
                    ? const SizedBox.shrink()
                    : TextButton.icon(
                        key: const ValueKey('edit'),
                        onPressed: _toggleEdit,
                        icon: const Icon(Icons.edit_rounded,
                            size: 16, color: Colors.white),
                        label: Text(
                          'Edit',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Foto Profil ─────────────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: _C.surfaceLow, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: _C.primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=11',
                  ),
                ),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _C.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _C.surfaceLowest, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 13),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ahmad Fauzi',
                  style: GoogleFonts.manrope(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _C.primary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'NIS: 0092384112',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _C.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_rounded,
                          size: 12, color: _C.primary),
                      const SizedBox(width: 5),
                      Text(
                        'Kelas 3A · 2024/2025',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _C.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Card ─────────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Color color,
    required Color bg,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _C.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: _C.outlineVariant.withValues(alpha: 0.3)),

          // Fields
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // ── Field ────────────────────────────────────────────────────────────────────
  Widget _buildField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isDate = false,
  }) {
    final effectiveReadOnly = readOnly || !_isEditing;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: _C.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _C.onSurfaceVariant,
                ),
              ),
              if (readOnly) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: _C.surfaceLow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Tidak dapat diubah',
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        color: _C.outline,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: isDate && _isEditing
                ? () => _pickDate(controller)
                : null,
            child: AbsorbPointer(
              absorbing: isDate && _isEditing,
              child: TextField(
                controller: controller,
                readOnly: effectiveReadOnly || isDate,
                maxLines: maxLines,
                keyboardType: keyboardType,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: effectiveReadOnly
                      ? _C.onSurface
                      : _C.onSurface,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: effectiveReadOnly
                      ? _C.surfaceLow
                      : _C.surfaceLowest,
                  suffixIcon: isDate && _isEditing
                      ? const Icon(Icons.calendar_month_rounded,
                          size: 18, color: _C.outline)
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color:
                            _C.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: effectiveReadOnly
                            ? _C.outlineVariant.withValues(alpha: 0.25)
                            : _C.outlineVariant.withValues(alpha: 0.6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: _C.primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date Picker ──────────────────────────────────────────────────────────────
  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2008, 3, 12),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.primary,
            onPrimary: Colors.white,
            surface: _C.surfaceLowest,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      controller.text =
          '${picked.day} ${months[picked.month - 1]} ${picked.year}';
    }
  }
}
