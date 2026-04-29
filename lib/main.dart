import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pages/dashboard_page.dart';
import 'pages/lupa_kata_sandi_page.dart';
import 'services/api_service.dart';
import 'services/device_service.dart';
import 'config/asset_config.dart';
import 'services/download_manager.dart';
import 'widgets/server_status_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize device service first
  await DeviceService().init();
  
  // Initialize asset configuration based on device
  await AssetConfig().init();
  
  // Initialize download manager
  await DownloadManager().init();
  
  // Initialize API service with saved token
  await ApiService().init();
  
  runApp(const SimanisApp());
}

// ─── Color Palette (from Tailwind config) ─────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF004D34);
  static const primaryContainer = Color(0xFF006747);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF735C00);
  static const secondaryContainer = Color(0xFFFED65B);
  static const onSecondaryContainer = Color(0xFF745C00);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const surfaceContainerHighest = Color(0xFFE1E3E4);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF3F4943);
  static const outline = Color(0xFF6F7A72);
  static const outlineVariant = Color(0xFFBEC9C1);
}

// ─── Theme ────────────────────────────────────────────────────────────────────
class AppTheme {
  static TextTheme get textTheme => TextTheme(
        headlineLarge: GoogleFonts.manrope(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
          letterSpacing: -0.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
        ),
      );

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          onPrimary: AppColors.onPrimary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          onSurface: AppColors.onSurface,
        ),
        textTheme: textTheme,
        scaffoldBackgroundColor: AppColors.surface,
      );
}

// ─── App ─────────────────────────────────────────────────────────────────────
class SimanisApp extends StatelessWidget {
  const SimanisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMANIS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      locale: const Locale('id', 'ID'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      builder: (context, child) {
        return ServerStatusWidget(child: child!);
      },
      home: const LoginPage(),
    );
  }
}

// ─── Login Page ───────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final api = ApiService();
        final response = await api.post(
          '/api/auth/login',
          body: {
            'email': _usernameController.text,
            'password': _passwordController.text,
          },
          requiresAuth: false,
        );

        if (response['success'] == true) {
          // Save token
          final token = response['data']['token'];
          await api.saveToken(token);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login berhasil!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardPage()),
            );
          }
        } else {
          throw Exception(response['message'] ?? 'Login gagal');
        }
      } on ApiException catch (e) {
        if (mounted) {
          if (e.isServerDown) {
            ServerErrorHandler.showServerDownSnackbar(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          if (e.toString().contains('Server sedang offline')) {
            ServerErrorHandler.showServerDownSnackbar(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login gagal: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── Decorative background ──
          const _BackgroundDecoration(),
          // ── Scrollable content ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: _LoginCard(
                    formKey: _formKey,
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    isLoading: _isLoading,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onLogin: _handleLogin,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background Decoration ────────────────────────────────────────────────────
class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dot pattern overlay
        Opacity(
          opacity: 0.04,
          child: CustomPaint(
            painter: _DotPatternPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        // Top-left glow
        Positioned(
          top: -96,
          left: -96,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.05),
            ),
          ),
        ),
        // Bottom-right glow
        Positioned(
          bottom: -96,
          right: -96,
          child: Container(
            width: 384,
            height: 384,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondary.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeCap = StrokeCap.round;

    const spacing = 20.0;
    const dotRadius = 0.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
        canvas.drawCircle(
            Offset(x + spacing / 2, y + spacing / 2), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPatternPainter oldDelegate) => false;
}

// ─── Login Card ───────────────────────────────────────────────────────────────
class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool isLoading;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Branding ──
            const _BrandingSection(),
            const SizedBox(height: 32),
            // ── Username field ──
            _FieldLabel(label: 'Nomor Induk / Username'),
            const SizedBox(height: 8),
            _InputField(
              controller: usernameController,
              hint: 'Masukkan nomor induk atau username',
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.text,
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Username tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 20),
            // ── Password field ──
            _FieldLabel(label: 'Kata Sandi'),
            const SizedBox(height: 8),
            _InputField(
              controller: passwordController,
              hint: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: obscurePassword,
              suffixIcon: IconButton(
                onPressed: onTogglePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.outline,
                  size: 20,
                ),
                splashRadius: 18,
              ),
              validator: (v) => (v == null || v.isEmpty)
                  ? 'Kata sandi tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LupaKataSandiPage(),
                    ),
                  );
                },
                child: Text(
                  'Lupa Kata Sandi?',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.secondary.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ── Login button ──
            _LoginButton(isLoading: isLoading, onPressed: onLogin),
            const SizedBox(height: 32),
            // ── Help section ──
            const _HelpSection(),
          ],
        ),
      ),
    );
  }
}

// ─── Branding Section ─────────────────────────────────────────────────────────
class _BrandingSection extends StatelessWidget {
  const _BrandingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Login SIMANIS',
          style: GoogleFonts.manrope(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Silakan masuk ke akun Anda',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Field Label ──────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
    );
  }
}

// ─── Input Field ──────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.outline.withOpacity(0.7),
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Icon(prefixIcon, color: AppColors.outline, size: 20),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 2),
        ),
      ),
    );
  }
}

// ─── Login Button ─────────────────────────────────────────────────────────────
class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Masuk',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.onPrimary,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Help Section ─────────────────────────────────────────────────────────────
class _HelpSection extends StatelessWidget {
  const _HelpSection();

  Future<void> _openWhatsApp() async {
    // Ganti nomor WhatsApp admin di bawah ini (format: kode negara + nomor tanpa 0 di depan)
    const phone = '6281234567890';
    const message = 'Halo Admin, saya ingin mendaftar akun SIMANIS.';
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Color(0x1FBEC9C1), thickness: 1),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _openWhatsApp,
          child: Text.rich(
            TextSpan(
              text: 'Belum punya akun? ',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              children: [
                TextSpan(
                  text: 'Hubungi Admin Madrasah',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primary.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}