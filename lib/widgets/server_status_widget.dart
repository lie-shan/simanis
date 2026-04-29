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
  bool _showBanner = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _checkServerStatus();
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
      setState(() {
        if (!isReachable && !_isServerDown) {
          // Server just went down
          _isServerDown = true;
          _showBanner = true;
        } else if (isReachable && _isServerDown) {
          // Server back online
          _isServerDown = false;
          _showBanner = true;
        }
      });

      // Auto hide banner after 5 seconds if server is back
      if (isReachable && _showBanner) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _showBanner = false);
          }
        });
      }
    }
  }

  void _hideBanner() {
    setState(() => _showBanner = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Server Status Banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _showBanner ? null : 0,
          child: _showBanner
              ? MaterialBanner(
                  content: Row(
                    children: [
                      Icon(
                        _isServerDown ? Icons.cloud_off : Icons.cloud_done,
                        color: _isServerDown ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isServerDown
                              ? 'Server sedang offline. Beberapa fitur mungkin tidak tersedia.'
                              : 'Server kembali online.',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: _isServerDown 
                      ? Colors.red.shade700 
                      : Colors.green.shade700,
                  actions: [
                    TextButton(
                      onPressed: _hideBanner,
                      child: Text(
                        'TUTUP',
                        style: TextStyle(
                          color: _isServerDown 
                              ? Colors.red.shade100 
                              : Colors.green.shade100,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (_isServerDown)
                      TextButton(
                        onPressed: () {
                          _checkServerStatus();
                        },
                        child: const Text(
                          'COBA LAGI',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                )
              : null,
        ),
        // Main Content
        Expanded(child: widget.child),
      ],
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
