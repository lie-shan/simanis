import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Color Palette ────────────────────────────────────────────────────────────
class _AppColors {
  static const primary = Color(0xFF004D34);
  static const secondary = Color(0xFF006747);
  static const accent = Color(0xFFD97706);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceLowest = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline = Color(0xFF6F7A72);
  static const outlineVariant = Color(0xFFBEC9C1);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFDC2626);
}

// ─── Lupa Kata Sandi Page ─────────────────────────────────────────────────────
class LupaKataSandiPage extends StatefulWidget {
  const LupaKataSandiPage({super.key});

  @override
  State<LupaKataSandiPage> createState() => _LupaKataSandiPageState();
}

class _LupaKataSandiPageState extends State<LupaKataSandiPage> {
  final _formKey = GlobalKey<FormState>();
  final _whatsappCtrl = TextEditingController();
  bool _isLoading = false;
  bool _passwordSent = false;

  @override
  void dispose() {
    _whatsappCtrl.dispose();
    super.dispose();
  }

  Future<void> _kirimPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulasi pengiriman password via WhatsApp
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _passwordSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _AppColors.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: _AppColors.surfaceLowest,
                    foregroundColor: _AppColors.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    _passwordSent ? Icons.check_circle_rounded : Icons.lock_reset_rounded,
                    size: 40,
                    color: _AppColors.accent,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  _passwordSent ? 'Password Terkirim!' : 'Lupa Kata Sandi?',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  _passwordSent
                      ? 'Password baru telah dikirim ke nomor WhatsApp Anda. Silakan cek pesan WhatsApp Anda dan login dengan password baru.'
                      : 'Masukkan nomor WhatsApp yang terdaftar di akun Anda. Kami akan mengirimkan password baru melalui WhatsApp.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                if (!_passwordSent) ...[
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WhatsApp field
                        Text(
                          'Nomor WhatsApp',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _whatsappCtrl,
                          keyboardType: TextInputType.phone,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: _AppColors.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: '08123456789',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 14,
                              color: _AppColors.outline.withValues(alpha: 0.6),
                            ),
                            prefixIcon: Icon(
                              Icons.phone_android_rounded,
                              size: 20,
                              color: _AppColors.outline,
                            ),
                            filled: true,
                            fillColor: _AppColors.surfaceLowest,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _AppColors.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _AppColors.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: _AppColors.accent,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: _AppColors.error,
                                width: 1.5,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: _AppColors.error,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nomor WhatsApp wajib diisi';
                            }
                            // Remove all non-digit characters
                            final cleanNumber = value.trim().replaceAll(RegExp(r'\D'), '');
                            if (cleanNumber.length < 10 || cleanNumber.length > 13) {
                              return 'Nomor WhatsApp tidak valid (10-13 digit)';
                            }
                            if (!cleanNumber.startsWith('08') && !cleanNumber.startsWith('628')) {
                              return 'Nomor harus diawali 08 atau 628';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _kirimPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor:
                                  _AppColors.accent.withValues(alpha: 0.5),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Reset Kata Sandi',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Success actions
                  Column(
                    children: [
                      // Resend button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() => _passwordSent = false);
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: Text(
                            'Kirim Ulang Password',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _AppColors.accent,
                            side: const BorderSide(color: _AppColors.accent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Back to login
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_rounded, size: 20),
                          label: Text(
                            'Kembali ke Login',
                            style: GoogleFonts.manrope(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _AppColors.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),

                // Info box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: _AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Jika Anda tidak menerima pesan WhatsApp dalam 5 menit, pastikan nomor yang dimasukkan benar atau hubungi administrator.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _AppColors.primary,
                            height: 1.5,
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
