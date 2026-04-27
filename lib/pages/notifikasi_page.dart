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
}

// ─── Notifikasi Page ──────────────────────────────────────────────────────────
class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  // ── State semua toggle ──
  bool _notifAbsensi       = true;
  bool _notifNilai         = true;
  bool _notifPembayaran    = true;
  bool _notifPengumuman    = false;
  bool _notifIzin          = true;
  bool _notifJadwal        = false;
  bool _notifEmail         = false;
  bool _notifWhatsapp      = true;
  bool _notifPush          = true;
  bool _notifSuara         = true;
  bool _notifGetar         = true;

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
                    // ── Info Banner ──
                    _buildInfoBanner(),
                    const SizedBox(height: 20),

                    // ── Jenis Notifikasi ──
                    _buildSectionCard(
                      icon: Icons.notifications_active_rounded,
                      title: 'Jenis Notifikasi',
                      color: const Color(0xFF7E22CE),
                      bg: const Color(0xFFF3E8FF),
                      children: [
                        _buildToggleItem(
                          icon: Icons.how_to_reg_rounded,
                          iconColor: _C.primary,
                          iconBg: const Color(0xFFE8F5EE),
                          label: 'Absensi',
                          subtitle: 'Notifikasi rekap kehadiran harian',
                          value: _notifAbsensi,
                          onChanged: (v) =>
                              setState(() => _notifAbsensi = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.grade_rounded,
                          iconColor: const Color(0xFFEA580C),
                          iconBg: const Color(0xFFFFF7ED),
                          label: 'Nilai',
                          subtitle: 'Input nilai baru dari guru',
                          value: _notifNilai,
                          onChanged: (v) =>
                              setState(() => _notifNilai = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: const Color(0xFF9333EA),
                          iconBg: const Color(0xFFFAF5FF),
                          label: 'Pembayaran',
                          subtitle: 'Tagihan dan konfirmasi pembayaran',
                          value: _notifPembayaran,
                          onChanged: (v) =>
                              setState(() => _notifPembayaran = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.campaign_rounded,
                          iconColor: const Color(0xFF0284C7),
                          iconBg: const Color(0xFFF0F9FF),
                          label: 'Pengumuman',
                          subtitle: 'Info dan pengumuman sekolah',
                          value: _notifPengumuman,
                          onChanged: (v) =>
                              setState(() => _notifPengumuman = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.event_busy_rounded,
                          iconColor: const Color(0xFF0D9488),
                          iconBg: const Color(0xFFF0FDFA),
                          label: 'Izin & Perizinan',
                          subtitle: 'Status pengajuan izin siswa',
                          value: _notifIzin,
                          onChanged: (v) =>
                              setState(() => _notifIzin = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFF2563EB),
                          iconBg: const Color(0xFFEFF6FF),
                          label: 'Jadwal',
                          subtitle: 'Perubahan jadwal pelajaran',
                          value: _notifJadwal,
                          onChanged: (v) =>
                              setState(() => _notifJadwal = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Saluran Notifikasi ──
                    _buildSectionCard(
                      icon: Icons.send_rounded,
                      title: 'Saluran Notifikasi',
                      color: const Color(0xFF2563EB),
                      bg: const Color(0xFFEFF6FF),
                      children: [
                        _buildToggleItem(
                          icon: Icons.notifications_rounded,
                          iconColor: const Color(0xFF7E22CE),
                          iconBg: const Color(0xFFF3E8FF),
                          label: 'Push Notification',
                          subtitle: 'Notifikasi langsung di perangkat',
                          value: _notifPush,
                          onChanged: (v) =>
                              setState(() => _notifPush = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.email_rounded,
                          iconColor: const Color(0xFFE11D48),
                          iconBg: const Color(0xFFFFF1F2),
                          label: 'Email',
                          subtitle: 'Kirim ringkasan via email',
                          value: _notifEmail,
                          onChanged: (v) =>
                              setState(() => _notifEmail = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.chat_rounded,
                          iconColor: const Color(0xFF16A34A),
                          iconBg: const Color(0xFFF0FDF4),
                          label: 'WhatsApp',
                          subtitle: 'Pesan notifikasi via WhatsApp',
                          value: _notifWhatsapp,
                          onChanged: (v) =>
                              setState(() => _notifWhatsapp = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Preferensi Suara ──
                    _buildSectionCard(
                      icon: Icons.tune_rounded,
                      title: 'Preferensi',
                      color: const Color(0xFFEA580C),
                      bg: const Color(0xFFFFF7ED),
                      children: [
                        _buildToggleItem(
                          icon: Icons.volume_up_rounded,
                          iconColor: const Color(0xFFEA580C),
                          iconBg: const Color(0xFFFFF7ED),
                          label: 'Suara Notifikasi',
                          subtitle: 'Mainkan suara saat notifikasi masuk',
                          value: _notifSuara,
                          onChanged: (v) =>
                              setState(() => _notifSuara = v),
                        ),
                        _buildDivider(),
                        _buildToggleItem(
                          icon: Icons.vibration_rounded,
                          iconColor: const Color(0xFF0D9488),
                          iconBg: const Color(0xFFF0FDFA),
                          label: 'Getar',
                          subtitle: 'Aktifkan getar saat notifikasi masuk',
                          value: _notifGetar,
                          onChanged: (v) =>
                              setState(() => _notifGetar = v),
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
                'Pengaturan Notifikasi',
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

  // ── Info Banner ──────────────────────────────────────────────────────────────
  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _C.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: _C.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Perubahan pengaturan notifikasi akan langsung diterapkan pada perangkat ini.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: _C.primary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // ── Toggle Item ──────────────────────────────────────────────────────────────
  Widget _buildToggleItem({
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

  Widget _buildDivider() => Divider(
      height: 1,
      color: _C.outlineVariant.withValues(alpha: 0.25));
}
