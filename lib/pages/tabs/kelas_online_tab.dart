import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/elearning_models.dart';
import '../../widgets/shared_widgets.dart';

// ─── Tab Kelas Online ─────────────────────────────────────────────────────────
class KelasOnlineTab extends StatelessWidget {
  const KelasOnlineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      children: [
        // ── Live Banner ──
        if (dummyKelas.any((k) => k.isLive)) ...[
          _LiveBanner(kelas: dummyKelas.firstWhere((k) => k.isLive)),
          const SizedBox(height: 16),
        ],

        // ── Section Header ──
        Text(
          'JADWAL KELAS',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        ...dummyKelas.map((k) => _KelasCard(kelas: k)),
      ],
    );
  }
}

// ─── Live Banner ──────────────────────────────────────────────────────────────
class _LiveBanner extends StatelessWidget {
  final KelasOnline kelas;
  const _LiveBanner({required this.kelas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004D34), Color(0xFF006747)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'SEDANG BERLANGSUNG',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            kelas.namaKelas,
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            kelas.guru,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent.shade400,
                foregroundColor: AppColors.primaryDark,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.video_call_rounded, size: 18),
              label: Text(
                'Gabung Sekarang',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Kelas Card ───────────────────────────────────────────────────────────────
class _KelasCard extends StatelessWidget {
  final KelasOnline kelas;
  const _KelasCard({required this.kelas});

  @override
  Widget build(BuildContext context) {
    final color = mapelColor(kelas.mapel);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(mapelIcon(kelas.mapel), color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kelas.namaKelas,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  kelas.guru,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.subtle),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded,
                        size: 12, color: AppColors.subtle),
                    const SizedBox(width: 4),
                    Text(
                      kelas.jadwal,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.subtle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.people_rounded,
                        size: 12, color: AppColors.subtle),
                    const SizedBox(width: 3),
                    Text(
                      '${kelas.jumlahSiswa}',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.subtle),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Masuk',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
