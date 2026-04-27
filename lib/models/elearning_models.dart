import 'package:flutter/material.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF004D34);
  static const primaryDark = Color(0xFF022C22);
  static const surface = Color(0xFFF8F9FA);
  static const card = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1D);
  static const subtle = Color(0xFF3F4943);
  static const border = Color(0xFFBEC9C1);
  static const chip = Color(0xFFEDEEEF);
  static const blue = Color(0xFF0284C7);
  static const purple = Color(0xFF7C3AED);
  static const amber = Color(0xFFF59E0B);
  static const red = Color(0xFFE11D48);
  static const teal = Color(0xFF0D9488);
  static const orange = Color(0xFFEA580C);
  static const indigo = Color(0xFF4F46E5);
}

// Alias pendek untuk kompatibilitas internal
// ignore: camel_case_types
class _C {
  static const primary     = AppColors.primary;
  static const primaryDark = AppColors.primaryDark;
  static const surface     = AppColors.surface;
  static const card        = AppColors.card;
  static const onSurface   = AppColors.onSurface;
  static const subtle      = AppColors.subtle;
  static const border      = AppColors.border;
  static const chip        = AppColors.chip;
  static const blue        = AppColors.blue;
  static const purple      = AppColors.purple;
  static const amber       = AppColors.amber;
  static const red         = AppColors.red;
  static const teal        = AppColors.teal;
  static const orange      = AppColors.orange;
  static const indigo      = AppColors.indigo;
}

// ─── Enums ────────────────────────────────────────────────────────────────────
enum MataPelajaran { matematika, bahasaIndonesia, ipa, ips, bahasaInggris, agama, senibudaya, penjaskes }
enum StatusMateri { belumDibaca, sedangDibaca, selesai }
enum TipeKonten { video, pdf, kuis, tugas }

// ─── Models ───────────────────────────────────────────────────────────────────
class MateriItem {
  final String id;
  final String judul;
  final String deskripsi;
  final MataPelajaran mapel;
  final TipeKonten tipe;
  final StatusMateri status;
  final String durasi;
  final String tanggalUpload;
  final String guru;
  final int nilaiKuis;
  final bool isDue;
  final String? deadline;
  final String? youtubeId;
  final String? pdfUrl;

  const MateriItem({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.mapel,
    required this.tipe,
    required this.status,
    required this.durasi,
    required this.tanggalUpload,
    required this.guru,
    this.nilaiKuis = 0,
    this.isDue = false,
    this.deadline,
    this.youtubeId,
    this.pdfUrl,
  });

  MateriItem copyWith({
    String? id, String? judul, String? deskripsi, MataPelajaran? mapel,
    TipeKonten? tipe, StatusMateri? status, String? durasi,
    String? tanggalUpload, String? guru, int? nilaiKuis, bool? isDue,
    String? deadline, String? youtubeId, String? pdfUrl,
  }) => MateriItem(
    id: id ?? this.id,
    judul: judul ?? this.judul,
    deskripsi: deskripsi ?? this.deskripsi,
    mapel: mapel ?? this.mapel,
    tipe: tipe ?? this.tipe,
    status: status ?? this.status,
    durasi: durasi ?? this.durasi,
    tanggalUpload: tanggalUpload ?? this.tanggalUpload,
    guru: guru ?? this.guru,
    nilaiKuis: nilaiKuis ?? this.nilaiKuis,
    isDue: isDue ?? this.isDue,
    deadline: deadline ?? this.deadline,
    youtubeId: youtubeId ?? this.youtubeId,
    pdfUrl: pdfUrl ?? this.pdfUrl,
  );
}

class KelasOnline {
  final String id;
  final String namaKelas;
  final MataPelajaran mapel;
  final String guru;
  final String jadwal;
  final String link;
  final bool isLive;
  final int jumlahSiswa;

  const KelasOnline({
    required this.id,
    required this.namaKelas,
    required this.mapel,
    required this.guru,
    required this.jadwal,
    required this.link,
    this.isLive = false,
    required this.jumlahSiswa,
  });
}

