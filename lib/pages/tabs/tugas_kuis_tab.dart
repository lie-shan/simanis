import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' as xl;
import '../../models/elearning_models.dart';
import '../../widgets/shared_widgets.dart';

// ── Helper: format deadline ISO/string → human readable ──
String _formatDeadline(String? deadline) {
  if (deadline == null || deadline.isEmpty) return '-';
  const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
  try {
    final dt = DateTime.parse(deadline);
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  } catch (_) {
    return deadline; // fallback untuk format lama
  }
}

// ── Helper: initialDate aman (tidak sebelum firstDate) ──
DateTime _safeInitialDate(DateTime? selected) {
  final now = DateTime.now();
  final fallback = now.add(const Duration(days: 7));
  if (selected == null) return fallback;
  return selected.isAfter(now) ? selected : fallback;
}

// ─── Tab Tugas & Kuis ─────────────────────────────────────────────────────────
class TugasKuisTab extends StatefulWidget {
  final List<MateriItem> allMateri;
  final ValueChanged<MateriItem> onTambah;
  final ValueChanged<MateriItem> onEdit;
  final ValueChanged<String> onHapus;
  final void Function(String id, StatusMateri status) onStatusUpdate;
  const TugasKuisTab({super.key, required this.allMateri, required this.onTambah, required this.onEdit, required this.onHapus, required this.onStatusUpdate});

  @override
  State<TugasKuisTab> createState() => _TugasKuisTabState();
}

class _TugasKuisTabState extends State<TugasKuisTab> {
  @override
  Widget build(BuildContext context) {
    final selesai = widget.allMateri
        .where((m) =>
            m.status == StatusMateri.selesai &&
            (m.tipe == TipeKonten.kuis || m.tipe == TipeKonten.tugas))
        .toList();
    final pending = widget.allMateri
        .where((m) =>
            m.status != StatusMateri.selesai &&
            (m.tipe == TipeKonten.kuis || m.tipe == TipeKonten.tugas))
        .toList();

    final jumlahTugas = widget.allMateri
        .where((m) => m.tipe == TipeKonten.tugas).length;
    final jumlahKuis = widget.allMateri
        .where((m) => m.tipe == TipeKonten.kuis).length;
    final jumlahBelumDikerjakan = widget.allMateri
        .where((m) =>
            m.status == StatusMateri.belumDibaca &&
            (m.tipe == TipeKonten.kuis || m.tipe == TipeKonten.tugas))
        .length;

    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      children: [
        // ── Summary Frame ──
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
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
              ESummaryItem(
                icon: Icons.assignment_rounded,
                label: 'Tugas',
                value: '$jumlahTugas',
                color: AppColors.orange,
              ),
              ESummaryDivider(),
              ESummaryItem(
                icon: Icons.quiz_rounded,
                label: 'Kuis',
                value: '$jumlahKuis',
                color: AppColors.purple,
              ),
              ESummaryDivider(),
              ESummaryItem(
                icon: Icons.task_alt_rounded,
                label: 'Selesai',
                value: '${selesai.length}',
                color: AppColors.teal,
              ),
              ESummaryDivider(),
              ESummaryItem(
                icon: Icons.pending_actions_rounded,
                label: 'Belum\nDikerjakan',
                value: '$jumlahBelumDikerjakan',
                color: AppColors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Pending ──
        if (pending.isNotEmpty) ...[
          Text(
            'PERLU DIKERJAKAN',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ...pending.map((m) => TugasCard(item: m, isDone: false, onEdit: widget.onEdit, onHapus: widget.onHapus, onStatusUpdate: widget.onStatusUpdate)),
          const SizedBox(height: 20),
        ],

        // ── Selesai ──
        if (selesai.isNotEmpty) ...[
          Text(
            'SUDAH DIKERJAKAN',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          ...selesai.map((m) => TugasCard(item: m, isDone: true, onEdit: widget.onEdit, onHapus: widget.onHapus, onStatusUpdate: widget.onStatusUpdate)),
        ],

        if (pending.isEmpty && selesai.isEmpty)
          EEmptyState(
            icon: Icons.task_alt_rounded,
            title: 'Tidak ada tugas',
            subtitle: 'Semua tugas dan kuis sudah selesai dikerjakan!',
          ),
      ],
    );
  }
}

// ─── Tugas Card ───────────────────────────────────────────────────────────────
class TugasCard extends StatelessWidget {
  final MateriItem item;
  final bool isDone;
  final ValueChanged<MateriItem> onEdit;
  final ValueChanged<String> onHapus;
  final void Function(String id, StatusMateri status) onStatusUpdate;
  const TugasCard({super.key, required this.item, required this.isDone, required this.onEdit, required this.onHapus, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    final tColor = tipeColor(item.tipe);
    final mColor = mapelColor(item.mapel);

    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDone
                ? AppColors.teal.withOpacity(0.2)
                : item.isDue
                    ? AppColors.red.withOpacity(0.2)
                    : AppColors.border.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header Strip ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: tColor.withOpacity(0.07),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: tColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(tipeIcon(item.tipe), color: tColor, size: 15),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tipeLabel(item.tipe),
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: tColor),
                  ),
                  const Spacer(),
                  // Badge status
                  if (isDone)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded, size: 10, color: AppColors.teal),
                        const SizedBox(width: 3),
                        Text('Selesai', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.teal)),
                      ]),
                    )
                  else if (item.isDue)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(children: [
                        const Icon(Icons.timer_rounded, size: 10, color: AppColors.red),
                        const SizedBox(width: 3),
                         Text("Tenggat ${item.deadline ?? ""}", style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.red)),
                      ]),
                    ),
                  const SizedBox(width: 4),
                  // ── Menu Edit / Hapus ──
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') onEdit(item);
                      if (val == 'hapus') onHapus(item.id);
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    icon: Icon(Icons.more_vert_rounded, size: 16, color: AppColors.subtle.withOpacity(0.6)),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          const Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Edit', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                      PopupMenuItem(
                        value: 'hapus',
                        child: Row(children: [
                          const Icon(Icons.delete_rounded, size: 16, color: AppColors.red),
                          const SizedBox(width: 8),
                          Text('Hapus', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.red)),
                        ]),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Body ──
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: mColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(mapelIcon(item.mapel), color: mColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.judul,
                          style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: isDone ? AppColors.subtle : AppColors.onSurface,
                            decoration: isDone ? TextDecoration.lineThrough : null,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mapelLabel(item.mapel),
                          style: GoogleFonts.inter(fontSize: 11, color: mColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            EMetaChip(icon: Icons.person_rounded, label: item.guru, color: AppColors.subtle),
                            const Spacer(),
                            // Tombol aksi
                            if (!isDone)
                              GestureDetector(
                                onTap: () {
                                  if (item.tipe == TipeKonten.kuis) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => KuisPage(item: item)));
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => KumpulTugasPage(item: item)));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: tColor, borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    item.tipe == TipeKonten.kuis ? 'Mulai' : 'Kumpul',
                                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                ),
                              )
                            else if (item.nilaiKuis > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.teal.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  const Icon(Icons.star_rounded, size: 12, color: AppColors.teal),
                                  const SizedBox(width: 4),
                                  Text('Nilai: ${item.nilaiKuis}',
                                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.teal)),
                                ]),
                              )
                            else
                              const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 22),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TugasDetailSheet(item: item, isDone: isDone, onEdit: onEdit, onHapus: onHapus, onStatusUpdate: onStatusUpdate),
    );
  }
}

