import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pengumuman_page.dart';
import 'presensi_page.dart';
import 'akun_page.dart';
import '../widgets/bottom_navbar.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────
class _ScheduleItem {
  final String startTime;
  final String endTime;
  final String subject;
  final String room;
  final String teacher;
  final Color color;
  final bool isNow;

  const _ScheduleItem({
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.room,
    required this.teacher,
    required this.color,
    this.isNow = false,
  });
}

// ─── Schedule Data per Hari ───────────────────────────────────────────────────
const _scheduleData = {
  0: [ // Senin
    _ScheduleItem(
      startTime: '08:00', endTime: '10:30',
      subject: 'Pemrograman Mobile',
      room: 'Lab Komputer 2',
      teacher: 'Dr. Budi Santoso',
      color: Color(0xFFE8A020),
      isNow: true,
    ),
    _ScheduleItem(
      startTime: '11:00', endTime: '13:00',
      subject: 'Basis Data Terdistribusi',
      room: 'Ruang A.302',
      teacher: 'Siti Aminah, M.T.',
      color: Color(0xFF2980B9),
    ),
    _ScheduleItem(
      startTime: '14:00', endTime: '16:00',
      subject: 'Etika Profesi IT',
      room: 'Gedung Teater',
      teacher: 'Iwan Setiawan, M.Kom',
      color: Color(0xFFE74C3C),
    ),
  ],
  1: [ // Selasa
    _ScheduleItem(
      startTime: '07:30', endTime: '09:30',
      subject: 'Matematika Diskrit',
      room: 'Ruang B.201',
      teacher: 'Dr. Rina Susanti',
      color: Color(0xFF27AE60),
    ),
    _ScheduleItem(
      startTime: '10:00', endTime: '12:00',
      subject: 'Jaringan Komputer',
      room: 'Lab Jaringan',
      teacher: 'Budi Prasetyo, M.T.',
      color: Color(0xFF8E44AD),
    ),
    _ScheduleItem(
      startTime: '13:00', endTime: '15:00',
      subject: 'Kecerdasan Buatan',
      room: 'Lab AI',
      teacher: 'Prof. Andi Kurniawan',
      color: Color(0xFFE8A020),
    ),
  ],
  2: [ // Rabu
    _ScheduleItem(
      startTime: '08:00', endTime: '10:00',
      subject: 'Rekayasa Perangkat Lunak',
      room: 'Ruang C.105',
      teacher: 'Dewi Lestari, M.Kom',
      color: Color(0xFF2980B9),
    ),
    _ScheduleItem(
      startTime: '10:30', endTime: '12:30',
      subject: 'Sistem Operasi',
      room: 'Lab Komputer 1',
      teacher: 'Hendra Wijaya, M.T.',
      color: Color(0xFFE74C3C),
    ),
  ],
  3: [ // Kamis
    _ScheduleItem(
      startTime: '09:00', endTime: '11:00',
      subject: 'Algoritma & Struktur Data',
      room: 'Ruang A.101',
      teacher: 'Ir. Wahyu Santoso',
      color: Color(0xFF27AE60),
    ),
    _ScheduleItem(
      startTime: '13:00', endTime: '15:30',
      subject: 'Desain UI/UX',
      room: 'Studio Desain',
      teacher: 'Nadia Putri, M.Ds.',
      color: Color(0xFF8E44AD),
    ),
    _ScheduleItem(
      startTime: '16:00', endTime: '17:30',
      subject: 'Bahasa Inggris Teknis',
      room: 'Ruang B.303',
      teacher: 'Rachel Amelia, M.A.',
      color: Color(0xFFE8A020),
    ),
  ],
  4: [ // Jumat
    _ScheduleItem(
      startTime: '07:30', endTime: '09:00',
      subject: 'Kalkulus Lanjut',
      room: 'Ruang A.202',
      teacher: 'Dr. Surya Darmawan',
      color: Color(0xFFE74C3C),
    ),
    _ScheduleItem(
      startTime: '09:30', endTime: '11:00',
      subject: 'Pemrograman Web',
      room: 'Lab Komputer 3',
      teacher: 'Yoga Pratama, M.Kom',
      color: Color(0xFF2980B9),
    ),
  ],
  5: [ // Sabtu
    _ScheduleItem(
      startTime: '08:00', endTime: '12:00',
      subject: 'Praktikum Pemrograman',
      room: 'Lab Komputer 2',
      teacher: 'Tim Asisten Lab',
      color: Color(0xFF27AE60),
    ),
  ],
};

// ─── Page ─────────────────────────────────────────────────────────────────────
class SchoolSchedulePage extends StatefulWidget {
  const SchoolSchedulePage({super.key});

  @override
  State<SchoolSchedulePage> createState() => _SchoolSchedulePageState();
}

class _SchoolSchedulePageState extends State<SchoolSchedulePage> {
  int _selectedNavIndex = 0;
  int _selectedDay = 0;

  static const _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  static const _primary = Color(0xFF004D34);

  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => page,
        transitionsBuilder: (_, a, __, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _scheduleData[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App Bar ──────────────────────────────────────────────
                Container(
                  color: _primary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  height: 60,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          'Jadwal Kuliah',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // ── Day Selector Card ─────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selector Hari',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(_days.length, (i) {
                          final isSelected = i == _selectedDay;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDay = i),
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                children: [
                                  Text(
                                    _days[i],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? _primary
                                          : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? _primary
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // ── Schedule List ─────────────────────────────────────────
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_busy_rounded,
                                  size: 60,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Tidak ada jadwal',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                          itemCount: items.length,
                          itemBuilder: (_, index) =>
                              _ScheduleCard(item: items[index]),
                        ),
                ),
              ],
            ),

            // ── Bottom Navbar ─────────────────────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: SIMANISBottomNavBar(
                selectedIndex: _selectedNavIndex,
                onTap: (i) {
                  if (i == 0) {
                    Navigator.of(context).pop();
                  } else if (i == 1) {
                    _navigateTo(const PresensiPage());
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
}

// ─── Schedule Card ─────────────────────────────────────────────────────────────
// Desain PERSIS referensi kanan:
//   • Wrapper luar  → border berwarna (2px), border radius 18, background putih
//   • Kolom kiri    → warna solid (item.color), teks putih bold, width 88
//   • Kolom kanan   → putih bersih, judul hitam bold, room & teacher abu-abu
//   • Tidak ada strip kanan
//   • Shadow ringan hitam
class _ScheduleCard extends StatelessWidget {
  final _ScheduleItem item;
  const _ScheduleCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.color, width: 2),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Blok waktu kiri (warna solid) ───────────────────────
              Container(
                width: 88,
                color: item.color,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.startTime,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      width: 1.5,
                      height: 12,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    Text(
                      item.endTime,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info kanan (putih bersih) ────────────────────────────
              Expanded(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.subject,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              size: 14, color: item.color),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.room,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_rounded,
                              size: 14, color: item.color),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.teacher,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}