import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/elearning_models.dart';
import '../../widgets/shared_widgets.dart';

// ─── Tab Materi ───────────────────────────────────────────────────────────────
class MateriTab extends StatelessWidget {
  final List<MateriItem> filteredMateri;
  final MataPelajaran? filterMapel;
  final TipeKonten? filterTipe;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<MataPelajaran?> onMapelFilter;
  final ValueChanged<TipeKonten?> onTipeFilter;
  final ValueChanged<MateriItem> onEdit;
  final ValueChanged<String> onHapus;
  final void Function(String id, StatusMateri status) onStatusUpdate;

  const MateriTab({
    super.key,
    required this.filteredMateri,
    required this.filterMapel,
    required this.filterTipe,
    required this.searchController,
    required this.onSearchChanged,
    required this.onMapelFilter,
    required this.onTipeFilter,
    required this.onEdit,
    required this.onHapus,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100;
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
      children: [
        // ── Search ──
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Cari materi, mata pelajaran, atau guru...',
              hintStyle:
                  GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
              prefixIcon: Icon(Icons.search_rounded,
                  color: Colors.grey.shade400, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // ── Filter Mapel ──
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              EFilterChip(
                label: 'Semua',
                isSelected: filterMapel == null,
                onTap: () => onMapelFilter(null),
                color: AppColors.primary,
              ),
              ...MataPelajaran.values.map((m) => EFilterChip(
                    label: mapelLabel(m),
                    isSelected: filterMapel == m,
                    onTap: () => onMapelFilter(filterMapel == m ? null : m),
                    color: mapelColor(m),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // ── Filter Tipe ──
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              EFilterChip(
                label: 'Semua Tipe',
                isSelected: filterTipe == null,
                onTap: () => onTipeFilter(null),
                color: AppColors.subtle,
              ),
              ...[TipeKonten.video, TipeKonten.pdf].map((t) => EFilterChip(
                    label: tipeLabel(t),
                    isSelected: filterTipe == t,
                    onTap: () => onTipeFilter(filterTipe == t ? null : t),
                    color: tipeColor(t),
                    icon: tipeIcon(t),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Results ──
        if (filteredMateri.isEmpty)
          EEmptyState(
            icon: Icons.search_off_rounded,
            title: 'Materi tidak ditemukan',
            subtitle: 'Coba ubah kata kunci atau filter pencarian',
          )
        else
          ...filteredMateri.map((m) => MateriCard(
                item: m,
                onEdit: () => onEdit(m),
                onHapus: (id) => onHapus(id),
                onStatusUpdate: onStatusUpdate,
              )),
      ],
    );
  }
}

// ─── Materi Card ──────────────────────────────────────────────────────────────
class MateriCard extends StatelessWidget {
  final MateriItem item;
  final VoidCallback onEdit;
  final ValueChanged<String> onHapus;
  final void Function(String id, StatusMateri status) onStatusUpdate;
  const MateriCard({super.key, required this.item, required this.onEdit, required this.onHapus, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    final mColor = mapelColor(item.mapel);
    final tColor = tipeColor(item.tipe);

    return InkWell(
      onTap: () => _showMateriDetail(context, item),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
        child: Column(
          children: [
            // ── Header strip ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mColor.withOpacity(0.07),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: mColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(mapelIcon(item.mapel), color: mColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mapelLabel(item.mapel),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: mColor,
                    ),
                  ),
                  const Spacer(),
                  if (item.isDue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_rounded,
                              size: 10, color: AppColors.red),
                          const SizedBox(width: 3),
                          Text(
                            'Tenggat ${item.deadline}',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 4),
                  // ── Menu edit/hapus ──
                  GestureDetector(
                    onTap: () {},
                    child: PopupMenuButton<String>(
                      onSelected: (val) {
                        if (val == 'edit') onEdit();
                        if (val == 'hapus') onHapus(item.id);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      icon: Icon(Icons.more_vert_rounded,
                          size: 16, color: AppColors.subtle.withOpacity(0.6)),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text('Edit',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'hapus',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_rounded,
                                  size: 16, color: AppColors.red),
                              const SizedBox(width: 8),
                              Text('Hapus',
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: tColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(tipeIcon(item.tipe), color: tColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.judul,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.guru,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.subtle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (item.tipe != TipeKonten.pdf) ...[  
                              EMetaChip(
                                icon: Icons.access_time_rounded,
                                label: item.durasi,
                                color: AppColors.subtle,
                              ),
                              const SizedBox(width: 6),
                            ],
                            EMetaChip(
                              icon: tipeIcon(item.tipe),
                              label: tipeLabel(item.tipe),
                              color: tColor,
                            ),
                            const Spacer(),
                            Icon(
                              statusIcon(item.status),
                              size: 18,
                              color: statusColor(item.status),
                            ),
                          ],
                        ),
                        if (item.status == StatusMateri.selesai &&
                            item.nilaiKuis > 0) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 12, color: AppColors.teal),
                                const SizedBox(width: 4),
                                Text(
                                  'Nilai: ${item.nilaiKuis}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.teal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  void _showMateriDetail(BuildContext context, MateriItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MateriDetailSheet(item: item, onStatusUpdate: onStatusUpdate),
    );
  }
}

// ─── Detail Bottom Sheet ───────────────────────────────────────────────────────
class MateriDetailSheet extends StatelessWidget {
  final MateriItem item;
  final void Function(String id, StatusMateri status) onStatusUpdate;
  const MateriDetailSheet({super.key, required this.item, required this.onStatusUpdate});

  @override
  Widget build(BuildContext context) {
    final mColor = mapelColor(item.mapel);
    final tColor = tipeColor(item.tipe);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      expand: false,
      snap: true,
      snapSizes: const [0.4, 0.6, 0.92],
      builder: (_, controller) => GestureDetector(
        onTap: () {},
        child: Container(
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
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Mapel badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: mColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(mapelIcon(item.mapel), size: 13, color: mColor),
                          const SizedBox(width: 5),
                          Text(
                            mapelLabel(item.mapel),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: mColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: tColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(tipeIcon(item.tipe), size: 13, color: tColor),
                          const SizedBox(width: 5),
                          Text(
                            tipeLabel(item.tipe),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: tColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  item.judul,
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.guru,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.subtle),
                ),
                const SizedBox(height: 16),

                if (item.tipe != TipeKonten.pdf)
                EDetailRow(
                    icon: Icons.access_time_rounded,
                    label: 'Durasi',
                    value: item.durasi),
                EDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Diunggah',
                    value: item.tanggalUpload),
                if (item.deadline != null)
                  EDetailRow(
                      icon: Icons.timer_rounded,
                      label: 'Tenggat',
                      value: item.deadline!),
                if (item.nilaiKuis > 0)
                  EDetailRow(
                      icon: Icons.star_rounded,
                      label: 'Nilai',
                      value: '${item.nilaiKuis} / 100'),

                const SizedBox(height: 16),
                Text(
                  'Deskripsi',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.subtle,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.deskripsi,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurface,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (item.tipe == TipeKonten.video) {
                        onStatusUpdate(item.id, StatusMateri.sedangDibaca);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerPage(
                              item: item,
                              onStatusUpdate: onStatusUpdate,
                            ),
                          ),
                        );
                      } else if (item.tipe == TipeKonten.pdf) {
                        final path = item.pdfUrl ?? '';
                        if (path.isNotEmpty) {
                          onStatusUpdate(item.id, StatusMateri.selesai);
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PdfViewerPage(
                                filePath: path,
                                judul: item.judul,
                              ),
                            ),
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('File dokumen belum diupload',
                                  style: GoogleFonts.inter()),
                              backgroundColor: AppColors.subtle,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ));
                          }
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(
                      item.tipe == TipeKonten.video
                          ? Icons.play_arrow_rounded
                          : item.tipe == TipeKonten.pdf
                              ? Icons.open_in_new_rounded
                              : Icons.edit_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      item.tipe == TipeKonten.video
                          ? 'Tonton Video'
                          : item.tipe == TipeKonten.pdf
                              ? 'Buka Dokumen'
                              : item.tipe == TipeKonten.kuis
                                  ? 'Mulai Kuis'
                                  : 'Kumpulkan Tugas',
                      style: GoogleFonts.inter(
                        fontSize: 14,
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
      ),
    );
  }
}

// ─── Video Player Page ────────────────────────────────────────────────────────
class VideoPlayerPage extends StatefulWidget {
  final MateriItem item;
  final void Function(String id, StatusMateri status) onStatusUpdate;
  const VideoPlayerPage({super.key, required this.item, required this.onStatusUpdate});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = widget.item.youtubeId ?? '';
    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        forceHD: false,
      ),
    );
    _controller.addListener(_onPlayerStateChanged);
  }

  void _onPlayerStateChanged() {
    if (_controller.value.playerState == PlayerState.ended) {
      widget.onStatusUpdate(widget.item.id, StatusMateri.selesai);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onPlayerStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mColor = mapelColor(widget.item.mapel);

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.primary,
        progressColors: const ProgressBarColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
        ),
        onReady: () {},
      ),
      builder: (context, player) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              // ── Video Area ──
              Container(
                color: Colors.black,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20),
                            ),
                            Expanded(
                              child: Text(
                                widget.item.judul,
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      player,
                    ],
                  ),
                ),
              ),

              // ── Info Area ──
              Expanded(
                child: Container(
                  color: AppColors.surface,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: mColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(mapelIcon(widget.item.mapel),
                                  size: 13, color: mColor),
                              const SizedBox(width: 5),
                              Text(
                                mapelLabel(widget.item.mapel),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: mColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          widget.item.judul,
                          style: GoogleFonts.manrope(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                size: 14, color: AppColors.subtle),
                            const SizedBox(width: 4),
                            Text(widget.item.guru,
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.subtle)),
                            const SizedBox(width: 12),
                            const Icon(Icons.access_time_rounded,
                                size: 14, color: AppColors.subtle),
                            const SizedBox(width: 4),
                            Text(widget.item.durasi,
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.subtle)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Divider(height: 1, color: AppColors.border.withOpacity(0.4)),
                        const SizedBox(height: 16),

                        Text(
                          'Deskripsi',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.subtle,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.item.deskripsi,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurface,
                            height: 1.6,
                          ),
                        ),
                      ],
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

// ─── Form Tambah / Edit Materi ────────────────────────────────────────────────
class MateriFormSheet extends StatefulWidget {
  final MateriItem? materi;
  final ValueChanged<MateriItem> onSave;

  const MateriFormSheet({super.key, this.materi, required this.onSave});

  @override
  State<MateriFormSheet> createState() => _MateriFormSheetState();
}

class _MateriFormSheetState extends State<MateriFormSheet> {
  final _judulCtrl    = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _youtubeCtrl  = TextEditingController();
  String? _pickedFilePath;
  String? _pickedFileName;
  String _guru = 'Pak Budi Santoso';
  MataPelajaran _mapel = MataPelajaran.matematika;
  TipeKonten _tipe = TipeKonten.video;
  late StatusMateri _status;
  bool _isSaving = false;
  bool _isPickingFile = false;
  // Durasi — dropdown
  String _selectedDurasi = '20 menit';
  final List<String> _durasiOptions = ['5 menit','10 menit','15 menit','20 menit','30 menit','45 menit','60 menit','90 menit'];

  @override
  void initState() {
    super.initState();
    final m = widget.materi;
    _status = m?.status ?? StatusMateri.belumDibaca;
    if (m != null) {
      _judulCtrl.text     = m.judul;
      _deskripsiCtrl.text = m.deskripsi == 'Tidak ada deskripsi' ? '' : m.deskripsi;
      if (m.durasi != '-' && m.durasi != '—' && _durasiOptions.contains(m.durasi)) {
        _selectedDurasi = m.durasi;
      }
      _youtubeCtrl.text   = m.youtubeId ?? '';
      // Jika ada pdfUrl (path lokal), tampilkan nama file-nya
      if (m.pdfUrl != null && m.pdfUrl!.isNotEmpty) {
        _pickedFilePath = m.pdfUrl;
        _pickedFileName = m.pdfUrl!.split('/').last.split('\\').last;
      }
      _guru   = m.guru.isNotEmpty ? m.guru : 'Pak Budi Santoso';
      _mapel  = m.mapel;
      _tipe   = m.tipe;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose(); _deskripsiCtrl.dispose();
    _youtubeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );
      if (result != null && result.files.single.name.isNotEmpty) {
        final f = result.files.single;
        final appDir = await getApplicationDocumentsDirectory();
        final targetPath = "${appDir.path}/${f.name}";
        if (f.path != null) {
          await File(f.path!).copy(targetPath);
        } else if (f.bytes != null) {
          await File(targetPath).writeAsBytes(f.bytes!);
        }
        setState(() { _pickedFilePath = targetPath; _pickedFileName = f.name; });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memilih file: $e', style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  String _bulan(int m) {
    const b = ['','Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return b[m];
  }

  void _simpan() {
    if (_judulCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Judul tidak boleh kosong',
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _isSaving = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      final isEdit = widget.materi != null;
      final result = MateriItem(
        id: widget.materi?.id ?? '',
        judul: _judulCtrl.text.trim(),
        deskripsi: _deskripsiCtrl.text.trim().isEmpty ? 'Tidak ada deskripsi' : _deskripsiCtrl.text.trim(),
        mapel: _mapel, tipe: _tipe, status: _status,
        durasi: _tipe == TipeKonten.pdf ? '-' : _selectedDurasi,
        tanggalUpload: widget.materi?.tanggalUpload ??
            '${DateTime.now().day} ${_bulan(DateTime.now().month)} ${DateTime.now().year}',
        guru: _guru,
        youtubeId: _tipe == TipeKonten.video ? _youtubeCtrl.text.trim() : null,
        pdfUrl: _tipe == TipeKonten.pdf ? _pickedFilePath : null,
        nilaiKuis: widget.materi?.nilaiKuis ?? 0,
      );
      widget.onSave(result);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Materi berhasil diperbarui' : 'Materi berhasil ditambahkan',
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.materi != null;
    final tColor = tipeColor(_tipe);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + bottomPadding),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99)))),
            const SizedBox(height: 20),
            Row(children: [
              Container(width: 40, height: 40,
                decoration: BoxDecoration(color: tColor.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
                child: Icon(tipeIcon(_tipe), color: tColor, size: 20)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isEdit ? 'Edit Materi' : 'Tambah Materi Baru',
                    style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                Text(isEdit ? 'Perbarui informasi materi' : 'Isi data materi baru',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.subtle)),
              ]),
            ]),
            const SizedBox(height: 20),

