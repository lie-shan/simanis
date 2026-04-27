package id.sinan.siakad

import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Channel harus sama persis dengan yang ada di Dart
    private val CHANNEL = "id.sinan.siakad/kuis_lock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {

                    // ── Mulai mode kuis: FLAG_SECURE ──────────────────────────────────────
                    // FLAG_SECURE:
                    //   1. Blokir screenshot & screen record selama kuis
                    //   2. Halaman kuis tampil HITAM di Recent Apps → user tidak bisa
                    //      "melihat soal" dari luar tanpa masuk ke app
                    //   3. TIDAK menampilkan notifikasi "Aplikasi disematkan"
                    //
                    // Penting: ini TIDAK mencegah minimize secara paksa.
                    // Pencegahan minimize & deteksi keluar dilakukan di sisi Flutter
                    // via AppLifecycleListener (onPause → auto-submit).
                    "startScreenPin" -> {
                        try {
                            runOnUiThread {
                                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                    // Sembunyikan konten di Recent Apps (tampil hitam/blur)
                                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                                }
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("LOCK_FAILED", e.message, null)
                        }
                    }

                    // ── Selesai kuis: lepas FLAG_SECURE ──────────────────────────────────
                    "stopScreenPin" -> {
                        try {
                            runOnUiThread {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("UNLOCK_FAILED", e.message, null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
