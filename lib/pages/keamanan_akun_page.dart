import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _C {
  static const primary          = Color(0xFF004D34);
  static const surface          = Color(0xFFF8F9FA);
  static const surfaceLowest    = Color(0xFFFFFFFF);
  static const surfaceLow       = Color(0xFFF3F4F5);
  static const onSurface        = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline          = Color(0xFF6F7A72);
  static const outlineVariant   = Color(0xFFBEC9C1);
  static const error            = Color(0xFFBA1A1A);
  static const errorContainer   = Color(0xFFFFDAD6);
}

// ─── Keamanan Akun Page ───────────────────────────────────────────────────────
class KeamananAkunPage extends StatefulWidget {
  const KeamananAkunPage({super.key});

  @override
  State<KeamananAkunPage> createState() => _KeamananAkunPageState();
}

class _KeamananAkunPageState extends State<KeamananAkunPage> {
  bool _biometrik   = false;
  bool _duaFaktor   = false;
  bool _sessionAktif = true;

  // ── Ganti Password ──
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController   = TextEditingController();
  bool _showLama    = false;
  bool _showBaru    = false;
  bool _showKonfirm = false;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _simpanPassword() {
    final lama    = _passwordLamaController.text.trim();
    final baru    = _passwordBaruController.text.trim();
    final konfirm = _konfirmasiController.text.trim();

    if (lama.isEmpty || baru.isEmpty || konfirm.isEmpty) {
      _showSnackbar('Semua kolom wajib diisi', isError: true);
      return;
    }
    if (baru.length < 8) {
      _showSnackbar('Password baru minimal 8 karakter', isError: true);
      return;
    }
    if (baru != konfirm) {
      _showSnackbar('Konfirmasi password tidak cocok', isError: true);
      return;
    }
    _passwordLamaController.clear();
    _passwordBaruController.clear();
    _konfirmasiController.clear();
    _showSnackbar('Password berhasil diperbarui');
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(msg,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: isError ? _C.error : _C.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
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
                    // ── Status Keamanan ──
                    _buildSecurityStatus(),
                    const SizedBox(height: 20),

                    // ── Ganti Password ──
                    _buildSectionCard(
                      icon: Icons.lock_reset_rounded,
                      title: 'Ganti Password',
                      color: _C.primary,
                      bg: const Color(0xFFE8F5EE),
                      child: Column(
                        children: [
                          _buildPasswordField(
                            label: 'Password Lama',
                            controller: _passwordLamaController,
                            show: _showLama,
                            onToggle: () =>
                                setState(() => _showLama = !_showLama),
                          ),
                          const SizedBox(height: 14),
                          _buildPasswordField(
                            label: 'Password Baru',
                            controller: _passwordBaruController,
                            show: _showBaru,
                            onToggle: () =>
                                setState(() => _showBaru = !_showBaru),
                          ),
                          const SizedBox(height: 6),
                          // Indikator kekuatan
                          _buildStrengthIndicator(
                              _passwordBaruController.text),
                          const SizedBox(height: 14),
                          _buildPasswordField(
                            label: 'Konfirmasi Password Baru',
                            controller: _konfirmasiController,
                            show: _showKonfirm,
                            onToggle: () =>
                                setState(() => _showKonfirm = !_showKonfirm),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _simpanPassword,
                              icon: const Icon(Icons.save_rounded,
                                  size: 18),
                              label: Text('Simpan Password Baru',
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
                    ),
                    const SizedBox(height: 16),

                    // ── Pengamanan Tambahan ──
                    _buildSectionCard(
                      icon: Icons.security_rounded,
                      title: 'Pengamanan Tambahan',
                      color: const Color(0xFF7E22CE),
                      bg: const Color(0xFFF3E8FF),
                      child: Column(
                        children: [
                          _buildToggleRow(
                            icon: Icons.fingerprint_rounded,
                            iconColor: _C.primary,
                            iconBg: const Color(0xFFE8F5EE),
                            label: 'Login Biometrik',
                            subtitle:
                                'Gunakan sidik jari atau wajah untuk masuk',
                            value: _biometrik,
                            onChanged: (v) =>
                                setState(() => _biometrik = v),
                          ),
                          Divider(
                              height: 1,
                              color: _C.outlineVariant
                                  .withValues(alpha: 0.25)),
                          _buildToggleRow(
                            icon: Icons.verified_user_rounded,
                            iconColor: const Color(0xFF2563EB),
                            iconBg: const Color(0xFFEFF6FF),
                            label: 'Verifikasi Dua Faktor',
                            subtitle:
                                'Kirim kode OTP ke nomor terdaftar saat login',
                            value: _duaFaktor,
                            onChanged: (v) =>
                                setState(() => _duaFaktor = v),
                          ),
                          Divider(
                              height: 1,
                              color: _C.outlineVariant
                                  .withValues(alpha: 0.25)),
                          _buildToggleRow(
                            icon: Icons.manage_accounts_rounded,
                            iconColor: const Color(0xFFEA580C),
                            iconBg: const Color(0xFFFFF7ED),
                            label: 'Tetap Masuk',
                            subtitle:
                                'Sesi login tetap aktif selama 30 hari',
                            value: _sessionAktif,
                            onChanged: (v) =>
                                setState(() => _sessionAktif = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Riwayat Aktivitas ──
                    _buildSectionCard(
                      icon: Icons.history_rounded,
                      title: 'Aktivitas Login Terakhir',
                      color: const Color(0xFF0284C7),
                      bg: const Color(0xFFF0F9FF),
                      child: Column(
                        children: [
                          _buildActivityItem(
                            device: 'Samsung Galaxy A54',
                            location: 'Bandung, Indonesia',
                            time: 'Hari ini, 07:32',
                            isCurrent: true,
                          ),
                          Divider(
                              height: 1,
                              color: _C.outlineVariant
                                  .withValues(alpha: 0.25)),
                          _buildActivityItem(
                            device: 'Chrome · Windows 11',
                            location: 'Bandung, Indonesia',
                            time: 'Kemarin, 19:15',
                            isCurrent: false,
                          ),
                          Divider(
                              height: 1,
                              color: _C.outlineVariant
                                  .withValues(alpha: 0.25)),
                          _buildActivityItem(
                            device: 'iPhone 13',
                            location: 'Jakarta, Indonesia',
                            time: '2 hari lalu, 14:08',
                            isCurrent: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Hapus Akun ──
                    _buildDangerCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────
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
          padding: const EdgeInsets.fromLTRB(4, 4, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 2),
              Text(
                'Keamanan Akun',
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
      ),
    );
  }

  // ── Security Status ──────────────────────────────────────────────────────────
  Widget _buildSecurityStatus() {
    final score = (_biometrik ? 1 : 0) + (_duaFaktor ? 2 : 0) + 1;
    final isStrong = score >= 3;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isStrong
              ? [const Color(0xFF003828), const Color(0xFF006747)]
              : [const Color(0xFFEA580C), const Color(0xFFFB923C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isStrong
                  ? Icons.shield_rounded
                  : Icons.shield_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStrong ? 'Akun Terlindungi' : 'Keamanan Perlu Ditingkatkan',
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isStrong
                      ? 'Semua fitur keamanan aktif'
                      : 'Aktifkan biometrik & 2FA untuk perlindungan lebih',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
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
    required Widget child,
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
                Text(title,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.onSurface,
                      letterSpacing: -0.2,
                    )),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: _C.outlineVariant.withValues(alpha: 0.3)),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  // ── Password Field ───────────────────────────────────────────────────────────
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _C.onSurfaceVariant,
            )),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !show,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.inter(fontSize: 13, color: _C.onSurface),
          decoration: InputDecoration(
            filled: true,
            fillColor: _C.surfaceLow,
            hintText: '••••••••',
            hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: _C.outline.withValues(alpha: 0.4)),
            suffixIcon: IconButton(
              icon: Icon(
                show
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: _C.outline,
                size: 20,
              ),
              onPressed: onToggle,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: _C.outlineVariant.withValues(alpha: 0.5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: _C.outlineVariant.withValues(alpha: 0.4)),
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

  // ── Strength Indicator ───────────────────────────────────────────────────────
  Widget _buildStrengthIndicator(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#\$%^&*]'))) strength++;

    final labels = ['', 'Lemah', 'Sedang', 'Kuat', 'Sangat Kuat'];
    final colors = [
      Colors.transparent,
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF22C55E),
      _C.primary,
    ];

    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: i < strength
                      ? colors[strength]
                      : _C.outlineVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        if (strength > 0) ...[
          const SizedBox(height: 4),
          Text(
            'Kekuatan: ${labels[strength]}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors[strength],
            ),
          ),
        ],
      ],
    );
  }

  // ── Toggle Row ───────────────────────────────────────────────────────────────
  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _C.onSurface,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _C.onSurfaceVariant,
                      height: 1.4,
                    )),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _C.primary,
          ),
        ],
      ),
    );
  }

  // ── Activity Item ────────────────────────────────────────────────────────────
  Widget _buildActivityItem({
    required String device,
    required String location,
    required String time,
    required bool isCurrent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFFE8F5EE)
                  : _C.surfaceLow,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              device.contains('iPhone') || device.contains('Galaxy')
                  ? Icons.smartphone_rounded
                  : Icons.computer_rounded,
              color: isCurrent ? _C.primary : _C.outline,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(device,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.onSurface,
                          )),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5EE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Perangkat ini',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _C.primary,
                            )),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text('$location · $time',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _C.onSurfaceVariant,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Danger Card ──────────────────────────────────────────────────────────────
  Widget _buildDangerCard() {
    return Container(
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.error.withValues(alpha: 0.2)),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: _C.errorContainer,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: _C.error, size: 18),
                ),
                const SizedBox(width: 10),
                Text('Zona Berbahaya',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.error,
                      letterSpacing: -0.2,
                    )),
              ],
            ),
          ),
          Divider(
              height: 1,
              color: _C.error.withValues(alpha: 0.15)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keluar dari Semua Perangkat',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paksa keluar dari semua sesi login yang aktif di perangkat lain.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _C.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showKonfirmasiLogout(context),
                    icon: const Icon(Icons.logout_rounded, size: 16),
                    label: Text('Keluar Semua Perangkat',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _C.error,
                      side: BorderSide(
                          color: _C.error.withValues(alpha: 0.5)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showKonfirmasiLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar Semua Perangkat?',
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800, fontSize: 17)),
        content: Text(
          'Semua sesi login aktif akan dihentikan. Anda harus login ulang di semua perangkat.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: _C.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackbar('Berhasil keluar dari semua perangkat');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Keluar',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
