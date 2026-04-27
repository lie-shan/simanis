import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bottom_navbar.dart';
import '../services/pembayaran_service.dart';
import '../services/siswa_service.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _C {
  static const primary     = Color.fromARGB(255, 0,   77,  52);
  static const primaryDark = Color.fromARGB(255, 2,   44,  34);
  static const surface     = Color.fromARGB(255, 248, 249, 250);
  static const card        = Color.fromARGB(255, 255, 255, 255);
  static const onSurface   = Color.fromARGB(255, 25,  28,  29);
  static const subtle      = Color.fromARGB(255, 63,  73,  67);
  static const border      = Color.fromARGB(255, 190, 201, 193);
  static const chip        = Color.fromARGB(255, 237, 238, 239);
  static const purple      = Color.fromARGB(255, 147, 51,  234);
  static const amber       = Color.fromARGB(255, 245, 158, 11);
  static const red         = Color.fromARGB(255, 225, 29,  72);
  static const teal        = Color.fromARGB(255, 13,  148, 136);
  static const blue        = Color.fromARGB(255, 2,   132, 199);
}

// ─── Enums & Models ───────────────────────────────────────────────────────────
enum StatusBayar { lunas, belumBayar, telat }

enum JenisBayar { ujian, acara, pendaftaran }

class TagihanItem {
  final String id;
  final String namaSiswa;
  final String kelas;
  final String nis;
  final JenisBayar jenis;
  final int nominal;
  final String bulan;
  final String jatuhTempo;
  final StatusBayar status;
  final String? tanggalBayar;
  final String? metodeBayar;
  final int? siswaDbId; // ID siswa dari database (untuk edit)

  const TagihanItem({
    required this.id,
    required this.namaSiswa,
    required this.kelas,
    required this.nis,
    required this.jenis,
    required this.nominal,
    required this.bulan,
    required this.jatuhTempo,
    required this.status,
    this.tanggalBayar,
    this.metodeBayar,
    this.siswaDbId,
  });

  TagihanItem copyWith({
    String? id,
    String? namaSiswa,
    String? kelas,
    String? nis,
    JenisBayar? jenis,
    int? nominal,
    String? bulan,
    String? jatuhTempo,
    StatusBayar? status,
    String? tanggalBayar,
    String? metodeBayar,
    int? siswaDbId,
    bool clearTanggalBayar = false,
    bool clearMetodeBayar = false,
  }) {
    return TagihanItem(
      id: id ?? this.id,
      namaSiswa: namaSiswa ?? this.namaSiswa,
      kelas: kelas ?? this.kelas,
      nis: nis ?? this.nis,
      jenis: jenis ?? this.jenis,
      nominal: nominal ?? this.nominal,
      bulan: bulan ?? this.bulan,
      jatuhTempo: jatuhTempo ?? this.jatuhTempo,
      status: status ?? this.status,
      tanggalBayar:
          clearTanggalBayar ? null : (tanggalBayar ?? this.tanggalBayar),
      metodeBayar:
          clearMetodeBayar ? null : (metodeBayar ?? this.metodeBayar),
      siswaDbId: siswaDbId ?? this.siswaDbId,
    );
  }

  // Factory constructor to convert API data to TagihanItem
  factory TagihanItem.fromJson(Map<String, dynamic> json) {
    // Gunakan kode_transaksi sebagai ID jika tersedia, fallback ke id
    final String itemId = json['kode_transaksi']?.toString() ??
                         json['id']?.toString() ??
                         '';
    return TagihanItem(
      id: itemId,
      namaSiswa: json['nama_siswa'] ?? '-',
      kelas: json['nama_kelas'] ?? json['kelas'] ?? '-',
      nis: json['nis'] ?? '-',
      jenis: _parseJenisBayar(json['jenis_pembayaran'] ?? 'ujian'),
      nominal: _parseJumlah(json['jumlah']),
      bulan: json['keterangan'] ?? '-',
      jatuhTempo: json['tanggal_jatuh_tempo'] != null
          ? _formatDateFromApi(json['tanggal_jatuh_tempo'])
          : '-',
      status: _parseStatusBayar(json['status'] ?? 'belum_bayar'),
      tanggalBayar: json['tanggal_bayar'] != null
          ? _formatDateFromApi(json['tanggal_bayar'])
          : null,
      metodeBayar: json['metode_pembayaran'],
      siswaDbId: json['siswa_id'] != null ? int.tryParse(json['siswa_id'].toString()) : null,
    );
  }

