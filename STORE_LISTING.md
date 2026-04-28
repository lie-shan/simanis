# Store Listing Requirements - SIAKAD

Dokumen ini menjelaskan persyaratan untuk submit aplikasi SIAKAD ke berbagai app store termasuk Uptodown, APKPure, dan lainnya.

## Perubahan yang Sudah Dilakukan

Berikut perbaikan untuk masalah penolakan dari Uptodown:

### 1. Adaptive Icons ✅
- Folder `mipmap-anydpi-v26/ic_launcher.xml` ditambahkan
- `drawable-v24/ic_launcher_foreground.xml` ditambahkan  
- `drawable-v24/ic_launcher_background.xml` ditambahkan

### 2. README.md Diperbarui ✅
- Deskripsi aplikasi yang lengkap
- Fitur utama dijelaskan
- Instruksi instalasi detail
- Informasi dukungan dan kontak

## Langkah Build & Release

### 1. Clean Build
```bash
flutter clean
flutter pub get
```

### 2. Generate Icons (jika diperlukan)
```bash
flutter pub run flutter_launcher_icons:main
```

### 3. Build APK Release dengan Split ABI
```bash
flutter build apk --release --split-per-abi
```

Ini akan menghasilkan:
- `app-arm64-v8a-release.apk` - HP modern 64-bit
- `app-armeabi-v7a-release.apk` - HP lama 32-bit
- `app-x86_64-release.apk` - Emulator/Chromebook

### 4. Rename File untuk Release
```bash
# Rename sesuai versi
cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk siakad-v1.0.1-arm64-v8a.apk
cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk siakad-v1.0.1-armeabi-v7a.apk
cp build/app/outputs/flutter-apk/app-x86_64-release.apk siakad-v1.0.1-x86_64.apk
```

## Aset yang Diperlukan untuk Store Listing

### 1. App Icon (Wajib)
- Format: PNG
- Ukuran: 512x512 px minimum
- Background: Bebas (tapi gunakan warna solid dari brand)
- Lokasi: `assets/icon/icon.png`

### 2. Screenshots (Wajib)
Minimal 2-8 screenshot dengan spesifikasi:
- Format: PNG atau JPEG
- Ukuran: 
  - Phone: 1080x1920 px (9:16)
  - Tablet: 2048x1536 px (4:3) atau 2732x2048 px
- **Konten**: Tampilkan UI utama aplikasi
  - Halaman Login
  - Dashboard
  - Fitur QR Scanner
  - Halaman Presensi
  - Data Akademik

### 3. Feature Graphic (Wajib untuk Play Store)
- Format: PNG atau JPEG
- Ukuran: 1024x500 px
- File: `feature-graphic.html` (buka di browser untuk generate)

### 4. Video Promo (Opsional tapi direkomendasikan)
- Durasi: 30 detik - 2 menit
- Format: MP4, 720p minimum
- Konten: Demo penggunaan aplikasi

## Metadata untuk Store Listing

### Nama Aplikasi (Maks 50 karakter)
```
SIAKAD - Sistem Informasi Akademik
```

### Short Description (Maks 80 karakter)
```
Aplikasi manajemen sekolah dengan login QR, presensi, dan data akademik.
```

### Full Description
```
SIAKAD (Sistem Informasi Akademik) adalah aplikasi manajemen sekolah modern yang dirancang untuk memudahkan administrasi akademik, presensi, dan komunikasi dalam lingkungan pendidikan.

FITUR UTAMA:
• Login QR Code - Akses cepat dan aman dengan scan QR
• Dashboard Akademik - Lihat ringkasan data akademik secara real-time
• Presensi Digital - Catat kehadiran siswa dan guru dengan mudah
• Manajemen Data - Kelola data siswa, guru, dan kelas dalam satu platform
• Jadwal Pelajaran - Akses jadwal kapan saja dan di mana saja
• E-Learning Terintegrasi - Akses materi pembelajaran online

KEAMANAN:
• Enkripsi data dengan HTTPS/TLS
• Autentikasi token-based yang aman
• Validasi input pada server
• Tidak menyimpan password dalam plain text

SIAKAD cocok untuk sekolah, madrasah, dan institusi pendidikan lainnya yang ingin digitalisasi sistem informasi akademik mereka.

Dikembangkan oleh PT Sinan Pojok Technology
Lokasi: Garut, Jawa Barat, Indonesia
Support: support@sinan.my.id
```

