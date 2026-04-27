# GitHub Setup untuk Auto-Download System

## 🚀 Setup Instructions

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** tab
3. Scroll down to **GitHub Pages** section
4. Under **Build and deployment**, select **GitHub Actions** as source
5. Save settings

### 2. Configure Repository Secrets

Go to **Settings** → **Secrets and variables** → **Actions** and add:

```
GITHUB_TOKEN (already available)
```

### 3. Update Repository URLs

Sebelum membuat release, update URL berikut di file-file yang relevan:

#### 1. Update `.github/scripts/generate-release-description.py`
```python
# Ganti baris ini dengan repository Anda
repo_name = 'your-username/siakad_login'  # → 'username-anda/siakad_login'
```

#### 2. Update `web/download.html`
```javascript
// Ganti URL base dengan repository Anda
const baseUrl = "https://github.com/your-username/siakad_login/releases/latest/download";
// → "https://github.com/username-anda/siakad_login/releases/latest/download"
```

#### 3. Update GitHub Workflow
Di `.github/workflows/release.yml`, pastikan repository name benar:
```yaml
baseUrl: "https://github.com/${{ github.repository }}/releases/latest/download"
```

### 4. Create Release

#### Method 1: Automatic (Tag-based)
```bash
git tag v1.0.0
git push origin v1.0.0
```

#### Method 2: Manual (GitHub Actions)
1. Go to **Actions** tab
2. Select **Build and Release** workflow
3. Click **Run workflow**
4. Input version (e.g., `1.0.0`)
5. Add release notes (optional)
6. Click **Run workflow**

### 5. Access Download Pages

Setelah release selesai, Anda akan memiliki:

#### Smart Download Page (Auto-Detection)
URL: `https://username-anda.github.io/siakad_login/release/v1.0.0/download.html`

Features:
- ✅ Automatic device detection
- ✅ Smart APK selection
- ✅ Progress tracking
- ✅ Beautiful UI

#### GitHub Release Page
URL: `https://github.com/username-anda/siakad_login/releases/tag/v1.0.0`

Features:
- ✅ Device compatibility matrix
- ✅ Manual download links
- ✅ QR code support
- ✅ Detailed documentation

## 📱 Cara Penggunaan untuk End User

### Method 1: Smart Download (Recommended)
1. Buka link smart download di HP Android
2. Klik tombol "Download Sekarang"
3. Tunggu proses deteksi device (2-3 detik)
4. Download otomatis dimulai
5. Install APK setelah selesai

### Method 2: Manual Selection
1. Buka GitHub release page
2. Cek spesifikasi HP di Settings → About Phone
3. Pilih versi yang sesuai:
   - **Low-end**: < 2GB RAM
   - **Medium**: 2-4GB RAM  
   - **High-end**: 4-8GB RAM
   - **Premium**: > 8GB RAM
   - **Universal**: Auto-adapt (jika ragu)

### Method 3: QR Code
1. Download `smart-download.html` dari release
2. Buka di desktop browser
3. Scan QR code dengan HP camera
4. Download otomatis dimulai

## 🔧 Testing Setup

### 1. Test Local Development
```bash
# Install dependencies
flutter pub get

# Test device detection
flutter run --dart-define=DEVICE_PERFORMANCE=low
flutter run --dart-define=DEVICE_PERFORMANCE=medium
flutter run --dart-define=DEVICE_PERFORMANCE=high
```

### 2. Test Web Download Page
```bash
# Build web version
flutter build web --release

# Serve locally
cd build/web
python -m http.server 8080
# Buka http://localhost:8080/download.html
```

### 3. Test Release Process
```bash
# Create test release
git tag v1.0.0-test
git push origin v1.0.0-test

# Check GitHub Actions progress
# Verify release creation
# Test download links
```

## 📊 Monitoring & Analytics

### GitHub Actions Metrics
- Build success rate
- Download counts per version
- Device distribution (jika diimplementasikan)

### Download Tracking (Optional)
Tambahkan Google Analytics atau tracking script di `download.html`:

```html
<!-- Tambahkan di <head> -->
<script async src="https://www.googletagmanager.com/gtag/js?id=GA_MEASUREMENT_ID"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', 'GA_MEASUREMENT_ID');
</script>
```

## 🐛 Troubleshooting

### Common Issues

#### 1. GitHub Pages tidak muncul
- Pastikan GitHub Pages enabled di Settings
- Tunggu 5-10 menit setelah first deployment
- Check Actions tab untuk error logs

#### 2. Download links tidak berfungsi
- Verify repository name di semua file
- Check release assets ter-upload dengan benar
- Pastikan file names sesuai dengan workflow

#### 3. Device detection tidak akurat
- Test di berbagai device Android
- Update detection logic di `download.html`
- Consider adding more device metrics

#### 4. Build failures
- Check Flutter version compatibility
- Verify dependencies di `pubspec.yaml`
- Review error logs di Actions tab

### Debug Mode

Enable debug mode dengan menambahkan parameter:

```javascript
// Di download.html
const DEBUG_MODE = true; // Set ke true untuk debugging

// Akan menampilkan console logs dan device info
```

## 🔄 Maintenance

### Regular Tasks
1. **Monthly**: Check download statistics
2. **Quarterly**: Update device detection logic
3. **Bi-annually**: Review and optimize APK sizes
4. **Annually**: Update Flutter version and dependencies

### Update Process
1. Update code di `main` branch
2. Test dengan development build
3. Create new release tag
4. Verify auto-download functionality
5. Monitor initial downloads

## 📞 Support

Jika mengalami masalah dengan setup:

1. **GitHub Issues**: Create issue di repository
2. **Documentation**: Check `README.md` dan `docs/` folder
3. **Examples**: Lihat release examples di repository

---

**Setup complete! 🎉** 

Sistem auto-download Anda sekarang siap digunakan. User dapat dengan mudah download APK yang optimal untuk device mereka secara otomatis.