            Text('TIPE KONTEN', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Row(children: [TipeKonten.video, TipeKonten.pdf].map((t) {
              final sel = _tipe == t; final color = tipeColor(t);
              return Expanded(child: GestureDetector(
                onTap: () => setState(() => _tipe = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: sel ? color : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: sel ? color : AppColors.border.withOpacity(0.4), width: sel ? 1.5 : 1),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(tipeIcon(t), size: 15, color: sel ? Colors.white : color),
                    const SizedBox(width: 6),
                    Text(tipeLabel(t), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.subtle)),
                  ]),
                ),
              ));
            }).toList()),
            const SizedBox(height: 18),

            Text('JUDUL', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withOpacity(0.4))),
              child: TextField(controller: _judulCtrl, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                decoration: InputDecoration(hintText: 'Judul materi', hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400), contentPadding: const EdgeInsets.all(14), border: InputBorder.none)),
            ),
            const SizedBox(height: 18),

            if (_tipe == TipeKonten.video) ...[
              Text('YOUTUBE ID', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withOpacity(0.4))),
                child: TextField(controller: _youtubeCtrl, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                  decoration: InputDecoration(hintText: 'Contoh: jL5jtqWFy0w', hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
                    contentPadding: const EdgeInsets.all(14), border: InputBorder.none,
                    prefixIcon: const Icon(Icons.play_circle_rounded, color: AppColors.subtle, size: 18))),
              ),
              const SizedBox(height: 18),
            ] else ...[
              Text('UPLOAD DOKUMEN PDF', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isPickingFile ? null : _pickPdfFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _pickedFilePath != null
                        ? AppColors.teal.withOpacity(0.06)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _pickedFilePath != null
                          ? AppColors.teal.withOpacity(0.4)
                          : AppColors.border.withOpacity(0.4),
                    ),
                  ),
                  child: _isPickingFile
                      ? Row(children: [
                          const SizedBox(width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                          const SizedBox(width: 12),
                          Text('Memilih file...', style: GoogleFonts.inter(fontSize: 13, color: AppColors.subtle)),
                        ])
                      : Row(children: [
                          Icon(
                            _pickedFilePath != null ? Icons.picture_as_pdf_rounded : Icons.upload_file_rounded,
                            size: 20,
                            color: _pickedFilePath != null ? AppColors.teal : AppColors.subtle,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(
                            _pickedFileName ?? 'Pilih file PDF...',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _pickedFilePath != null ? AppColors.onSurface : Colors.grey.shade400,
                              fontWeight: _pickedFilePath != null ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )),
                          if (_pickedFilePath != null) ...[
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => setState(() { _pickedFilePath = null; _pickedFileName = null; }),
                              child: const Icon(Icons.close_rounded, size: 16, color: AppColors.subtle),
                            ),
                          ],
                        ]),
                ),
              ),
              const SizedBox(height: 18),
            ],

            Text('DESKRIPSI (OPSIONAL)', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withOpacity(0.4))),
              child: TextField(controller: _deskripsiCtrl, maxLines: 3, style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                decoration: InputDecoration(hintText: 'Deskripsi singkat materi...', hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400), contentPadding: const EdgeInsets.all(14), border: InputBorder.none)),
            ),
            const SizedBox(height: 18),

            Text('GURU', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withOpacity(0.4))),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                value: _guru, isExpanded: true,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.subtle),
                onChanged: (v) { if (v != null) setState(() => _guru = v); },
                items: ['Pak Budi Santoso','Bu Siti Rahayu','Pak Joko Widodo','Bu Ani Suryani','Pak Hendra Wijaya','Bu Dewi Kartika']
                  .map((g) => DropdownMenuItem(value: g, child: Row(children: [
                    const Icon(Icons.person_rounded, size: 15, color: AppColors.subtle),
                    const SizedBox(width: 8), Text(g)]))).toList(),
              )),
            ),
            const SizedBox(height: 18),

            Text('MATA PELAJARAN', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withOpacity(0.4))),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonHideUnderline(child: DropdownButton<MataPelajaran>(
                value: _mapel, isExpanded: true,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.subtle),
                onChanged: (v) { if (v != null) setState(() => _mapel = v); },
                items: MataPelajaran.values.map((m) => DropdownMenuItem(value: m,
                  child: Row(children: [Icon(mapelIcon(m), color: mapelColor(m), size: 15), const SizedBox(width: 8), Text(mapelLabel(m))]))).toList(),
              )),
            ),
            const SizedBox(height: 18),

            if (_tipe != TipeKonten.pdf) ...[
              Text('DURASI', style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border.withOpacity(0.4))),
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
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, color: AppColors.subtle, size: 16),
                          const SizedBox(width: 8),
                          Text(d),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 26),
            ] else
              const SizedBox(height: 26),

            SizedBox(width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: tColor, disabledBackgroundColor: tColor.withOpacity(0.5),
                  elevation: 0, padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: _isSaving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(isEdit ? Icons.save_rounded : Icons.add_rounded, size: 18, color: Colors.white),
                label: Text(_isSaving ? 'Menyimpan...' : isEdit ? 'Simpan Perubahan' : 'Tambah Materi',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ─── PDF Viewer Page ─────────────────────────────────────────────────────────
class PdfViewerPage extends StatefulWidget {
  final String filePath;
  final String judul;
  const PdfViewerPage({super.key, required this.filePath, required this.judul});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isReady = false;
  PDFViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.onSurface, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.judul,
                style: GoogleFonts.manrope(
                    fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            if (_isReady)
              Text('Halaman ${_currentPage + 1} dari $_totalPages',
                  style: GoogleFonts.inter(fontSize: 10, color: AppColors.subtle)),
          ],
        ),
        actions: [
          if (_isReady && _totalPages > 1) ...[
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: AppColors.onSurface),
              onPressed: _currentPage > 0
                  ? () => _controller?.setPage(_currentPage - 1)
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded, color: AppColors.onSurface),
              onPressed: _currentPage < _totalPages - 1
                  ? () => _controller?.setPage(_currentPage + 1)
                  : null,
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            onRender: (pages) => setState(() {
              _totalPages = pages ?? 0;
              _isReady = true;
            }),
            onPageChanged: (page, total) => setState(() {
              _currentPage = page ?? 0;
              _totalPages = total ?? 0;
            }),
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Gagal memuat PDF: $error',
                    style: GoogleFonts.inter()),
                backgroundColor: AppColors.red,
              ));
            },
            onViewCreated: (controller) => _controller = controller,
          ),
          if (!_isReady)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text('Memuat dokumen...',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.subtle)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