### Kategori
- Education
- Productivity

### Tags
```
education, school, academic, siswa, guru, presensi, qr code, e-learning, sekolah, manajemen sekolah
```

## Daftar Store yang Dapat Di-submit

### 1. Uptodown (https://uptodown.com)
- Daftar di: https://developer.uptodown.com
- Upload APK langsung
- Butuh: App icon, screenshots, deskripsi

### 2. APKPure (https://apkpure.com)
- Daftar di: https://apkpure.com/dev-console
- Upload APK
- Butuh: Icon, screenshots, deskripsi

### 3. Aptoide (https://aptoide.com)
- Daftar di: https://www.aptoide.com/page/developer
- Upload APK via store backend

### 4. Amazon Appstore
- Daftar di: https://developer.amazon.com/apps-and-games
- Good untuk Fire tablet users

### 5. Samsung Galaxy Store
- Daftar di: https://seller.samsungapps.com
- Khusus untuk device Samsung

### 6. Huawei AppGallery
- Daftar di: https://developer.huawei.com
- Untuk device Huawei (tanpa Google Play)

## Tips Agar Tidak Ditolak

1. **App Icon Berkualitas**
   - Gunakan ikon vector bukan PNG blur
   - Adaptive icon wajib untuk Android 8.0+
   - Ikon harus jelas dan representatif

2. **Screenshots Asli**
   - Jangan pakai screenshot placeholder
   - Tampilkan UI aktual aplikasi
   - Bahasa UI sesuai target market

3. **Deskripsi Lengkap**
   - Jelaskan fitur dengan jelas
   - Hindari bahasa marketing berlebihan
   - Sertakan informasi kontak

4. **Kebijakan Privasi**
   - Harus ada dan accessible
   - Jelaskan data yang dikumpulkan
   - File: `PRIVACY_POLICY.md`

5. **App Functionality**
   - Pastikan app tidak crash
   - Tidak ada placeholder content
   - Semua tombol berfungsi

6. **App Size**
   - APK per ABI: < 50 MB ideal
   - Universal APK: < 100 MB
   - Split APK recommended

## Checklist Pre-Submission

- [ ] Adaptive icons sudah di-generate
- [ ] App icon 512x512 px siap
- [ ] Minimal 4 screenshots siap
- [ ] Feature graphic 1024x500 siap (opsional)
- [ ] README.md sudah lengkap
- [ ] Privacy Policy sudah ada
- [ ] APK sudah di-test dan tidak crash
- [ ] Versi app sudah di-update di `pubspec.yaml`
- [ ] App sudah di-sign dengan keystore release
- [ ] Tidak ada debug logs atau test code

## Troubleshooting Penolakan Umum

### "App doesn't meet minimum quality standards"
✅ **Solusi**: 
- Tambah adaptive icons
- Perbaiki README.md
- Sediakan screenshots berkualitas

### "Missing required assets"
✅ **Solusi**:
- Sediakan app icon 512x512
- Tambah screenshots minimal 2
- Upload feature graphic

### "App crashes on startup"
✅ **Solusi**:
- Test APK di device real sebelum submit
- Cek semua permission di AndroidManifest.xml
- Pastikan backend API accessible

## Kontak & Dukungan

Jika ada pertanyaan tentang store submission:
- Email: support@sinan.my.id
- Developer Console: https://developer.uptodown.com/help
