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

// ─── Model FAQ ────────────────────────────────────────────────────────────────
class _FaqItem {
  final String pertanyaan;
  final String jawaban;
  bool isOpen;

  _FaqItem({
    required this.pertanyaan,
    required this.jawaban,
    this.isOpen = false,
  });
}

// ─── Bantuan Page ─────────────────────────────────────────────────────────────
class BantuanPage extends StatefulWidget {
  const BantuanPage({super.key});

  @override
  State<BantuanPage> createState() => _BantuanPageState();
}

class _BantuanPageState extends State<BantuanPage> {
  final _pesanController = TextEditingController();

  final List<_FaqItem> _faqList = [
    _FaqItem(
      pertanyaan: 'Bagaimana cara melihat rekap absensi saya?',
      jawaban:
          'Buka menu Presensi dari halaman utama, lalu pilih menu Absensi. Di sana Anda dapat melihat rekap kehadiran per bulan beserta detail setiap pertemuan.',
    ),
    _FaqItem(
      pertanyaan: 'Bagaimana cara mengajukan izin tidak masuk?',
      jawaban:
          'Masuk ke menu Presensi → Izin. Klik tombol "+" untuk membuat pengajuan izin baru. Isi tanggal, jenis izin, dan alasan, lalu kirim. Pengajuan akan diproses oleh wali kelas.',
    ),
    _FaqItem(
      pertanyaan: 'Mengapa nilai saya belum muncul?',
      jawaban:
          'Nilai baru akan muncul setelah guru memasukkan dan mempublikasikan nilai. Jika sudah lebih dari 3 hari kerja setelah ujian, hubungi guru mata pelajaran terkait.',
    ),
    _FaqItem(
      pertanyaan: 'Bagaimana cara melakukan pembayaran SPP?',
      jawaban:
          'Buka menu Presensi → Pembayaran. Pilih tagihan yang ingin dibayar, lalu pilih metode pembayaran. Simpan bukti pembayaran dan tunggu konfirmasi dari bendahara.',
    ),
    _FaqItem(
      pertanyaan: 'Saya lupa password, bagaimana cara menggantinya?',
      jawaban:
          'Di halaman login, klik "Lupa Password". Masukkan NIS atau email terdaftar Anda. Kode OTP akan dikirim ke nomor telepon orang tua yang terdaftar untuk mereset password.',
    ),
    _FaqItem(
      pertanyaan: 'Apakah data pribadi saya aman?',
      jawaban:
          'Ya. Semua data pribadi dilindungi dengan enkripsi SSL dan disimpan di server yang aman sesuai kebijakan privasi sekolah. Data tidak akan dibagikan kepada pihak ketiga tanpa izin.',
    ),
  ];

  @override
  void dispose() {
    _pesanController.dispose();
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
                    // ── Kontak Cepat ──
                    _buildKontakCepat(),
                    const SizedBox(height: 20),

                    // ── FAQ ──
                    _buildSectionHeader(
                      icon: Icons.quiz_rounded,
                      title: 'Pertanyaan Umum (FAQ)',
                      color: const Color(0xFF7E22CE),
                      bg: const Color(0xFFF3E8FF),
                    ),
                    const SizedBox(height: 12),
                    ..._faqList.map((item) => _buildFaqTile(item)),
                    const SizedBox(height: 20),

                    // ── Kirim Pesan ──
                    _buildSectionCard(
                      icon: Icons.mail_rounded,
                      title: 'Kirim Pesan ke Admin',
                      color: const Color(0xFF2563EB),
                      bg: const Color(0xFFEFF6FF),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Belum menemukan jawaban? Kirim pertanyaan atau laporan langsung ke tim admin sekolah.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _C.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _pesanController,
                            maxLines: 4,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: _C.onSurface),
                            decoration: InputDecoration(
                              hintText:
                                  'Tuliskan pertanyaan atau kendala yang Anda alami...',
                              hintStyle: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _C.outline
                                      .withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: _C.surfaceLow,
                              contentPadding: const EdgeInsets.all(14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: _C.outlineVariant
                                        .withValues(alpha: 0.4)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: _C.outlineVariant
                                        .withValues(alpha: 0.4)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: _C.primary, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_pesanController.text
                                    .trim()
                                    .isEmpty) return;
                                _pesanController.clear();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.white,
                                            size: 18),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Pesan terkirim! Admin akan merespons dalam 1×24 jam.',
                                          style: GoogleFonts.inter(
                                              fontWeight:
                                                  FontWeight.w600,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: _C.primary,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    margin: const EdgeInsets.all(16),
                                    duration:
                                        const Duration(seconds: 3),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.send_rounded,
                                  size: 17),
                              label: Text('Kirim Pesan',
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
                    const SizedBox(height: 20),

                    // ── Info Versi ──
                    _buildVersiInfo(),
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
                'Bantuan & Dukungan',
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

  // ── Kontak Cepat ─────────────────────────────────────────────────────────────
  Widget _buildKontakCepat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          icon: Icons.support_agent_rounded,
          title: 'Hubungi Kami',
          color: _C.primary,
          bg: const Color(0xFFE8F5EE),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKontakCard(
                icon: Icons.chat_rounded,
                label: 'WhatsApp',
                sublabel: 'Chat Langsung',
                color: const Color(0xFF16A34A),
                bg: const Color(0xFFF0FDF4),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKontakCard(
                icon: Icons.phone_rounded,
                label: 'Telepon',
                sublabel: '(022) 1234-5678',
                color: const Color(0xFF2563EB),
                bg: const Color(0xFFEFF6FF),
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKontakCard(
                icon: Icons.email_rounded,
                label: 'Email',
                sublabel: 'admin@sekolah.id',
                color: const Color(0xFFE11D48),
                bg: const Color(0xFFFFF1F2),
                onTap: () {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.surfaceLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _C.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.access_time_rounded,
                    size: 16, color: Color(0xFFEA580C)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jam Operasional',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _C.onSurface,
                        )),
                    const SizedBox(height: 1),
                    Text('Senin – Jumat, 07.00 – 15.00 WIB',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _C.onSurfaceVariant,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKontakCard({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: _C.surfaceLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _C.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _C.onSurface,
                )),
            const SizedBox(height: 2),
            Text(sublabel,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: _C.onSurfaceVariant,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── FAQ Tile ─────────────────────────────────────────────────────────────────
  Widget _buildFaqTile(_FaqItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: item.isOpen
                ? _C.primary.withValues(alpha: 0.3)
                : _C.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => item.isOpen = !item.isOpen),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: item.isOpen
                            ? const Color(0xFFE8F5EE)
                            : _C.surfaceLow,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isOpen
                            ? Icons.remove_rounded
                            : Icons.add_rounded,
                        size: 16,
                        color: item.isOpen
                            ? _C.primary
                            : _C.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.pertanyaan,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: item.isOpen
                              ? _C.primary
                              : _C.onSurface,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.isOpen) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 38),
                    child: Text(
                      item.jawaban,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _C.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required Color bg,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: bg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 17),
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

  // ── Versi Info ───────────────────────────────────────────────────────────────
  Widget _buildVersiInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surfaceLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: _C.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: _C.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SIMANIS v.2.4.0',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _C.onSurface,
                    )),
                const SizedBox(height: 2),
                Text('Terakhir diperbarui: 1 April 2025',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: _C.onSurfaceVariant,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Versi Terbaru',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.primary,
                )),
          ),
        ],
      ),
    );
  }
}