// ─── Tugas Detail Sheet ────────────────────────────────────────────────────────
class _TugasDetailSheet extends StatelessWidget {
  final MateriItem item;
  final bool isDone;
  final ValueChanged<MateriItem> onEdit;
  final ValueChanged<String> onHapus;
  final void Function(String id, StatusMateri status) onStatusUpdate;
  const _TugasDetailSheet({required this.item, required this.isDone, required this.onEdit, required this.onHapus, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    final tColor = tipeColor(item.tipe);
    final mColor = mapelColor(item.mapel);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      snap: true,
      snapSizes: const [0.4, 0.55, 0.9],
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: controller,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Center(child: Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 20),

              // Badge tipe & mapel
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: tColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(tipeIcon(item.tipe), size: 13, color: tColor),
                    const SizedBox(width: 5),
                    Text(tipeLabel(item.tipe), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: tColor)),
                  ]),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: mColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Icon(mapelIcon(item.mapel), size: 13, color: mColor),
                    const SizedBox(width: 5),
                    Text(mapelLabel(item.mapel), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: mColor)),
                  ]),
                ),
                const Spacer(),
                // Edit & Hapus di detail sheet
                IconButton(
                  onPressed: () { Navigator.pop(context); onEdit(item); },
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () { Navigator.pop(context); onHapus(item.id); },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.red),
                  tooltip: 'Hapus',
                ),
              ]),
              const SizedBox(height: 12),

              Text(item.judul, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.onSurface, height: 1.3)),
              const SizedBox(height: 6),
              Text(item.guru, style: GoogleFonts.inter(fontSize: 12, color: AppColors.subtle)),
              const SizedBox(height: 16),

              EDetailRow(icon: Icons.calendar_today_rounded, label: 'Diunggah', value: item.tanggalUpload),
              if (item.deadline != null)
                EDetailRow(icon: Icons.timer_rounded, label: 'Tenggat', value: _formatDeadline(item.deadline)),
              if (item.nilaiKuis > 0)
                EDetailRow(icon: Icons.star_rounded, label: 'Nilai', value: '${item.nilaiKuis} / 100'),

              const SizedBox(height: 16),
              Text('Deskripsi', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.subtle, letterSpacing: 0.3)),
              const SizedBox(height: 6),
              Text(item.deskripsi, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface, height: 1.6)),
              const SizedBox(height: 24),

              if (isDone) ...[
                // Sudah selesai — tampilkan badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.task_alt_rounded, color: AppColors.teal, size: 18),
                      const SizedBox(width: 8),
                      Text('Sudah Dikerjakan',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w700,
                              color: AppColors.teal)),
                    ],
                  ),
                ),
              ] else ...[
                // Belum selesai — tombol kerjakan (otomatis selesai)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onStatusUpdate(item.id, StatusMateri.selesai);
                      Navigator.pop(context);
                      if (item.tipe == TipeKonten.kuis) {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => KuisPage(item: item)));
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => KumpulTugasPage(item: item)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tColor, elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(item.tipe == TipeKonten.kuis ? Icons.quiz_rounded : Icons.upload_file_rounded,
                        size: 18, color: Colors.white),
                    label: Text(
                      item.tipe == TipeKonten.kuis ? 'Mulai Kuis' : 'Kumpulkan Tugas',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Form Sheet: Tambah Kuis / Tugas ─────────────────────────────────────────
class TugasKuisFormSheet extends StatefulWidget {
  final ValueChanged<MateriItem> onSave;
  final MateriItem? materi; // null = tambah baru, non-null = edit
  const TugasKuisFormSheet({super.key, required this.onSave, this.materi});

  @override
  State<TugasKuisFormSheet> createState() => _TugasKuisFormSheetState();
}

class _TugasKuisFormSheetState extends State<TugasKuisFormSheet> {
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  MataPelajaran _mapel = MataPelajaran.matematika;
  TipeKonten _tipe = TipeKonten.tugas;
  bool _isSaving = false;
  String _guru = 'Pak Budi Santoso';
  List<SoalKuis> _parsedSoal = [];
  String? _namaFileKuis;
  bool _isParsingFile = false;
  String _parseError = '';
  // Durasi kuis — pilihan dropdown
  String _selectedDurasi = '30 menit';
  final List<String> _durasiOptions = ['10 menit','15 menit','20 menit','30 menit','45 menit','60 menit','90 menit','120 menit'];
  // Tenggat — dipilih dari date picker
  DateTime? _selectedDeadline;

  @override
  void initState() {
    super.initState();
    final m = widget.materi;
    if (m != null) {
      _judulCtrl.text = m.judul;
      _deskripsiCtrl.text = m.deskripsi == 'Tidak ada deskripsi' ? '' : m.deskripsi;
      // Pulihkan durasi
      if (m.durasi != '-' && m.durasi != '—' && _durasiOptions.contains(m.durasi)) {
        _selectedDurasi = m.durasi;
      }
      // Pulihkan deadline
      if (m.deadline != null && m.deadline!.isNotEmpty) {
        try { _selectedDeadline = DateTime.parse(m.deadline!); } catch (_) {}
      }
      _mapel = m.mapel;
      _tipe = m.tipe;
      _guru = m.guru;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  // ── Upload & Parse CSV / Excel Soal ──────────────────────────────────────
  Future<void> _pickAndParseFile() async {
    setState(() { _isParsingFile = true; _parseError = ''; });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _isParsingFile = false);
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        setState(() { _isParsingFile = false; _parseError = 'Tidak dapat membaca isi file'; });
        return;
      }

      final ext = file.extension?.toLowerCase() ?? '';
      List<SoalKuis> hasil;

      if (ext == 'xlsx' || ext == 'xls') {
        hasil = _parseExcel(bytes);
      } else {
        hasil = _parseCsv(bytes);
      }

      if (hasil.isEmpty) {
        setState(() { _isParsingFile = false; _parseError = 'Tidak ada soal valid. Periksa format file.'; });
        return;
      }
      setState(() { _isParsingFile = false; _parsedSoal = hasil; _namaFileKuis = file.name; _parseError = ''; });
    } catch (e) {
      setState(() { _isParsingFile = false; _parseError = 'Gagal membaca file: $e'; });
    }
  }

  // ── Parse CSV bytes ──
  List<SoalKuis> _parseCsv(List<int> bytes) {
    final raw = utf8.decode(bytes, allowMalformed: true);
    final lines = raw.split('\n').map((l) => l.trim().replaceAll('\r', '')).where((l) => l.isNotEmpty).toList();
    if (lines.length < 2) return [];
    return _parseSoalRows(lines.sublist(1).map(_parseCsvLine).toList());
  }

  // ── Parse Excel bytes ──
  List<SoalKuis> _parseExcel(List<int> bytes) {
    final workbook = xl.Excel.decodeBytes(bytes);
    final sheet = workbook.sheets.values.first;
    final rows = sheet.rows.skip(1).toList(); // skip header row
    return _parseSoalRows(rows.map((row) {
      return row.map((cell) => cell?.value?.toString().trim() ?? '').toList();
    }).toList());
  }

  // ── Parsing baris soal (shared logic CSV & Excel) ──
  List<SoalKuis> _parseSoalRows(List<List<String>> rows) {
    final List<SoalKuis> hasil = [];
    for (final cols in rows) {
      if (cols.length < 5) continue;
      final pertanyaan = cols[0].trim();
      if (pertanyaan.isEmpty) continue;

      final bool punya4Pilihan = cols.length >= 6 && cols[4].trim().isNotEmpty
          && !['A','B','C','D'].contains(cols[4].trim().toUpperCase());

      final List<String> pilihan;
      final String jawabanStr;
      if (punya4Pilihan) {
        pilihan = [cols[1].trim(), cols[2].trim(), cols[3].trim(), cols[4].trim()]
            .where((p) => p.isNotEmpty).toList();
        jawabanStr = cols.length > 5 ? cols[5].trim().toUpperCase() : 'A';
      } else {
        pilihan = [cols[1].trim(), cols[2].trim(), cols[3].trim()]
            .where((p) => p.isNotEmpty).toList();
        jawabanStr = cols.length > 4 ? cols[4].trim().toUpperCase() : 'A';
      }

      if (pilihan.length < 2) continue;
      final benarIdx = jawabanStr == 'A' ? 0 : jawabanStr == 'B' ? 1
          : jawabanStr == 'C' ? 2 : jawabanStr == 'D' ? 3 : 0;
      final safeIdx = benarIdx.clamp(0, pilihan.length - 1);

      hasil.add(SoalKuis(pertanyaan: pertanyaan, pilihan: pilihan, jawabanBenar: safeIdx));
    }
    return hasil;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final buf = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final ch = line[i];
      if (ch == '"') { inQuotes = !inQuotes; }
      else if (ch == ',' && !inQuotes) { result.add(buf.toString()); buf.clear(); }
      else { buf.write(ch); }
    }
    result.add(buf.toString());
    return result;
  }

  void _simpan() {
    if (_judulCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Judul tidak boleh kosong',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      final isEdit = widget.materi != null;
      final item = MateriItem(
        id: widget.materi?.id ?? 'TK_TEMP',
        judul: _judulCtrl.text.trim(),
        deskripsi: _deskripsiCtrl.text.trim().isEmpty
            ? 'Tidak ada deskripsi'
            : _deskripsiCtrl.text.trim(),
        mapel: _mapel,
        tipe: _tipe,
        status: StatusMateri.belumDibaca,
        durasi: (_tipe == TipeKonten.kuis) ? _selectedDurasi : '-',
        tanggalUpload: '${DateTime.now().day} Apr ${DateTime.now().year}',
        guru: _guru,
        isDue: _selectedDeadline != null,
        deadline: _selectedDeadline?.toIso8601String(),
      );

      // Simpan soal ke database sebelum onSave dipanggil
      if (_tipe == TipeKonten.kuis && _parsedSoal.isNotEmpty) {
        if (isEdit) {
          // Edit: langsung update soal dengan ID yang sudah ada
          soalDatabase[item.id] = _parsedSoal;
        } else {
          // Tambah baru: simpan ke 'PENDING', lalu _tambahMateri akan pindahkan ke ID baru
          soalDatabase['PENDING'] = _parsedSoal;
        }
      }

      widget.onSave(item);
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final tColor = _tipe == TipeKonten.kuis ? AppColors.purple : AppColors.orange;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: tColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    _tipe == TipeKonten.kuis ? Icons.quiz_rounded : Icons.assignment_rounded,
                    color: tColor, size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Tambah ${_tipe == TipeKonten.kuis ? "Kuis" : "Tugas"}',
                  style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Pilih Tipe ──
            Text('TIPE', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800,
                color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Row(
              children: [TipeKonten.tugas, TipeKonten.kuis].map((t) {
                final selected = _tipe == t;
                final color = tipeColor(t);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _tipe = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: selected ? color.withOpacity(0.12) : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? color : AppColors.border.withOpacity(0.4),
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(tipeIcon(t), color: selected ? color : AppColors.subtle, size: 16),
                          const SizedBox(width: 6),
                          Text(tipeLabel(t),
                              style: GoogleFonts.inter(
                                fontSize: 12, fontWeight: FontWeight.w700,
                                color: selected ? color : AppColors.subtle,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Text('JUDUL', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800,
                color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.4)),
              ),
              child: TextField(
                controller: _judulCtrl,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: _tipe == TipeKonten.kuis
                      ? 'Contoh: Kuis Bab 3 – Fotosintesis'
                      : 'Contoh: Tugas Peta Kepadatan Penduduk',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // ── Upload Soal (khusus Kuis) ──
            if (_tipe == TipeKonten.kuis) ...[
              Text('UPLOAD SOAL KUIS', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
              const SizedBox(height: 4),
              Text('Format: Pertanyaan, PilA, PilB, PilC, [PilD], Jawaban(A/B/C/D)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.subtle)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isParsingFile ? null : _pickAndParseFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _namaFileKuis != null ? AppColors.purple.withOpacity(0.06) : AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _namaFileKuis != null ? AppColors.purple.withOpacity(0.4) : AppColors.border.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: _isParsingFile
                      ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.purple)),
                          const SizedBox(width: 10),
                          Text('Membaca soal...', style: GoogleFonts.inter(fontSize: 13, color: AppColors.purple, fontWeight: FontWeight.w600)),
                        ])
                      : _namaFileKuis != null
                          ? Row(children: [
                              Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.table_chart_rounded, color: AppColors.purple, size: 22)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(_namaFileKuis!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(' soal terdeteksi · Ketuk untuk ganti', style: GoogleFonts.inter(fontSize: 10, color: AppColors.subtle)),
                              ])),
                              const Icon(Icons.check_circle_rounded, color: AppColors.purple, size: 20),
                            ])
                          : Column(children: [
                              const Icon(Icons.upload_file_rounded, color: AppColors.purple, size: 32),
                              const SizedBox(height: 8),
                              Text('Ketuk untuk upload file soal', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.purple)),
                              const SizedBox(height: 2),
                              Text('Format: .CSV, .XLSX (Excel)', style: GoogleFonts.inter(fontSize: 10, color: AppColors.subtle)),
                            ]),
                ),
              ),
              if (_parseError.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.red.withOpacity(0.07), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.red.withOpacity(0.2))),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.red),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_parseError, style: GoogleFonts.inter(fontSize: 11, color: AppColors.red, fontWeight: FontWeight.w600))),
                  ]),
                ),
              ],
              if (_parsedSoal.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.purple.withOpacity(0.2))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.quiz_rounded, size: 14, color: AppColors.purple),
                      const SizedBox(width: 6),
                      Text(' Soal Terdeteksi', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.purple)),
                    ]),
                    const SizedBox(height: 10),
                    ...List.generate(_parsedSoal.length > 5 ? 5 : _parsedSoal.length, (i) {
                      final s = _parsedSoal[i];
                      final huruf = ['A','B','C','D'][s.jawabanBenar];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(width: 20, height: 20, decoration: BoxDecoration(color: AppColors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                            child: Center(child: Text('', style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.purple)))),
                          const SizedBox(width: 8),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(s.pertanyaan, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                              child: Text('Benar: . ', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.teal), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ])),
                        ]),
                      );
                    }),
                    if (_parsedSoal.length > 5)
                      Text('... dan  soal lainnya', style: GoogleFonts.inter(fontSize: 11, color: AppColors.subtle, fontStyle: FontStyle.italic)),
                  ]),
                ),
              ],
            ],
            const SizedBox(height: 18),

            // ── Deskripsi ──
            Text('DESKRIPSI (OPSIONAL)', style: GoogleFonts.manrope(fontSize: 11,
                fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.4)),
              ),
              child: TextField(
                controller: _deskripsiCtrl,
                maxLines: 3,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Tulis instruksi atau keterangan...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // -- GURU --
            Text('GURU', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _guru,
                  isExpanded: true,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.subtle),
                  onChanged: (v) { if (v != null) setState(() => _guru = v); },
                  items: [
                    'Pak Budi Santoso', 'Bu Siti Rahayu', 'Pak Joko Widodo',
                    'Bu Ani Suryani', 'Pak Hendra Wijaya', 'Bu Dewi Kartika',
                  ].map((g) => DropdownMenuItem(value: g, child: Row(children: [
                    const Icon(Icons.person_rounded, size: 15, color: AppColors.subtle),
                    const SizedBox(width: 8),
                    Text(g),
                  ]))).toList(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // ── Mata Pelajaran ──
            Text('MATA PELAJARAN', style: GoogleFonts.manrope(fontSize: 11,
                fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border.withOpacity(0.4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<MataPelajaran>(
                  value: _mapel,
                  isExpanded: true,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.subtle),
                  onChanged: (v) { if (v != null) setState(() => _mapel = v); },
                  items: MataPelajaran.values.map((m) => DropdownMenuItem(
                    value: m,
                    child: Row(
                      children: [
                        Icon(mapelIcon(m), color: mapelColor(m), size: 15),
                        const SizedBox(width: 8),
                        Text(mapelLabel(m)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 14),


            // ── Durasi (Kuis) + Tenggat ──
            if (_tipe == TipeKonten.kuis) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DURASI', style: GoogleFonts.manrope(fontSize: 11,
                            fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border.withOpacity(0.4)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedDurasi,
                              isExpanded: true,
                              dropdownColor: AppColors.card,
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.subtle, size: 20),
                              onChanged: (v) => setState(() => _selectedDurasi = v!),
                              items: _durasiOptions.map((d) => DropdownMenuItem(
                                value: d,
                                child: Text(d),
                              )).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TENGGAT', style: GoogleFonts.manrope(fontSize: 11,
                            fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _safeInitialDate(_selectedDeadline),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: AppColors.primary,
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black87,
                                ),
                              ), child: child!),
                            );
                            if (picked != null) setState(() => _selectedDeadline = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _selectedDeadline != null
                                  ? AppColors.primary.withOpacity(0.5)
                                  : AppColors.border.withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded,
                                    size: 14,
                                    color: _selectedDeadline != null ? AppColors.primary : AppColors.subtle),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedDeadline != null
                                        ? '${_selectedDeadline!.day} ${['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'][_selectedDeadline!.month-1]} ${_selectedDeadline!.year}'
                                        : 'Pilih tanggal',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: _selectedDeadline != null ? AppColors.onSurface : Colors.grey.shade400,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
            ] else ...[
              // Tugas: hanya TENGGAT (full width)
              Text('TENGGAT', style: GoogleFonts.manrope(fontSize: 11,
                  fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _safeInitialDate(_selectedDeadline),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ), child: child!),
                  );
                  if (picked != null) setState(() => _selectedDeadline = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedDeadline != null
                        ? AppColors.primary.withOpacity(0.5)
                        : AppColors.border.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 16,
                          color: _selectedDeadline != null ? AppColors.primary : AppColors.subtle),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDeadline != null
                            ? '${_selectedDeadline!.day} ${['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'][_selectedDeadline!.month-1]} ${_selectedDeadline!.year}'
                            : 'Pilih tanggal tenggat',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _selectedDeadline != null ? AppColors.onSurface : Colors.grey.shade400,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDeadline != null)
                        GestureDetector(
                          onTap: () => setState(() => _selectedDeadline = null),
                          child: const Icon(Icons.close_rounded, size: 16, color: AppColors.subtle),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 26),

            // ── Simpan ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tColor,
                  disabledBackgroundColor: tColor.withOpacity(0.5),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan ${_tipe == TipeKonten.kuis ? "Kuis" : "Tugas"}',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Model Soal ───────────────────────────────────────────────────────────────
class SoalKuis {
  final String pertanyaan;
  final List<String> pilihan;
  final int jawabanBenar;

  const SoalKuis({
    required this.pertanyaan,
    required this.pilihan,
    required this.jawabanBenar,
  });
}

// ─── Dummy Soal per Kuis ──────────────────────────────────────────────────────
Map<String, List<SoalKuis>> soalDatabase = {
  'M003': [
    SoalKuis(
      pertanyaan: 'Proses fotosintesis pada tumbuhan menghasilkan ...',
      pilihan: ['CO₂ dan H₂O', 'O₂ dan glukosa', 'O₂ dan CO₂', 'Glukosa dan H₂O'],
      jawabanBenar: 1,
    ),
    SoalKuis(
      pertanyaan: 'Organel sel yang menjadi tempat berlangsungnya fotosintesis adalah ...',
      pilihan: ['Mitokondria', 'Ribosom', 'Kloroplas', 'Nukleus'],
      jawabanBenar: 2,
    ),
    SoalKuis(
      pertanyaan: 'Reaksi gelap pada fotosintesis disebut juga siklus ...',
      pilihan: ['Krebs', 'Calvin', 'Nitrogen', 'Embden'],
      jawabanBenar: 1,
    ),
    SoalKuis(
      pertanyaan: 'Respirasi aerob menghasilkan energi berupa ...',
      pilihan: ['ADP', 'ATP', 'NADH', 'FADH'],
      jawabanBenar: 1,
    ),
    SoalKuis(
      pertanyaan: 'Bahan baku utama proses fotosintesis adalah ...',
      pilihan: ['O₂ dan glukosa', 'CO₂ dan H₂O', 'H₂O dan O₂', 'Glukosa dan CO₂'],
      jawabanBenar: 1,
    ),
    SoalKuis(
      pertanyaan: 'Tempat berlangsungnya respirasi seluler adalah ...',
      pilihan: ['Kloroplas', 'Vakuola', 'Mitokondria', 'Badan Golgi'],
      jawabanBenar: 2,
    ),
    SoalKuis(
      pertanyaan: 'Pigmen hijau pada daun yang menyerap cahaya matahari disebut ...',
      pilihan: ['Xantofil', 'Karoten', 'Klorofil', 'Antosianin'],
      jawabanBenar: 2,
    ),
    SoalKuis(
      pertanyaan: 'Respirasi anaerob pada ragi menghasilkan ...',
      pilihan: ['CO₂ dan asam laktat', 'Etanol dan CO₂', 'ATP dan H₂O', 'Glukosa dan O₂'],
      jawabanBenar: 1,
    ),
    SoalKuis(
      pertanyaan: 'Persamaan reaksi fotosintesis yang benar adalah ...',
      pilihan: [
        '6CO₂ + 6H₂O → C₆H₁₂O₆ + 6O₂',
        'C₆H₁₂O₆ + 6O₂ → 6CO₂ + 6H₂O',
        '6O₂ + 6H₂O → C₆H₁₂O₆ + 6CO₂',
        'C₆H₁₂O₆ → 6CO₂ + 6H₂O + ATP',
      ],
      jawabanBenar: 0,
    ),
    SoalKuis(
      pertanyaan: 'Faktor yang TIDAK mempengaruhi laju fotosintesis adalah ...',
      pilihan: ['Intensitas cahaya', 'Kadar CO₂', 'Warna bunga', 'Suhu'],
      jawabanBenar: 2,
    ),
  ],
};

List<SoalKuis> getSoal(String id) {
  return soalDatabase[id] ?? [
    SoalKuis(
      pertanyaan: 'Apa nama dokumen dasar negara Indonesia?',
      pilihan: ['KUHP', 'UUD 1945', 'Tap MPR', 'Perppu'],
      jawabanBenar: 1,
    ),
    SoalKuis(
      pertanyaan: 'Berapa jumlah provinsi di Indonesia saat ini?',
      pilihan: ['33', '34', '37', '38'],
      jawabanBenar: 3,
    ),
    SoalKuis(
      pertanyaan: 'Siapa proklamator kemerdekaan Indonesia?',
      pilihan: ['Soeharto & Try Sutrisno', 'Soekarno & Hatta', 'Sjahrir & Hatta', 'Soekarno & Sjahrir'],
      jawabanBenar: 1,
    ),
    SoalKuis(
      pertanyaan: 'Pancasila terdiri dari berapa sila?',
      pilihan: ['3', '4', '5', '6'],
      jawabanBenar: 2,
    ),
    SoalKuis(
      pertanyaan: 'Bahasa resmi negara Indonesia adalah ...',
      pilihan: ['Bahasa Jawa', 'Bahasa Melayu', 'Bahasa Indonesia', 'Bahasa Sunda'],
      jawabanBenar: 2,
    ),
  ];
}

// ─── Halaman Kuis ─────────────────────────────────────────────────────────────
class KuisPage extends StatefulWidget {
  final MateriItem item;
  const KuisPage({super.key, required this.item});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> with TickerProviderStateMixin {
  late final List<SoalKuis> _soalList;
  late final PageController _pageController;
  late AnimationController _timerController;
  AppLifecycleListener? _lifecycleListener;

  int _currentIndex = 0;
  final Map<int, int> _jawaban = {};
  bool _sudahSelesai = false;
  int _sisaDetik = 30;
  Timer? _timer;

  int _pelanggaranBackground = 0;
  int _pelanggaranExit = 0;
  static const int _maxPelanggaran = 3;
  bool _sedangTampilPeringatan = false;

  @override
  void initState() {
    super.initState();
    _soalList = getSoal(widget.item.id);
    _pageController = PageController();
    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _mulaiTimer();
    _lockScreen();

    _lifecycleListener = AppLifecycleListener(
      onResume: _onAppResume,
      onHide: _onAppBackground,
      onPause: _onAppBackground,
    );
  }

  static const _kuisChannel = MethodChannel('id.sinan.SIMANIS/kuis_lock');

  Future<void> _lockScreen() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    try {
      await _kuisChannel.invokeMethod('startScreenPin');
    } catch (_) {}
  }

  Future<void> _unlockScreen() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([]);
    try {
      await _kuisChannel.invokeMethod('stopScreenPin');
    } catch (_) {}
  }

  void _onAppResume() {
    if (_sudahSelesai || _sedangTampilPeringatan) return;
    if (_pelanggaranBackground == 0) return;
    _tampilkanPeringatan('background');
  }

  void _onAppBackground() {
    if (_sudahSelesai || _sedangTampilPeringatan) return;
    _pelanggaranBackground++;
    _timer?.cancel();
  }

  void _onCobaKeluar() {
    if (_sudahSelesai) return;
    _pelanggaranExit++;
    _timer?.cancel();
    _tampilkanPeringatan('exit');
  }

  int get _totalPelanggaran => _pelanggaranBackground + _pelanggaranExit;

  void _tampilkanPeringatan(String jenis) {
    if (_sedangTampilPeringatan) return;
    _sedangTampilPeringatan = true;

    final autoSubmit = jenis == 'background' || _pelanggaranExit >= _maxPelanggaran;

    final String judulText = autoSubmit
        ? '🚫 Kuis Dihentikan Otomatis!'
        : '⚠️ Tidak Boleh Keluar Saat Kuis!';

    final String isiText = autoSubmit
        ? (jenis == 'background'
            ? 'Kamu terdeteksi minimize atau berpindah aplikasi saat kuis berlangsung.\n\nKuis dikumpulkan otomatis dengan jawaban yang sudah diisi.'
            : 'Kamu telah mencoba keluar sebanyak $_pelanggaranExit kali.\n\nKuis dikumpulkan otomatis dengan jawaban yang sudah diisi.')
        : 'Kamu tidak diizinkan keluar dari halaman kuis yang sedang berlangsung!\n\nIni peringatan terakhir. Jika kamu mencoba keluar lagi, kuis akan dikumpulkan otomatis.';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.card,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  autoSubmit ? Icons.block_rounded : Icons.warning_amber_rounded,
                  color: AppColors.red, size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  judulText,
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800, fontSize: 14,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isiText,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.subtle, height: 1.55),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.red.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      autoSubmit ? Icons.block_rounded : Icons.lock_rounded,
                      color: AppColors.red, size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        autoSubmit
                            ? 'Jawaban yang sudah diisi akan tetap dihitung.'
                            : 'Selama kuis berlangsung, kamu tidak bisa minimize, switch app, atau keluar.',
                        style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.red, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _sedangTampilPeringatan = false;
                  if (autoSubmit) {
                    _timer?.cancel();
                    _unlockScreen();
                    setState(() => _sudahSelesai = true);
                  } else {
                    _lockScreen();
                    _mulaiTimer();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: autoSubmit ? AppColors.red : AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: Text(
                  autoSubmit ? 'Lihat Hasil Kuis' : 'Kembali ke Kuis',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => _sedangTampilPeringatan = false);
  }

  void _mulaiTimer() {
    _sisaDetik = 30;
    _timerController.forward(from: 0);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _sisaDetik--);
      if (_sisaDetik <= 0) {
        t.cancel();
        _jawabOtomatis();
      }
    });
  }

  void _jawabOtomatis() {
    if (!_jawaban.containsKey(_currentIndex)) {
      _jawaban[_currentIndex] = -1;
    }
    _lanjut();
  }

  void _pilih(int idx) {
    setState(() {
      _jawaban[_currentIndex] = idx;
    });
  }

  void _kembali() {
    if (_currentIndex <= 0) return;
    setState(() => _currentIndex--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _timer?.cancel();
    _mulaiTimer();
  }

  void _lanjut() {
    if (_currentIndex < _soalList.length - 1) {
      setState(() => _currentIndex++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _timer?.cancel();
      _mulaiTimer();
    } else {
      _timer?.cancel();
      setState(() => _sudahSelesai = true);
    }
  }

  int get _nilaiAkhir {
    int benar = 0;
    for (int i = 0; i < _soalList.length; i++) {
      if (_jawaban[i] == _soalList[i].jawabanBenar) benar++;
    }
    return ((benar / _soalList.length) * 100).round();
  }

  int get _jumlahBenar =>
      List.generate(_soalList.length, (i) => i)
          .where((i) => _jawaban[i] == _soalList[i].jawabanBenar)
          .length;

  @override
  void dispose() {
    _timer?.cancel();
    _timerController.dispose();
    _pageController.dispose();
    _lifecycleListener?.dispose();
    _unlockScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sudahSelesai) {
      return HasilKuisPage(
        item: widget.item,
        soalList: _soalList,
        jawaban: _jawaban,
        nilai: _nilaiAkhir,
        jumlahBenar: _jumlahBenar,
      );
    }

    final soal = _soalList[_currentIndex];
    final progres = (_currentIndex + 1) / _soalList.length;

    return WillPopScope(
      onWillPop: () async {
        _onCobaKeluar();
        return false;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // ── Header ──
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _onCobaKeluar(),
                            child: Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.close_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.item.judul,
                              style: GoogleFonts.manrope(
                                fontSize: 14, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _TimerWidget(sisaDetik: _sisaDetik),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            'Soal ${_currentIndex + 1} / ${_soalList.length}',
                            style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progres * 100).round()}%',
                            style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: Colors.greenAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progres,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Soal & Pilihan ──
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _soalList.length,
                    itemBuilder: (_, i) => _SoalView(
                      soal: _soalList[i],
                      nomorSoal: i + 1,
                      jawabanDipilih: _jawaban[i],
                      onPilih: i == _currentIndex ? _pilih : null,
                    ),
                  ),
                ),

                // ── Footer ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Row(
                    children: [
                      if (_currentIndex > 0)
                        GestureDetector(
                          onTap: _kembali,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_back_rounded,
                                    color: AppColors.subtle, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Kembali',
                                  style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: AppColors.subtle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Spacer(),
                      // Dot indikator soal
                      Wrap(
                        spacing: 5,
                        children: List.generate(_soalList.length, (i) {
                          Color dotColor;
                          if (i == _currentIndex) {
                            dotColor = AppColors.purple;
                          } else if (_jawaban.containsKey(i)) {
                            dotColor = AppColors.primary.withOpacity(0.5);
                          } else {
                            dotColor = AppColors.border;
                          }
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: i == _currentIndex ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: dotColor,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _jawaban.containsKey(_currentIndex) ? _lanjut : null,
                        child: AnimatedOpacity(
                          opacity: _jawaban.containsKey(_currentIndex) ? 1.0 : 0.45,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: _jawaban.containsKey(_currentIndex)
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _currentIndex < _soalList.length - 1
                                      ? 'Lanjut' : 'Selesai',
                                  style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  _currentIndex < _soalList.length - 1
                                      ? Icons.arrow_forward_rounded
                                      : Icons.check_rounded,
                                  color: Colors.white, size: 16,
                                ),
                              ],
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
    );
  }
}

// ─── Widget Soal ──────────────────────────────────────────────────────────────
class _SoalView extends StatelessWidget {
  final SoalKuis soal;
  final int nomorSoal;
  final int? jawabanDipilih;
  final ValueChanged<int>? onPilih;

  const _SoalView({
    required this.soal,
    required this.nomorSoal,
    this.jawabanDipilih,
    this.onPilih,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10, offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soal $nomorSoal',
                  style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                soal.pertanyaan,
                style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w600,
                  color: AppColors.onSurface, height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(soal.pilihan.length, (i) {
          if (soal.pilihan[i].isEmpty) return const SizedBox.shrink();
          final huruf = ['A', 'B', 'C', 'D'][i];
          final dipilih = jawabanDipilih == i;

          Color bgColor = AppColors.card;
          Color borderColor = AppColors.border.withOpacity(0.3);
          Color hurufBg = AppColors.surface;
          Color hurufColor = AppColors.subtle;

          if (dipilih) {
            bgColor = AppColors.purple.withOpacity(0.08);
            borderColor = AppColors.purple.withOpacity(0.5);
            hurufBg = AppColors.purple;
            hurufColor = Colors.white;
          }

          return GestureDetector(
            onTap: onPilih == null ? null : () => onPilih!.call(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6, offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: hurufBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        huruf,
                        style: GoogleFonts.manrope(
                          fontSize: 13, fontWeight: FontWeight.w800,
                          color: hurufColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      soal.pilihan[i],
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  if (dipilih)
                    const Icon(Icons.check_rounded, color: AppColors.purple, size: 20),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ─── Widget Timer ─────────────────────────────────────────────────────────────
class _TimerWidget extends StatelessWidget {
  final int sisaDetik;
  const _TimerWidget({required this.sisaDetik});

  @override
  Widget build(BuildContext context) {
    final isUrgent = sisaDetik <= 10;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.red.withOpacity(0.2)
            : Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUrgent
              ? AppColors.red.withOpacity(0.5)
              : Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 14,
              color: isUrgent ? AppColors.red : Colors.white70),
          const SizedBox(width: 5),
          Text(
            '${sisaDetik}s',
            style: GoogleFonts.manrope(
              fontSize: 13, fontWeight: FontWeight.w800,
              color: isUrgent ? AppColors.red : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Halaman Hasil Kuis ───────────────────────────────────────────────────────
class HasilKuisPage extends StatelessWidget {
  final MateriItem item;
  final List<SoalKuis> soalList;
  final Map<int, int> jawaban;
  final int nilai;
  final int jumlahBenar;

  const HasilKuisPage({
    super.key,
    required this.item,
    required this.soalList,
    required this.jawaban,
    required this.nilai,
    required this.jumlahBenar,
  });

  Color get _nilaiColor {
    if (nilai >= 80) return AppColors.teal;
    if (nilai >= 60) return AppColors.amber;
    return AppColors.red;
  }

  String get _predikat {
    if (nilai >= 90) return 'Luar Biasa! 🎉';
    if (nilai >= 80) return 'Sangat Bagus! 👏';
    if (nilai >= 70) return 'Bagus! 👍';
    if (nilai >= 60) return 'Cukup Baik';
    return 'Perlu Belajar Lagi';
  }

  @override
  Widget build(BuildContext context) {
    final salah = soalList.length - jumlahBenar;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              // ── Header hasil ──
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: _nilaiColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: _nilaiColor, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          '$nilai',
                          style: GoogleFonts.manrope(
                            fontSize: 32, fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _predikat,
                      style: GoogleFonts.manrope(
                        fontSize: 20, fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.judul,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(icon: Icons.check_circle_rounded,
                            label: 'Benar', value: '$jumlahBenar', color: AppColors.teal),
                        const SizedBox(width: 12),
                        _StatBadge(icon: Icons.cancel_rounded,
                            label: 'Salah', value: '$salah', color: AppColors.red),
                        const SizedBox(width: 12),
                        _StatBadge(icon: Icons.quiz_rounded,
                            label: 'Total', value: '${soalList.length}', color: AppColors.purple),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Pembahasan ──
              Text(
                'PEMBAHASAN JAWABAN',
                style: GoogleFonts.manrope(
                  fontSize: 13, fontWeight: FontWeight.w800,
                  color: AppColors.onSurface, letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              ...List.generate(soalList.length, (i) {
                final s = soalList[i];
                final userJawab = jawaban[i] ?? -1;
                final benar = userJawab == s.jawabanBenar;
                final color = benar ? AppColors.teal : AppColors.red;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.25), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8, offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text('Soal ${i + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 10, fontWeight: FontWeight.w700,
                                  color: color,
                                )),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            benar ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: color, size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(benar ? 'Benar' : 'Salah',
                              style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: color,
                              )),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(s.pertanyaan,
                          style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600,
                            color: AppColors.onSurface, height: 1.5,
                          )),
                      const SizedBox(height: 10),
                      if (!benar && userJawab >= 0) ...[
                        _JawabanRow(
                          huruf: ['A','B','C','D'][userJawab],
                          teks: s.pilihan[userJawab],
                          label: 'Jawabanmu',
                          color: AppColors.red,
                        ),
                        const SizedBox(height: 6),
                      ],
                      _JawabanRow(
                        huruf: ['A','B','C','D'][s.jawabanBenar],
                        teks: s.pilihan[s.jawabanBenar],
                        label: 'Jawaban Benar',
                        color: AppColors.teal,
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 18),
                  label: Text('Kembali ke Tugas & Kuis',
                      style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Kumpul Tugas Page ────────────────────────────────────────────────────────
class KumpulTugasPage extends StatefulWidget {
  final MateriItem item;
  const KumpulTugasPage({super.key, required this.item});

  @override
  State<KumpulTugasPage> createState() => _KumpulTugasPageState();
}

class _KumpulTugasPageState extends State<KumpulTugasPage> {
  final _catatanController = TextEditingController();
  String? _namaFile;
  String? _filePath;
  int? _fileSize;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _pilihFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      withData: false,
      withReadStream: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      if (file.size > 10 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ukuran file melebihi 10 MB',
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
      setState(() {
        _namaFile = file.name;
        _filePath = file.path;
        _fileSize = file.size;
      });
    }
  }

  Future<void> _kumpulkan() async {
    if (_namaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pilih file terlebih dahulu',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isSubmitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tColor = tipeColor(widget.item.tipe);
    final mColor = mapelColor(widget.item.mapel);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Kumpulkan Tugas',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.border.withOpacity(0.4)),
          ),
        ),
        body: _isSubmitted ? _buildSuccessState() : _buildForm(tColor, mColor),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppColors.teal, size: 52),
            ),
            const SizedBox(height: 24),
            Text(
              'Tugas Berhasil Dikumpulkan!',
              style: GoogleFonts.manrope(
                fontSize: 20, fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Tugasmu sudah diterima oleh ${widget.item.guru}.\nTunggu penilaian dari guru ya!',
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.subtle, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
                label: Text('Kembali ke Tugas & Kuis',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(Color tColor, Color mColor) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Info Card Tugas ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border.withOpacity(0.35)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10, offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: mColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        children: [
                          Icon(mapelIcon(widget.item.mapel), size: 11, color: mColor),
                          const SizedBox(width: 4),
                          Text(mapelLabel(widget.item.mapel),
                              style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w700, color: mColor)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: tColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Row(
                        children: [
                          Icon(tipeIcon(widget.item.tipe), size: 11, color: tColor),
                          const SizedBox(width: 4),
                          Text(tipeLabel(widget.item.tipe),
                              style: GoogleFonts.inter(
                                fontSize: 10, fontWeight: FontWeight.w700, color: tColor)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(widget.item.judul,
                    style: GoogleFonts.manrope(
                      fontSize: 16, fontWeight: FontWeight.w800,
                      color: AppColors.onSurface, height: 1.3,
                    )),
                const SizedBox(height: 4),
                Text(widget.item.guru,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.subtle)),
                if (widget.item.deadline != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.red.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer_rounded, size: 13, color: AppColors.red),
                        const SizedBox(width: 6),
                        Text('Tenggat: ${widget.item.deadline}',
                            style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.red)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Upload File ──
          Text('UNGGAH FILE TUGAS',
              style: GoogleFonts.manrope(
                fontSize: 12, fontWeight: FontWeight.w800,
                color: AppColors.onSurface, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async => await _pilihFile(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _namaFile != null ? AppColors.teal.withOpacity(0.06) : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _namaFile != null
                      ? AppColors.teal.withOpacity(0.4)
                      : AppColors.border.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: _namaFile != null
                  ? Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.insert_drive_file_rounded,
                              color: AppColors.teal, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_namaFile!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13, fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text(
                                _fileSize != null
                                    ? '${_formatFileSize(_fileSize!)} · Ketuk untuk mengganti'
                                    : 'Ketuk untuk mengganti file',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.subtle),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 20),
                      ],
                    )
                  : Column(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.upload_file_rounded,
                              color: AppColors.primary, size: 26),
                        ),
                        const SizedBox(height: 12),
                        Text('Ketuk untuk memilih file',
                            style: GoogleFonts.inter(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                        const SizedBox(height: 4),
                        Text('PDF, DOC, DOCX, JPG, PNG (maks. 10 MB)',
                            style: GoogleFonts.inter(fontSize: 11, color: AppColors.subtle)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Catatan ──
          Text('CATATAN (OPSIONAL)',
              style: GoogleFonts.manrope(
                fontSize: 12, fontWeight: FontWeight.w800,
                color: AppColors.onSurface, letterSpacing: 1.1)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border.withOpacity(0.4)),
            ),
            child: TextField(
              controller: _catatanController,
              maxLines: 4,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Tulis catatan atau keterangan untuk guru...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.all(14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Submit ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _kumpulkan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              label: Text(
                _isSubmitting ? 'Mengumpulkan...' : 'Kumpulkan Tugas',
                style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Badge ───────────────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.manrope(
                fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70)),
        ],
      ),
    );
  }
}

// ─── Jawaban Row ──────────────────────────────────────────────────────────────
class _JawabanRow extends StatelessWidget {
  final String huruf;
  final String teks;
  final String label;
  final Color color;

  const _JawabanRow({
    required this.huruf,
    required this.teks,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)),
          child: Center(
            child: Text(huruf,
                style: GoogleFonts.manrope(
                  fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 9, fontWeight: FontWeight.w700,
                    color: color, letterSpacing: 0.3)),
              Text(teks,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface)),
            ],
          ),
        ),
      ],
    );
  }
}
