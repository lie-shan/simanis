# SIAKAD - Sistem Informasi Akademik

Aplikasi manajemen sekolah modern untuk memudahkan administrasi akademik, presensi, dan komunikasi antara siswa, guru, dan orang tua.

## Deskripsi

SIAKAD (Sistem Informasi Akademik) adalah solusi digital untuk institusi pendidikan yang menyediakan:
- Login dengan QR Code untuk keamanan dan kemudahan
- Manajemen data siswa dan guru
- Presensi digital real-time
- Akses jadwal pelajaran
- E-learning terintegrasi
- Laporan akademik dan nilai

## Fitur Utama

- **Login QR Code**: Akses cepat dan aman dengan scan QR
- **Dashboard Akademik**: Lihat ringkasan data akademik
- **Presensi Digital**: Catat kehadiran secara real-time
- **Manajemen Data**: Kelola data siswa, guru, dan kelas
- **Jadwal Pelajaran**: Akses jadwal anytime, anywhere
- **E-Learning**: Akses materi pembelajaran online

## Teknologi

- **Framework**: Flutter 3.x
- **Backend**: REST API dengan integrasi database
- **State Management**: Provider
- **Storage**: Shared Preferences untuk local data

## Persyaratan Sistem

- Android 5.0 (API 21) atau lebih tinggi
- iOS 12 atau lebih tinggi (jika tersedia)
- Koneksi internet untuk fitur online

## Instalasi

### Download APK

1. Buka halaman [GitHub Releases](../../releases)
2. Pilih versi terbaru
3. Download APK sesuai arsitektur perangkat Anda:
   - **HP modern (2018+)**: `siakad-vX.X.X-arm64-v8a.apk`
   - **HP lama**: `siakad-vX.X.X-armeabi-v7a.apk`
   - **Tidak yakin**: `siakad-vX.X.X-universal.apk`
4. Install APK di perangkat Android Anda

### Build dari Source

```bash
# Clone repository
git clone https://github.com/username/siakad_login.git
cd siakad_login

# Install dependencies
flutter pub get

# Build APK release
flutter build apk --release

# Build APK dengan split per ABI (recommended)
flutter build apk --release --split-per-abi
```

## Pengaturan Backend

Aplikasi ini memerlukan backend server. Lihat file `INTEGRATION_GUIDE.md` untuk instruksi lengkap integrasi dengan server Anda.

## Keamanan

- Enkripsi data dengan HTTPS/TLS
- Autentikasi token-based
- Validasi input pada server
- Tidak menyimpan password dalam plain text

## Lisensi

Aplikasi ini dilisensikan untuk penggunaan institusi pendidikan. Hubungi pengembang untuk informasi lebih lanjut.

## Dukungan

- **Email**: support@sinan.my.id
- **Website**: https://sinan.my.id
- **Lokasi**: Garut, Jawa Barat, Indonesia

## Dokumen Terkait

- [Panduan Integrasi](INTEGRATION_GUIDE.md)
- [Kebijakan Privasi](PRIVACY_POLICY.md)
- [Panduan Rilis](GITHUB_RELEASE_SETUP.md)
- [Quick Start](QUICK_START.md)

---

**Versi**: 1.0.0+2  
**Dikembangkan oleh**: PT Sinan Pojok Technology
