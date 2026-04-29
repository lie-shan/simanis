import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ServerStatusWidget extends StatefulWidget {
  final Widget child;

  const ServerStatusWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ServerStatusWidget> createState() => _ServerStatusWidgetState();
}

class _ServerStatusWidgetState extends State<ServerStatusWidget> {
  bool _isServerDown = false;
  bool _showAlert = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkServerStatus();
    });
    // Check server status every 30 seconds
    _checkTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkServerStatus(),
    );
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkServerStatus() async {
    final isReachable = await ApiService().isServerReachable();
    
    if (mounted) {
      if (!isReachable && !_isServerDown) {
        // Server just went down
        setState(() {
          _isServerDown = true;
          _showAlert = true;
        });
        _showServerAlert();
      } else if (isReachable && _isServerDown) {
        // Server back online
        setState(() {
          _isServerDown = false;
          _showAlert = true;
        });
        _showServerBackAlert();
      }
    }
  }

  void _showServerAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_off, color: Colors.red, size: 48),
        title: const Text('Server Offline'),
        content: const Text(
          'Server sedang offline. Beberapa fitur mungkin tidak tersedia. Silakan hubungi administrator.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _showAlert = false);
            },
            child: const Text('TUTUP'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _checkServerStatus();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('COBA LAGI'),
          ),
        ],
      ),
    );
  }

  void _showServerBackAlert() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_done, color: Colors.green, size: 48),
        title: const Text('Server Online'),
        content: const Text('Server kembali online. Semua fitur sudah tersedia.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _showAlert = false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        setState(() => _showAlert = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: widget.child,
    );
  }
}

// Snackbar helper for server errors
class ServerErrorHandler {
  static void showServerDownSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Server sedang offline. Silakan hubungi administrator.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void handleApiError(BuildContext context, dynamic error) {
    if (error is ApiException && error.isServerDown) {
      showServerDownSnackbar(context);
    } else {
      // Show generic error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException 
                ? error.message 
                : 'Terjadi kesalahan. Silakan coba lagi.',
          ),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
