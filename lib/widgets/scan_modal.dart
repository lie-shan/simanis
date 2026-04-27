import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:audioplayers/audioplayers.dart';

class ScanModal {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScanModalContent(),
    );
  }
}

class ScanModalContent extends StatefulWidget {
  const ScanModalContent({super.key});

  @override
  State<ScanModalContent> createState() => _ScanModalContentState();
}

class _ScanModalContentState extends State<ScanModalContent> {
  late MobileScannerController controller;
  final AudioPlayer audioPlayer = AudioPlayer();
  
  bool _isProcessing = false;
  String _statusMessage = "Arahkan kamera tepat ke kode QR";
  Color _statusColor = const Color(0xFF004D34);

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    audioPlayer.dispose();
    super.dispose();
  }

  void _handleDetection(String? code) async {
    if (_isProcessing || code == null) return;
    
    setState(() {
      _isProcessing = true;
    });

    // Logika Validasi: Silahkan sesuaikan kriteria "Berhasil" Anda di sini
    bool isValid = code.contains("PRESENSI"); 

    try {
      if (isValid) {
        // Play suara sukses untuk Audioplayers 6.x.x
        await audioPlayer.play(AssetSource('sounds/success.mp3'));
        
        setState(() {
          _statusMessage = "Scan Berhasil!\n$code";
          _statusColor = const Color(0xFF004D34);
        });
      } else {
        // Play suara gagal untuk Audioplayers 6.x.x
        await audioPlayer.play(AssetSource('sounds/error.mp3'));
        
        setState(() {
          _statusMessage = "QR Code Tidak Valid!";
          _statusColor = Colors.red;
        });
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }

    // Jeda 3 detik: Agar user bisa melihat pesan & mendengar suara
    // Navigator.pop(context) DIHAPUS agar tidak langsung keluar
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _statusMessage = "Arahkan kamera tepat ke kode QR";
        _statusColor = const Color(0xFF004D34);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(
            "Scan QR Presensi",
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF004D34)),
          ),
          const SizedBox(height: 25),
          
          // Kotak Kamera
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _statusColor, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: MobileScanner(
                controller: controller,
                onDetect: (BarcodeCapture capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && !_isProcessing) {
                    _handleDetection(barcodes.first.rawValue);
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // KETERANGAN DI BAWAH KAMERA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _statusColor,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Tombol Kontrol
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(icon: Icons.flash_on_rounded, label: "Senter", onTap: () => controller.toggleTorch()),
                _buildActionButton(icon: Icons.flip_camera_ios_rounded, label: "Putar", onTap: () => controller.switchCamera()),
                _buildActionButton(icon: Icons.close_rounded, label: "Batal", onTap: () => Navigator.pop(context), isClose: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap, bool isClose = false}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: CircleAvatar(
            radius: 28,
            backgroundColor: isClose ? Colors.red.shade50 : Colors.grey.shade100,
            child: Icon(icon, color: isClose ? Colors.red : const Color(0xFF004D34)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}