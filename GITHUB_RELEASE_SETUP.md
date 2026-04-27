# Setup GitHub Releases dengan Auto-Download per ABI

Panduan lengkap untuk setup sistem otomatis download sesuai spesifikasi HP (ARM64, ARMv7, dll).

## 🎯 Cara Kerja Sistem

```
User buka halaman download → JavaScript deteksi arsitektur HP → Redirect ke APK yang tepat
```

## 📁 Struktur File yang Dihasilkan

Setelah build, GitHub Release akan berisi:

```
siakad-v1.0.0-arm64-v8a.apk    (24 MB)  → HP modern 2018+
siakad-v1.0.0-armeabi-v7a.apk  (20 MB)  → HP lama 32-bit
siakad-v1.0.0-x86_64.apk       (25 MB)  → Emulator/Chromebook
siakad-v1.0.0-universal.apk      (45 MB)  → Semua HP (jika ragu)
siakad-v1.0.0.aab                (40 MB)  → Untuk Play Store
```

## 🚀 Langkah Setup

### 1. Enable GitHub Pages

1. Buka repository GitHub Anda
2. Go to **Settings** → **Pages**
3. Source: **GitHub Actions**
4. Save

### 2. Setup Workflow

File `release-abi.yml` sudah dibuat di `.github/workflows/`. Workflow ini akan:
- Build APK per ABI (arm64-v8a, armeabi-v7a, x86_64, x86)
- Build universal APK
- Build AAB untuk Play Store
- Generate smart download page
- Deploy ke GitHub Pages

### 3. Cara Release

**Opsi A - Via Git Tag (Otomatis):**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Opsi B - Via GitHub Actions (Manual):**
1. Go to **Actions** tab di GitHub
2. Pilih workflow **"Build and Release (Split per ABI)"**
3. Click **Run workflow**
4. Masukkan versi (e.g., `1.0.0`)
5. Run

### 4. URL Download

Setelah deploy berhasil, halaman download akan tersedia di:
```
https://[username].github.io/siakad_login/
```

Contoh:
```
https://sinanpojok.github.io/siakad_login/
```

## 📱 Cara User Download

### Opsi 1 - Smart Download (Otomatis)
1. Buka halaman GitHub Pages
2. Sistem otomatis mendeteksi arsitektur HP
3. Klik tombol download yang direkomendasikan

### Opsi 2 - Manual dari GitHub Releases
1. Buka **Releases** di GitHub
2. Lihat tabel arsitektur di release notes
3. Pilih APK sesuai HP:
   - **HP baru (Samsung, Xiaomi, OPPO, Vivo 2018+)**: `arm64-v8a`
   - **HP lama**: `armeabi-v7a`
   - **Tidak yakin**: `universal`

## 🔍 Cara Cek Arsitektur HP

### Via Aplikasi (Mudah)
1. Install **CPU-Z** dari Play Store
2. Buka aplikasi
3. Lihat bagian **System** → **Architecture**
4. Cari yang ada tulisan `arm64` atau `armeabi`

### Via Command (Developer)
```bash
adb shell getprop ro.product.cpu.abi
```

### Via User Agent (Web)
Halaman download akan otomatis membaca user agent browser HP.

## 🛠️ Konfigurasi Tambahan (Optional)

### Custom Domain
Jika ingin pakai domain sendiri (e.g., `download.siakad.id`):

1. Tambahkan file `_site/CNAME`:
   ```
   download.siakad.id
   ```

2. Setup DNS di domain provider:
   ```
   CNAME download.siakad.id → [username].github.io
   ```

### Enable/Disable Auto-Download
Edit di `release-abi.yml` baris JavaScript:

```javascript
// Uncomment untuk auto-download tanpa klik:
setTimeout(() => {
    window.location.href = downloadUrl;
}, 2000);
```

## 📊 Perbandingan Ukuran File

| Arsitektur | Ukuran | Keterangan |
|------------|--------|------------|
| arm64-v8a | ~24 MB | 90% HP modern |
| armeabi-v7a | ~20 MB | HP lama 32-bit |
| x86_64 | ~25 MB | Emulator |
| universal | ~45 MB | Semua HP (gabungan semua ABI) |
| AAB | ~40 MB | Untuk Play Store |

## 🐛 Troubleshooting

### Halaman GitHub Pages 404
- Pastikan GitHub Pages di-enable di Settings
- Pastikan workflow `deploy-download-page` berhasil
- Tunggu 2-5 menit setelah deploy

### APK tidak terdownload
- Cek GitHub Release ada file APK
- Cek nama file sesuai format `siakad-v{VERSION}-{ABI}.apk`
- Cek URL di browser: `https://github.com/[user]/[repo]/releases/latest/download/...`

### Deteksi arsitektur salah
- Deteksi via User Agent tidak 100% akurat
- Selalu sediakan opsi manual download
- User bisa download universal APK sebagai fallback

## 📝 Changelog di Release

Workflow otomatis generate tabel seperti ini:

```markdown
| File | Arsitektur | Untuk HP |
|------|-----------|----------|
| siakad-v1.0.0-arm64-v8a.apk | ARM64 (64-bit) | HP modern 2018+ |
| siakad-v1.0.0-armeabi-v7a.apk | ARMv7 (32-bit) | HP lama 2017 ke bawah |
| siakad-v1.0.0-universal.apk | Universal | Semua HP |
```

## 🎨 Kustomisasi Halaman Download

Edit bagian `<style>` di workflow untuk ubah:
- Warna tema (default: ungu gradient)
- Ukuran tombol
- Font family
- Animasi

## 🔐 Keamanan
- Workflow hanya berjalan pada tag `v*` atau manual trigger
- GitHub Token otomatis di-generate, tidak perlu setup
- Pages hanya deploy file statis (HTML/CSS/JS)