// ─── Dummy Data ───────────────────────────────────────────────────────────────
const dummyMateri = [
  MateriItem(
    id: 'M001',
    judul: 'Persamaan Linear Dua Variabel',
    deskripsi: 'Mempelajari cara menyelesaikan sistem persamaan linear dengan dua variabel menggunakan metode substitusi dan eliminasi.',
    mapel: MataPelajaran.matematika,
    tipe: TipeKonten.video,
    status: StatusMateri.selesai,
    durasi: '25 menit',
    tanggalUpload: '10 Apr 2025',
    guru: 'Bpk. Hendra Gunawan',
    nilaiKuis: 90,
    youtubeId: 'jL5jtqWFy0w',
  ),
  MateriItem(
    id: 'M002',
    judul: 'Teks Argumentasi & Persuasi',
    deskripsi: 'Memahami struktur dan ciri-ciri teks argumentasi dan persuasi dalam bahasa Indonesia.',
    mapel: MataPelajaran.bahasaIndonesia,
    tipe: TipeKonten.pdf,
    status: StatusMateri.sedangDibaca,
    durasi: '15 menit',
    tanggalUpload: '09 Apr 2025',
    guru: 'Ibu Sari Dewi',
    pdfUrl: 'https://www.w3.org/WAI/WCAG21/wcag21.pdf',
  ),
  MateriItem(
    id: 'M003',
    judul: 'Kuis: Fotosintesis & Respirasi',
    deskripsi: 'Uji pemahaman kamu tentang proses fotosintesis dan respirasi pada makhluk hidup.',
    mapel: MataPelajaran.ipa,
    tipe: TipeKonten.kuis,
    status: StatusMateri.belumDibaca,
    durasi: '30 menit',
    tanggalUpload: '08 Apr 2025',
    guru: 'Ibu Ratna Sari',
    isDue: true,
    deadline: '15 Apr 2025',
  ),
  MateriItem(
    id: 'M004',
    judul: 'Tugas: Peta Kepadatan Penduduk',
    deskripsi: 'Buat peta tematik kepadatan penduduk di Indonesia berdasarkan data sensus terbaru.',
    mapel: MataPelajaran.ips,
    tipe: TipeKonten.tugas,
    status: StatusMateri.belumDibaca,
    durasi: '—',
    tanggalUpload: '07 Apr 2025',
    guru: 'Bpk. Agus Salim',
    isDue: true,
    deadline: '14 Apr 2025',
  ),
  MateriItem(
    id: 'M005',
    judul: 'Simple Present & Past Tense',
    deskripsi: 'Review penggunaan simple present tense dan simple past tense dalam kalimat bahasa Inggris.',
    mapel: MataPelajaran.bahasaInggris,
    tipe: TipeKonten.video,
    status: StatusMateri.selesai,
    durasi: '20 menit',
    tanggalUpload: '06 Apr 2025',
    guru: 'Ibu Fitri Amalia',
    nilaiKuis: 85,
    youtubeId: 'jL5jtqWFy0w',
  ),
  MateriItem(
    id: 'M006',
    judul: 'Akhlak dalam Kehidupan Sehari-hari',
    deskripsi: 'Memahami konsep akhlak mulia dan penerapannya dalam kehidupan bermasyarakat.',
    mapel: MataPelajaran.agama,
    tipe: TipeKonten.pdf,
    status: StatusMateri.belumDibaca,
    durasi: '12 menit',
    tanggalUpload: '05 Apr 2025',
    guru: 'Bpk. Farid Hasan',
    pdfUrl: 'https://www.w3.org/WAI/WCAG21/wcag21.pdf',
  ),
];