  // Helper methods for parsing
  static int _parseJumlah(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      // Handle format like "500000.00" - parse as double then convert to int
      final doubleValue = double.tryParse(value);
      if (doubleValue != null) {
        return doubleValue.toInt();
      }
      // Fallback: clean and parse
      final cleaned = value.replaceAll('.', '').replaceAll(',', '');
      return int.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  static JenisBayar _parseJenisBayar(String value) {
    switch (value.toLowerCase()) {
      case 'acara':
        return JenisBayar.acara;
      case 'pendaftaran':
        return JenisBayar.pendaftaran;
      case 'ujian':
      default:
        return JenisBayar.ujian;
    }
  }

  static StatusBayar _parseStatusBayar(String value) {
    switch (value.toLowerCase()) {
      case 'lunas':
        return StatusBayar.lunas;
      case 'telat':
      case 'terlambat':
        return StatusBayar.telat;
      case 'belum_bayar':
      default:
        return StatusBayar.belumBayar;
    }
  }

  static String _formatDateFromApi(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const b = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day.toString().padLeft(2, '0')} ${b[date.month]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

// ─── Initial Dummy Data ───────────────────────────────────────────────────────
final List<TagihanItem> _initialDummyTagihan = [
  const TagihanItem(
    id: 'TRX-001',
    namaSiswa: 'Ahmad Fauzan',
    kelas: 'Kelas 2A',
    nis: '2024001',
    jenis: JenisBayar.ujian,
    nominal: 350000,
    bulan: 'April 2025',
    jatuhTempo: '10 Apr 2025',
    status: StatusBayar.lunas,
    tanggalBayar: '08 Apr 2025',
    metodeBayar: 'Transfer Bank',
  ),
  const TagihanItem(
    id: 'TRX-002',
    namaSiswa: 'Siti Rahmawati',
    kelas: 'Kelas 1B',
    nis: '2024002',
    jenis: JenisBayar.ujian,
    nominal: 350000,
    bulan: 'April 2025',
    jatuhTempo: '10 Apr 2025',
    status: StatusBayar.belumBayar,
  ),
  const TagihanItem(
    id: 'TRX-003',
    namaSiswa: 'Rizky Maulana',
    kelas: 'Kelas 3A',
    nis: '2024003',
    jenis: JenisBayar.pendaftaran,
    nominal: 2500000,
    bulan: 'TA 2024/2025',
    jatuhTempo: '01 Apr 2025',
    status: StatusBayar.telat,
  ),
  const TagihanItem(
    id: 'TRX-004',
    namaSiswa: 'Nurul Hidayah',
    kelas: 'Kelas 2B',
    nis: '2024004',
    jenis: JenisBayar.ujian,
    nominal: 350000,
    bulan: 'April 2025',
    jatuhTempo: '10 Apr 2025',
    status: StatusBayar.lunas,
    tanggalBayar: '05 Apr 2025',
    metodeBayar: 'QRIS',
  ),
  const TagihanItem(
    id: 'TRX-005',
    namaSiswa: 'Bagas Prasetyo',
    kelas: 'Kelas 1A',
    nis: '2024005',
    jenis: JenisBayar.acara,
    nominal: 150000,
    bulan: 'April 2025',
    jatuhTempo: '15 Apr 2025',
    status: StatusBayar.belumBayar,
  ),
  const TagihanItem(
    id: 'TRX-006',
    namaSiswa: 'Dewi Anggraini',
    kelas: 'Kelas 3B',
    nis: '2024006',
    jenis: JenisBayar.acara,
    nominal: 450000,
    bulan: 'TA 2024/2025',
    jatuhTempo: '20 Mar 2025',
    status: StatusBayar.telat,
  ),
  const TagihanItem(
    id: 'TRX-007',
    namaSiswa: 'Muhammad Iqbal',
    kelas: 'Kelas 2A',
    nis: '2024007',
    jenis: JenisBayar.pendaftaran,
    nominal: 350000,
    bulan: 'April 2025',
    jatuhTempo: '10 Apr 2025',
    status: StatusBayar.belumBayar,
  ),
  const TagihanItem(
    id: 'TRX-008',
    namaSiswa: 'Aulia Zahra',
    kelas: 'Kelas 1A',
    nis: '2024008',
    jenis: JenisBayar.acara,
    nominal: 200000,
    bulan: 'April 2025',
    jatuhTempo: '10 Apr 2025',
    status: StatusBayar.lunas,
    tanggalBayar: '07 Apr 2025',
    metodeBayar: 'Tunai',
  ),
];

// ─── Master Data Siswa ────────────────────────────────────────────────────────
class _SiswaData {
  final int id;
  final String nama;
  final String nis;
  final String kelas;
  const _SiswaData({required this.id, required this.nama, required this.nis, required this.kelas});
}

final List<_SiswaData> _masterSiswa = [
  const _SiswaData(id: 1, nama: 'Ahmad Fauzan',    nis: '2024001', kelas: 'Kelas 2A'),
  const _SiswaData(id: 2, nama: 'Siti Rahmawati',  nis: '2024002', kelas: 'Kelas 1B'),
  const _SiswaData(id: 3, nama: 'Rizky Maulana',   nis: '2024003', kelas: 'Kelas 3A'),
  const _SiswaData(id: 4, nama: 'Nurul Hidayah',   nis: '2024004', kelas: 'Kelas 2B'),
  const _SiswaData(id: 5, nama: 'Bagas Prasetyo',  nis: '2024005', kelas: 'Kelas 1A'),
  const _SiswaData(id: 6, nama: 'Dewi Anggraini',  nis: '2024006', kelas: 'Kelas 3B'),
  const _SiswaData(id: 7, nama: 'Muhammad Iqbal',  nis: '2024007', kelas: 'Kelas 2A'),
  const _SiswaData(id: 8, nama: 'Aulia Zahra',     nis: '2024008', kelas: 'Kelas 1A'),
];

// ─── Helper Functions ─────────────────────────────────────────────────────────

// FIX: Bug logika — prefix 'Rp' tidak ikut di-reverse
String _formatRupiah(int nominal) {
  final str = nominal.toString();
  final buffer = StringBuffer();
  int counter = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (counter > 0 && counter % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
    counter++;
  }
  return 'Rp ${buffer.toString().split('').reversed.join('')}';
}

String _generateId(List<TagihanItem> list) {
  // Format: TRX-XXXXXXXXXX (10 angka unik berdasarkan timestamp)
  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final uniqueDigits = timestamp.substring(timestamp.length - 10);
  return 'TRX-$uniqueDigits';
}

Color _statusColor(StatusBayar s) {
  switch (s) {
    case StatusBayar.lunas:      return _C.teal;
    case StatusBayar.belumBayar: return _C.amber;
    case StatusBayar.telat:      return _C.red;
    default:                     return _C.subtle;
  }
}

String _statusLabel(StatusBayar s) {
  switch (s) {
    case StatusBayar.lunas:      return 'Lunas';
    case StatusBayar.belumBayar: return 'Belum Bayar';
    case StatusBayar.telat:      return 'Terlambat';
    default:                     return '-';
  }
}

IconData _statusIcon(StatusBayar s) {
  switch (s) {
    case StatusBayar.lunas:      return Icons.check_circle_rounded;
    case StatusBayar.belumBayar: return Icons.hourglass_top_rounded;
    case StatusBayar.telat:      return Icons.warning_rounded;
    default:                     return Icons.help_outline_rounded;
  }
}

Color _jenisColor(JenisBayar j) {
  switch (j) {
    case JenisBayar.ujian:       return _C.primary;
    case JenisBayar.acara:       return _C.purple;
    case JenisBayar.pendaftaran: return _C.blue;
    default:                     return _C.subtle;
  }
}

String _jenisLabel(JenisBayar j) {
  switch (j) {
    case JenisBayar.ujian:       return 'Ujian';
    case JenisBayar.acara:       return 'Acara';
    case JenisBayar.pendaftaran: return 'Pendaftaran';
    default:                     return 'Lainnya';
  }
}

IconData _jenisIcon(JenisBayar j) {
  switch (j) {
    case JenisBayar.ujian:       return Icons.quiz_rounded;
    case JenisBayar.acara:       return Icons.celebration_rounded;
    case JenisBayar.pendaftaran: return Icons.app_registration_rounded;
    default:                     return Icons.payments_rounded;
  }
}

// ─── Halaman Pembayaran ───────────────────────────────────────────────────────
class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage>
    with SingleTickerProviderStateMixin {
  late List<TagihanItem> _tagihanList;

  // Key untuk ScaffoldMessenger lokal agar SnackBar muncul di dalam halaman ini
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  StatusBayar? _filterStatus;
  JenisBayar?  _filterJenis;
  String _searchQuery = '';
  late AnimationController _animCtrl;
  final _searchController = TextEditingController();

  // Service
  final PembayaranService _pembayaranService = PembayaranService();
  final SiswaService _siswaService = SiswaService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tagihanList = [];

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();

    // Load data from API
    _loadData();

    // FIX: dipindah dari build() ke initState()
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Load Data from API ─────────────────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _pembayaranService.getAllPembayaran();
      setState(() {
        _tagihanList = data.map((json) => TagihanItem.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Gagal memuat data: $e', Icons.error_rounded, _C.red);
    }
  }

  // ── CRUD: Create ─────────────────────────────────────────────────────────────
  Future<void> _createTagihan(TagihanItem item) async {
    try {
      // Cari siswa_id dari database berdasarkan NIS atau gunakan siswaDbId jika tersedia
      int? siswaDbId = item.siswaDbId;
      if (siswaDbId == null || siswaDbId <= 0) {
        siswaDbId = await _getSiswaDbIdFromNis(item.nis);
      }
      if (siswaDbId == null || siswaDbId <= 0) {
        _showSnackBar('Siswa dengan NIS ${item.nis} tidak ditemukan di database', Icons.error_rounded, _C.red);
        return;
      }

      // Tentukan status berdasarkan data item
      final String statusName = item.status.name;

      // Prepare data for API dengan semua field
      final apiData = {
        'siswa_id': siswaDbId,
        'jenis_pembayaran': item.jenis.name,
        'jumlah': item.nominal,
        'tanggal_jatuh_tempo': _parseDateToApiFormat(item.jatuhTempo),
        'keterangan': item.bulan,
        'kode_transaksi': item.id, // TRX-XXXXXXXXXX
        'status': statusName, // 'lunas' atau 'belum_bayar'
        if (item.tanggalBayar != null) 'tanggal_bayar': _parseDateToApiFormat(item.tanggalBayar!),
        if (item.metodeBayar != null) 'metode_pembayaran': item.metodeBayar,
      };

      await _pembayaranService.createPembayaran(apiData);
      await _loadData(); // Refresh data
      _showSnackBar(
          'Tagihan berhasil ditambahkan', Icons.check_circle_rounded, _C.teal);
    } catch (e) {
      _showSnackBar('Gagal menambah tagihan: $e', Icons.error_rounded, _C.red);
    }
  }

  // ── CRUD: Update ─────────────────────────────────────────────────────────────
  Future<void> _updateTagihan(TagihanItem updated, {bool processAsPayment = false}) async {
    try {
      // Jika ada tanggal bayar dan metode, proses sebagai pembayaran
      if (processAsPayment && updated.tanggalBayar != null && updated.metodeBayar != null) {
        await _pembayaranService.processPayment(updated.id, {
          'metode_pembayaran': updated.metodeBayar,
        });
      } else {
        // Update data tagihan saja (tanpa ubah status)
        final apiData = {
          'jenis_pembayaran': updated.jenis.name,
          'jumlah': updated.nominal,
          'tanggal_jatuh_tempo': _parseDateToApiFormat(updated.jatuhTempo),
          'keterangan': updated.bulan,
        };
        await _pembayaranService.updatePembayaran(updated.id, apiData);
      }

      await _loadData(); // Refresh data
      _showSnackBar(
          'Tagihan berhasil diperbarui', Icons.edit_rounded, _C.blue);
    } catch (e) {
      _showSnackBar('Gagal update tagihan: $e', Icons.error_rounded, _C.red);
    }
  }

  // ── CRUD: Delete ─────────────────────────────────────────────────────────────
  Future<void> _deleteTagihan(String id) async {
    try {
      await _pembayaranService.deletePembayaran(id);
      await _loadData(); // Refresh data
      _showSnackBar(
        'Tagihan dihapus',
        Icons.delete_rounded,
        _C.red,
      );
    } catch (e) {
      _showSnackBar('Gagal menghapus tagihan: $e', Icons.error_rounded, _C.red);
    }
  }

  // ── Tandai Lunas (Update khusus) ──────────────────────────────────────────
  Future<void> _tandaiLunas(TagihanItem item) async {
    try {
      await _pembayaranService.processPayment(item.id, {
        'metode_pembayaran': 'Tunai', // Default metode
      });

      await _loadData(); // Refresh data
      _showSnackBar(
          '${item.namaSiswa} ditandai lunas', Icons.check_circle_rounded, _C.teal);
    } catch (e) {
      _showSnackBar('Gagal menandai lunas: $e', Icons.error_rounded, _C.red);
    }
  }

  // Helper to parse date from display format to API format
  String? _parseDateToApiFormat(String dateStr) {
    try {
      // Format input: "10 Apr 2025" or "DD MMM YYYY"
      final parts = dateStr.split(' ');
      if (parts.length != 3) return null;

      final day = parts[0];
      final monthName = parts[1].toLowerCase();
      final year = parts[2];

      final months = {
        'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04',
        'mei': '05', 'jun': '06', 'jul': '07', 'agu': '08',
        'ags': '08',  // Alternatif Agustus
        'sep': '09', 'okt': '10', 'nov': '11', 'des': '12',
      };

      final month = months[monthName.substring(0, 3)];
      if (month == null) return null;

      return '$year-$month-$day';
    } catch (e) {
      return null;
    }
  }

  String _bulanSingkat(int m) {
    const b = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return b[m];
  }

  // Helper untuk mendapatkan siswa_id dari database berdasarkan NIS
  // Coba cari di master data dulu, kalau tidak ada coba ambil dari API
  Future<int?> _getSiswaDbIdFromNis(String nis) async {
    // Coba cari di master data lokal dulu
    try {
      final siswa = _masterSiswa.firstWhere((s) => s.nis == nis);
      return siswa.id;
    } catch (_) {
      // Jika tidak ditemukan di master, coba ambil dari API
      try {
        final allSiswa = await _siswaService.getAllSiswa();
        final siswa = allSiswa.firstWhere((s) => s['nis'] == nis);
        return siswa['id'] as int?;
      } catch (_) {
        return null;
      }
    }
  }

  void _showSnackBar(String msg, IconData icon, Color color,
      {SnackBarAction? action}) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    _messengerKey.currentState?.clearSnackBars();
    _messengerKey.currentState?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                msg,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ],
        ),
        action: action,
      ),
    );
  }

  void _confirmDelete(BuildContext context, TagihanItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Tagihan?',
            style: GoogleFonts.manrope(
                fontWeight: FontWeight.w800, color: _C.onSurface)),
        content: Text(
          'Tagihan ${item.namaSiswa} (${item.id}) akan dihapus secara permanen.',
          style: GoogleFonts.inter(fontSize: 13, color: _C.subtle),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: _C.subtle)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTagihan(item.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _C.red,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Hapus',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  List<TagihanItem> get _filtered {
    return _tagihanList.where((item) {
      final matchStatus =
          _filterStatus == null || item.status == _filterStatus;
      final matchJenis = _filterJenis == null || item.jenis == _filterJenis;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          item.namaSiswa.toLowerCase().contains(q) ||
          item.kelas.toLowerCase().contains(q) ||
          item.nis.contains(q);
      return matchStatus && matchJenis && matchSearch;
    }).toList();
  }

  int get _totalLunas =>
      _tagihanList.where((e) => e.status == StatusBayar.lunas).length;
  int get _totalBelum =>
      _tagihanList.where((e) => e.status == StatusBayar.belumBayar).length;
  int get _totalTelat =>
      _tagihanList.where((e) => e.status == StatusBayar.telat).length;
  int get _totalPemasukan => _tagihanList
      .where((e) => e.status == StatusBayar.lunas)
      .fold(0, (sum, e) => sum + e.nominal);
  int get _totalTunggakan => _tagihanList
      .where((e) => e.status != StatusBayar.lunas)
      .fold(0, (sum, e) => sum + e.nominal);

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
      backgroundColor: _C.surface,
      floatingActionButton: _buildFab(context),
      bottomNavigationBar: SiakadBottomNavBar(
        selectedIndex: 1,
        onTap: (_) => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // ── STICKY: Header ──────────────────────────────────────────────
          _buildHeader(context),

          // ── STICKY: Revenue Banner + Summary Grid + Search + Jenis Filter ──
          AnimatedBuilder(
            animation: _animCtrl,
            builder: (_, child) => FadeTransition(
              opacity: _animCtrl,
              child: child,
            ),
            child: Container(
              color: _C.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Revenue banner
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _buildRevenueBanner(),
                  ),
                  // Summary chips grid
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _buildSummaryRow(),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _buildSearchBar(),
                  ),
                  // Jenis filter chips
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 0, 8),
                    child: _buildJenisFilter(),
                  ),
                  // Divider subtle
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: _C.border.withOpacity(0.35),
                  ),
                ],
              ),
            ),
          ),

          // ── SCROLLABLE: List header + tagihan cards ─────────────────────
          Expanded(
            child: AnimatedBuilder(
              animation: _animCtrl,
              builder: (_, child) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.03),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: _animCtrl, curve: Curves.easeOut)),
                child: child,
              ),
              child: Column(
                children: [
                  // ── STICKY: List header row ──
                  Container(
                    color: _C.surface,
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_filtered.length} Tagihan',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _C.subtle,
                          ),
                        ),
                        Text(
                          'Terbaru',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _C.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── SCROLLABLE: tagihan cards ──
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // Cards or empty state
                        _filtered.isEmpty
                            ? SliverFillRemaining(child: _buildEmptyState())
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) => Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        i == _filtered.length - 1 ? 100 : 12),
                                    child: _TagihanCard(
                                      item: _filtered[i],
                                      onTap: () =>
                                          _showDetail(context, _filtered[i]),
                                      onDelete: () =>
                                          _confirmDelete(context, _filtered[i]),
                                    ),
                                  ),
                                  childCount: _filtered.length,
                                ),
                              ),
                      ],
                    ),
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
      color: _C.primaryDark,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 12),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pembayaran',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Kelola tagihan & keuangan siswa',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              if (_totalTelat > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _C.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        color: _C.red.withOpacity(0.4), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: Color.fromARGB(255, 252, 129, 129), size: 13),
                      const SizedBox(width: 5),
                      Text(
                        '$_totalTelat Terlambat',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color.fromARGB(255, 252, 129, 129),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Revenue Banner ────────────────────────────────────────────────────────────
  Widget _buildRevenueBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.fromARGB(255, 0, 77, 52), Color.fromARGB(255, 0, 103, 71)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Ringkasan Keuangan',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _BannerStat(
                        label: 'Total Pemasukan',
                        value: _formatRupiah(_totalPemasukan),
                        icon: Icons.trending_up_rounded,
                        color: const Color.fromARGB(255, 110, 231, 183),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: Colors.white.withOpacity(0.15),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: _BannerStat(
                        label: 'Total Tunggakan',
                        value: _formatRupiah(_totalTunggakan),
                        icon: Icons.trending_down_rounded,
                        color: const Color.fromARGB(255, 252, 165, 165),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary Row ───────────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        _SummaryChip(
          label: 'Semua',
          count: _tagihanList.length,
          color: _C.primary,
          isSelected: _filterStatus == null,
          onTap: () => setState(() => _filterStatus = null),
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          label: 'Lunas',
          count: _totalLunas,
          color: _C.teal,
          isSelected: _filterStatus == StatusBayar.lunas,
          onTap: () => setState(() => _filterStatus = StatusBayar.lunas),
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          label: 'Belum',
          count: _totalBelum,
          color: _C.amber,
          isSelected: _filterStatus == StatusBayar.belumBayar,
          onTap: () =>
              setState(() => _filterStatus = StatusBayar.belumBayar),
        ),
        const SizedBox(width: 10),
        _SummaryChip(
          label: 'Terlambat',
          count: _totalTelat,
          color: _C.red,
          isSelected: _filterStatus == StatusBayar.telat,
          onTap: () => setState(() => _filterStatus = StatusBayar.telat),
        ),
      ],
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.inter(fontSize: 14, color: _C.onSurface),
        decoration: InputDecoration(
          hintText: 'Cari nama siswa, kelas, NIS…',
          hintStyle: GoogleFonts.inter(
              fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(Icons.search_rounded,
              color: Colors.grey.shade400, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close_rounded,
                      color: Colors.grey.shade400, size: 20),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ── Jenis Filter ─────────────────────────────────────────────────────────────
  Widget _buildJenisFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: JenisBayar.values.map((jenis) {
          final isActive = _filterJenis == jenis;
          final color = _jenisColor(jenis);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  setState(() => _filterJenis = isActive ? null : jenis),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? color : _C.card,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                    color: isActive
                        ? color
                        : _C.border.withOpacity(0.6),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                              color: color.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_jenisIcon(jenis),
                        size: 13,
                        color: isActive ? Colors.white : color),
                    const SizedBox(width: 6),
                    Text(
                      _jenisLabel(jenis),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? Colors.white : _C.subtle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── FAB ──────────────────────────────────────────────────────────────────────
  Widget _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showFormTagihan(context),
      backgroundColor: _C.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.12,
            child: Icon(Icons.account_balance_wallet_rounded,
                size: 100, color: _C.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tagihan',
            style: GoogleFonts.manrope(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _C.subtle,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Coba ubah filter atau kata kunci',
            style: GoogleFonts.inter(
                fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // ── Modals ────────────────────────────────────────────────────────────────────
  void _showDetail(BuildContext context, TagihanItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        item: item,
        onTandaiLunas: () {
          Navigator.pop(context);
          _tandaiLunas(item);
        },
        onEdit: () {
          Navigator.pop(context);
          _showFormTagihan(context, existing: item);
        },
        onDelete: () {
          Navigator.pop(context);
          _confirmDelete(context, item);
        },
      ),
    );
  }

  void _showFormTagihan(BuildContext context, {TagihanItem? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormTagihanSheet(
        existing: existing,
        onSave: (item, {bool processAsPayment = false}) =>
            existing == null ? _createTagihan(item) : _updateTagihan(item, processAsPayment: processAsPayment),
        generateId: () => _generateId(_tagihanList),
      ),
    );
  }
}

// ─── Banner Stat Widget ───────────────────────────────────────────────────────
class _BannerStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BannerStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withOpacity(0.65),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Summary Chip ─────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? color : _C.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : _C.border.withOpacity(0.5),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white.withOpacity(0.85)
                      : _C.subtle,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tagihan Card ─────────────────────────────────────────────────────────────
class _TagihanCard extends StatelessWidget {
  final TagihanItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TagihanCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(item.status);
    final jc = _jenisColor(item.jenis);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: _C.red.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: _C.red, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _C.border.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Accent bar
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: sc,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: jc.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                                color: jc.withOpacity(0.2)),
                          ),
                          child: Icon(_jenisIcon(item.jenis),
                              color: jc, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.namaSiswa,
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _C.onSurface,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _MiniChip(
                                      label: item.kelas,
                                      color: _C.primary),
                                  const SizedBox(width: 6),
                                  _MiniChip(
                                      label: _jenisLabel(item.jenis),
                                      color: jc),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: sc.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon(item.status),
                                  size: 11, color: sc),
                              const SizedBox(width: 4),
                              Text(
                                _statusLabel(item.status),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: sc,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(
                        height: 1,
                        color: _C.border.withOpacity(0.4)),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Text(
                          _formatRupiah(item.nominal),
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              item.status == StatusBayar.lunas
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.calendar_today_rounded,
                              size: 12,
                              color: item.status == StatusBayar.lunas
                                  ? _C.teal
                                  : item.status == StatusBayar.telat
                                      ? _C.red
                                      : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.status == StatusBayar.lunas
                                  ? item.tanggalBayar ?? '-'
                                  : 'Tempo: ${item.jatuhTempo}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: item.status == StatusBayar.lunas
                                    ? _C.teal
                                    : item.status == StatusBayar.telat
                                        ? _C.red
                                        : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (item.status == StatusBayar.lunas &&
                        item.metodeBayar != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.payment_rounded,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            item.metodeBayar!,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            item.id,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.date_range_rounded,
                            size: 12, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          item.bulan,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (item.status != StatusBayar.lunas) ...[
                          const Spacer(),
                          Text(
                            item.id,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Mini Chip ────────────────────────────────────────────────────────────────
class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
class _DetailSheet extends StatelessWidget {
  final TagihanItem item;
  final VoidCallback onTandaiLunas;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DetailSheet({
    required this.item,
    required this.onTandaiLunas,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final sc = _statusColor(item.status);
    final jc = _jenisColor(item.jenis);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: const BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _C.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: jc.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: jc.withOpacity(0.25), width: 2),
                  ),
                  child:
                      Icon(_jenisIcon(item.jenis), color: jc, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatRupiah(item.nominal),
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _C.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _MiniChip(
                              label: _jenisLabel(item.jenis), color: jc),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: sc.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_statusIcon(item.status),
                                    size: 10, color: sc),
                                const SizedBox(width: 4),
                                Text(
                                  _statusLabel(item.status),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: sc,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: _C.border.withOpacity(0.4)),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _DetailRow(
                    icon: Icons.person_rounded,
                    label: 'Nama Siswa',
                    value: item.namaSiswa),
                _DetailRow(
                    icon: Icons.badge_rounded,
                    label: 'NIS',
                    value: item.nis),
                _DetailRow(
                    icon: Icons.school_rounded,
                    label: 'Kelas',
                    value: item.kelas),
                _DetailRow(
                    icon: Icons.category_rounded,
                    label: 'Jenis Pembayaran',
                    value: _jenisLabel(item.jenis)),
                _DetailRow(
                    icon: Icons.date_range_rounded,
                    label: 'Tanggal Bayar',
                    value: item.tanggalBayar ?? '-'),
                _DetailRow(
                    icon: Icons.event_rounded,
                    label: 'Jatuh Tempo',
                    value: item.jatuhTempo),
                if (item.metodeBayar != null)
                  _DetailRow(
                      icon: Icons.payment_rounded,
                      label: 'Metode Bayar',
                      value: item.metodeBayar!),
                _DetailRow(
                    icon: Icons.qr_code_rounded,
                    label: 'ID Transaksi',
                    value: item.id),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Action Buttons ──
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottomPad),
            child: Column(
              children: [
                // Baris 1: Tutup | Edit | Hapus
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _C.border),
                          padding:
                              const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: _C.onSurface),
                        label: Text('Tutup',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _C.onSurface)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: _C.blue.withOpacity(0.5)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.edit_rounded,
                            size: 16, color: _C.blue),
                        label: Text('Edit',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _C.blue)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                            color: _C.red.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 13, horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Icon(Icons.delete_rounded,
                          size: 18, color: _C.red),
                    ),
                  ],
                ),

                // Baris 2: Tandai Lunas
                if (item.status != StatusBayar.lunas) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onTandaiLunas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _C.primary,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded,
                          size: 16, color: Colors.white),
                      label: Text(
                        'Tandai Lunas',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form Tambah / Edit Tagihan Sheet ─────────────────────────────────────────
class _FormTagihanSheet extends StatefulWidget {
  final TagihanItem? existing;
  final void Function(TagihanItem, {bool processAsPayment}) onSave;
  final String Function() generateId;

  const _FormTagihanSheet({
    this.existing,
    required this.onSave,
    required this.generateId,
  });

  @override
  State<_FormTagihanSheet> createState() => _FormTagihanSheetState();
}

class _FormTagihanSheetState extends State<_FormTagihanSheet> {
  late JenisBayar _jenis;
  late StatusBayar _status;
  _SiswaData? _selectedSiswa;
  late TextEditingController _nominalController;
  late TextEditingController _metodeBayarController;
  DateTime? _selectedPeriode;
  DateTime? _selectedJatuhTempo;

  final _formKey = GlobalKey<FormState>();
  final _siswaService = SiswaService();
  List<_SiswaData> _siswaList = [];
  bool _isLoadingSiswa = false;

  bool get _isEdit => widget.existing != null;

  String _formatPeriode(DateTime d) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${bulan[d.month]} ${d.year}';
  }

  String _formatJatuhTempo(DateTime d) {
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${bulan[d.month]} ${d.year}';
  }

  DateTime? _parseJatuhTempo(String s) {
    if (s.isEmpty || s == '-') return null;
    try {
      // Coba parse format API: "2025-04-28"
      if (s.contains('-') && s.length == 10) {
        return DateTime.parse(s);
      }
      // Parse format display: "28 Agu 2025"
      const bulan = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'Mei': 5, 'Jun': 6,
        'Jul': 7, 'Agu': 8, 'Ags': 8, 'Sep': 9, 'Okt': 10, 'Nov': 11, 'Des': 12
      };
      final parts = s.split(' ');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 1;
        final month = bulan[parts[1]] ?? 1;
        final year = int.tryParse(parts[2]) ?? 2025;
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  DateTime? _parsePeriode(String s) {
    try {
      const bulan = {
        'Januari': 1, 'Februari': 2, 'Maret': 3, 'April': 4, 'Mei': 5, 'Juni': 6,
        'Juli': 7, 'Agustus': 8, 'September': 9, 'Oktober': 10, 'November': 11, 'Desember': 12
      };
      final parts = s.split(' ');
      if (parts.length == 2) {
        return DateTime(int.parse(parts[1]), bulan[parts[0]] ?? 1, 1);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _pickPeriode() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPeriode ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Pilih Tanggal Bayar',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.primary,
            onPrimary: Colors.white,
            surface: _C.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedPeriode = picked);
  }

  Future<void> _pickJatuhTempo() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedJatuhTempo ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Pilih Jatuh Tempo',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _C.primary,
            onPrimary: Colors.white,
            surface: _C.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedJatuhTempo = picked);
  }

  @override
  void initState() {
    super.initState();
    _loadSiswa(); // Load data siswa dari API
    final e = widget.existing;
    _jenis  = e?.jenis  ?? JenisBayar.ujian;
    // Status otomatis: Lunas jika ada tanggal bayar, Belum Bayar jika tidak
    _status = e?.status ?? StatusBayar.belumBayar;
    _nominalController     = TextEditingController(text: e != null ? e.nominal.toString() : '');
    _metodeBayarController = TextEditingController(text: e?.metodeBayar ?? '');
    if (e != null) {
      // Simpan data sementara, akan di-set setelah _siswaList terload
      _tempExistingSiswa = _SiswaData(
        id: e.siswaDbId ?? -1,
        nama: e.namaSiswa,
        nis: e.nis,
        kelas: e.kelas,
      );
      // Parse tanggal bayar dari format DD MMM YYYY
      _selectedPeriode    = e.tanggalBayar != null ? _parseJatuhTempo(e.tanggalBayar!) : null;
      _selectedJatuhTempo = _parseJatuhTempo(e.jatuhTempo);
      // Set status dari data yang ada
      _status = e.status;
    }
  }

  _SiswaData? _tempExistingSiswa; // Sementara untuk menyimpan data saat init

  Future<void> _loadSiswa() async {
    setState(() => _isLoadingSiswa = true);
    try {
      final data = await _siswaService.getAllSiswa();
      setState(() {
        _siswaList = data.map((s) => _SiswaData(
          id: s['id'] ?? 0,
          nama: s['nama'] ?? '-',
          nis: s['nis'] ?? '-',
          kelas: s['nama_kelas'] ?? s['kelas'] ?? '-',
        )).toList();
        _isLoadingSiswa = false;
        // Jika ada data existing, cari dan pilih siswa yang sesuai
        if (_tempExistingSiswa != null) {
          try {
            _selectedSiswa = _siswaList.firstWhere((s) => s.nis == _tempExistingSiswa!.nis);
          } catch (_) {
            // Jika tidak ditemukan di list, gunakan data existing
            _selectedSiswa = _tempExistingSiswa;
          }
          _tempExistingSiswa = null;
        }
      });
    } catch (e) {
      setState(() => _isLoadingSiswa = false);
      // Fallback ke _masterSiswa jika gagal
      _siswaList = _masterSiswa;
    }
  }

  @override
  void dispose() {
    _nominalController.dispose();
    _metodeBayarController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSiswa == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pilih nama siswa terlebih dahulu',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: _C.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
      return;
    }
    if (_selectedJatuhTempo == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pilih tanggal jatuh tempo',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: _C.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
      return;
    }

    final nominal = int.tryParse(_nominalController.text.replaceAll('.', ''));
    if (nominal == null || nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Nominal tidak valid',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: _C.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
      return;
    }

    // Validasi: jika tanggal bayar diisi, metode bayar wajib
    if (_selectedPeriode != null && _metodeBayarController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Metode bayar wajib diisi jika tanggal bayar diisi',
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: _C.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ));
      return;
    }

    // Status otomatis: Lunas jika tanggal bayar diisi, Belum Bayar jika tidak
    final isLunas = _selectedPeriode != null;
    final tanggalBayar = _selectedPeriode != null ? _formatJatuhTempo(_selectedPeriode!) : null;

    final item = TagihanItem(
      id: widget.existing?.id ?? widget.generateId(),
      namaSiswa: _selectedSiswa!.nama,
      nis: _selectedSiswa!.nis,
      kelas: _selectedSiswa!.kelas,
      jenis: _jenis,
      nominal: nominal,
      bulan: _formatPeriode(_selectedJatuhTempo!), // Gunakan periode bulan tahun
      jatuhTempo: _formatJatuhTempo(_selectedJatuhTempo!),
      status: isLunas ? StatusBayar.lunas : StatusBayar.belumBayar,
      metodeBayar: _metodeBayarController.text.trim().isEmpty
          ? null
          : _metodeBayarController.text.trim(),
      tanggalBayar: tanggalBayar,
      siswaDbId: _selectedSiswa!.id > 0 ? _selectedSiswa!.id : widget.existing?.siswaDbId,
    );

    // Tentukan apakah perlu proses sebagai pembayaran (untuk edit)
    final bool isAddingPayment = _isEdit && 
                                  _selectedPeriode != null && 
                                  _metodeBayarController.text.trim().isNotEmpty &&
                                  widget.existing?.status != StatusBayar.lunas;

    Navigator.pop(context);
    widget.onSave(item, processAsPayment: isAddingPayment);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final keyboardPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding:
          EdgeInsets.fromLTRB(16, 16, 16, 12 + bottomPad + keyboardPad),
      decoration: const BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle ──
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _C.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Title row ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEdit ? 'Edit Tagihan' : 'Tambah Tagihan',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.onSurface,
                          ),
                        ),
                        Text(
                          _isEdit
                              ? 'Perbarui data tagihan siswa'
                              : 'Buat tagihan pembayaran baru',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Jenis Pembayaran ──
              _FormLabel('Jenis Pembayaran'),
              const SizedBox(height: 6),
              Row(
                children: JenisBayar.values.map((jenis) {
                  final isSelected = _jenis == jenis;
                  final color = _jenisColor(jenis);
                  final isLast = jenis == JenisBayar.values.last;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _jenis = jenis),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color : _C.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? color
                                  : _C.border.withOpacity(0.5),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_jenisIcon(jenis),
                                  size: 16,
                                  color:
                                      isSelected ? Colors.white : color),
                              const SizedBox(height: 3),
                              Text(
                                _jenisLabel(jenis),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.white
                                      : _C.subtle,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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


              // ── Nama Siswa (Dropdown) ──
              _FormLabel('Nama Siswa'),
              const SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  color: _C.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.border.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: _isLoadingSiswa
                  ? Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: _C.primary)),
                        const SizedBox(width: 12),
                        Text('Memuat data siswa...', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400)),
                      ],
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<_SiswaData>(
                        isExpanded: true,
                        value: _selectedSiswa,
                        hint: Row(
                          children: [
                            Icon(Icons.person_outline, size: 18, color: Colors.grey.shade400),
                            const SizedBox(width: 8),
                            Text('Pilih siswa', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400)),
                          ],
                        ),
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
                        style: GoogleFonts.inter(fontSize: 13, color: _C.onSurface),
                        dropdownColor: _C.card,
                        borderRadius: BorderRadius.circular(12),
                        items: () {
                          // Jika siswa terpilih tidak ada di list, tambahkan ke items sementara
                          final items = List<_SiswaData>.from(_siswaList);
                          if (_selectedSiswa != null && !items.any((s) => s.nis == _selectedSiswa!.nis)) {
                            items.add(_selectedSiswa!);
                          }
                          return items.map((s) => DropdownMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Icon(Icons.person_outline, size: 18, color: _C.primary),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(s.nama, style: GoogleFonts.inter(fontSize: 13, color: _C.onSurface, fontWeight: FontWeight.w600)),
                                      Text('${s.nis} • ${s.kelas}', style: GoogleFonts.inter(fontSize: 11, color: _C.subtle)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )).toList();
                        }(),
                        onChanged: (s) => setState(() => _selectedSiswa = s),
                      ),
                    ),
              ),
              const SizedBox(height: 10),

              // ── NIS + Kelas (2 kolom, auto-filled, read-only) ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('NIS'),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: _C.chip,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _C.border.withOpacity(0.4)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.badge_rounded, color: Colors.grey.shade400, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedSiswa?.nis ?? '—',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: _selectedSiswa != null ? _C.onSurface : Colors.grey.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('Kelas'),
                        const SizedBox(height: 5),
                        Container(
                          decoration: BoxDecoration(
                            color: _C.chip,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _C.border.withOpacity(0.4)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Row(
                            children: [
                              Icon(Icons.school_rounded, color: Colors.grey.shade400, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedSiswa?.kelas ?? '—',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: _selectedSiswa != null ? _C.onSurface : Colors.grey.shade400,
                                    fontWeight: FontWeight.w500,
                                  ),
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
              const SizedBox(height: 10),

              // ── Nominal ──
              _FormLabel('Nominal (Rp)'),
              const SizedBox(height: 5),
              _FormField(
                controller: _nominalController,
                hint: 'Contoh: 350000',
                icon: Icons.attach_money_rounded,
                inputType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Nominal wajib diisi';
                  }
                  if (int.tryParse(v.replaceAll('.', '')) == null) {
                    return 'Harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // ── Tanggal Bayar + Jatuh Tempo (2 kolom, date picker) ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('Tanggal Bayar'),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: _pickPeriode,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _C.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _C.border.withOpacity(0.5)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.date_range_rounded,
                                    color: _selectedPeriode != null ? _C.primary : Colors.grey.shade400,
                                    size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedPeriode != null
                                        ? _formatJatuhTempo(_selectedPeriode!)
                                        : 'Pilih tanggal bayar',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: _selectedPeriode != null ? _C.onSurface : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FormLabel('Jatuh Tempo'),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: _pickJatuhTempo,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _C.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _C.border.withOpacity(0.5)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.event_rounded,
                                    color: _selectedJatuhTempo != null ? _C.primary : Colors.grey.shade400,
                                    size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedJatuhTempo != null
                                        ? _formatJatuhTempo(_selectedJatuhTempo!)
                                        : 'Pilih tanggal',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: _selectedJatuhTempo != null ? _C.onSurface : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Metode Bayar (wajib jika tanggal bayar diisi) ──
              _FormLabel(_selectedPeriode != null ? 'Metode Bayar *' : 'Metode Bayar'),
              const SizedBox(height: 5),
              _FormField(
                controller: _metodeBayarController,
                hint: _selectedPeriode != null ? 'Wajib diisi (Transfer/QRIS/Tunai)' : 'Opsional jika belum bayar',
                icon: Icons.payment_rounded,
              ),
              const SizedBox(height: 16),

              // ── Save Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(
                      _isEdit
                          ? Icons.save_rounded
                          : Icons.add_rounded,
                      size: 17,
                      color: Colors.white),
                  label: Text(
                    _isEdit ? 'Simpan Perubahan' : 'Simpan Tagihan',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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

// ─── Reusable Widgets ─────────────────────────────────────────────────────────
class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _C.subtle,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType inputType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.inputType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border.withOpacity(0.5)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        style: GoogleFonts.inter(fontSize: 13, color: _C.onSurface),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
              fontSize: 13, color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 16),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          isDense: true,
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _C.chip,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _C.primary, size: 17),
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
                    color: _C.subtle,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _C.onSurface,
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
}