const dummyKelas = [
  KelasOnline(
    id: 'K001',
    namaKelas: 'Matematika — Kelas 8A',
    mapel: MataPelajaran.matematika,
    guru: 'Bpk. Hendra Gunawan',
    jadwal: 'Selasa, 08.00 – 09.30',
    link: 'https://meet.google.com/abc-defg-hij',
    isLive: true,
    jumlahSiswa: 28,
  ),
  KelasOnline(
    id: 'K002',
    namaKelas: 'IPA — Kelas 8A',
    mapel: MataPelajaran.ipa,
    guru: 'Ibu Ratna Sari',
    jadwal: 'Rabu, 10.00 – 11.30',
    link: 'https://meet.google.com/xyz-uvwx-yz',
    isLive: false,
    jumlahSiswa: 28,
  ),
  KelasOnline(
    id: 'K003',
    namaKelas: 'Bahasa Inggris — Kelas 8A',
    mapel: MataPelajaran.bahasaInggris,
    guru: 'Ibu Fitri Amalia',
    jadwal: 'Kamis, 13.00 – 14.30',
    link: 'https://meet.google.com/qrs-tuvw-xy',
    isLive: false,
    jumlahSiswa: 28,
  ),
];

// ─── Helper Functions ─────────────────────────────────────────────────────────
String mapelLabel(MataPelajaran m) {
  switch (m) {
    case MataPelajaran.matematika:      return 'Matematika';
    case MataPelajaran.bahasaIndonesia: return 'B. Indonesia';
    case MataPelajaran.ipa:             return 'IPA';
    case MataPelajaran.ips:             return 'IPS';
    case MataPelajaran.bahasaInggris:   return 'B. Inggris';
    case MataPelajaran.agama:           return 'Agama';
    case MataPelajaran.senibudaya:      return 'Seni Budaya';
    case MataPelajaran.penjaskes:       return 'Penjaskes';
  }
}

Color mapelColor(MataPelajaran m) {
  switch (m) {
    case MataPelajaran.matematika:      return _C.blue;
    case MataPelajaran.bahasaIndonesia: return _C.teal;
    case MataPelajaran.ipa:             return _C.primary;
    case MataPelajaran.ips:             return _C.orange;
    case MataPelajaran.bahasaInggris:   return _C.indigo;
    case MataPelajaran.agama:           return _C.amber;
    case MataPelajaran.senibudaya:      return _C.purple;
    case MataPelajaran.penjaskes:       return _C.red;
  }
}

IconData mapelIcon(MataPelajaran m) {
  switch (m) {
    case MataPelajaran.matematika:      return Icons.calculate_rounded;
    case MataPelajaran.bahasaIndonesia: return Icons.menu_book_rounded;
    case MataPelajaran.ipa:             return Icons.science_rounded;
    case MataPelajaran.ips:             return Icons.public_rounded;
    case MataPelajaran.bahasaInggris:   return Icons.translate_rounded;
    case MataPelajaran.agama:           return Icons.auto_stories_rounded;
    case MataPelajaran.senibudaya:      return Icons.palette_rounded;
    case MataPelajaran.penjaskes:       return Icons.sports_soccer_rounded;
  }
}

IconData tipeIcon(TipeKonten t) {
  switch (t) {
    case TipeKonten.video: return Icons.play_circle_rounded;
    case TipeKonten.pdf:   return Icons.picture_as_pdf_rounded;
    case TipeKonten.kuis:  return Icons.quiz_rounded;
    case TipeKonten.tugas: return Icons.assignment_rounded;
  }
}

Color tipeColor(TipeKonten t) {
  switch (t) {
    case TipeKonten.video: return _C.blue;
    case TipeKonten.pdf:   return _C.red;
    case TipeKonten.kuis:  return _C.purple;
    case TipeKonten.tugas: return _C.orange;
  }
}

String tipeLabel(TipeKonten t) {
  switch (t) {
    case TipeKonten.video: return 'Video';
    case TipeKonten.pdf:   return 'Dokumen';
    case TipeKonten.kuis:  return 'Kuis';
    case TipeKonten.tugas: return 'Tugas';
  }
}

Color statusColor(StatusMateri s) {
  switch (s) {
    case StatusMateri.selesai:      return _C.teal;
    case StatusMateri.sedangDibaca: return _C.amber;
    case StatusMateri.belumDibaca:  return _C.subtle.withOpacity(0.5);
  }
}

IconData statusIcon(StatusMateri s) {
  switch (s) {
    case StatusMateri.selesai:      return Icons.check_circle_rounded;
    case StatusMateri.sedangDibaca: return Icons.timelapse_rounded;
    case StatusMateri.belumDibaca:  return Icons.radio_button_unchecked_rounded;
  }
}
