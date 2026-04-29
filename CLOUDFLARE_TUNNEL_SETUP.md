# Setup Cloudflare Tunnel Permanen - SIMANIS

## Ringkasan
Panduan ini menjelaskan cara setup **Cloudflare Tunnel permanen** untuk menghubungkan aplikasi Flutter SIMANIS dengan backend Node.js via domain `https://api.sinan.my.id`.

---

## 1. Prasyarat

### Software yang Harus Terinstall
- **Cloudflared** (CLI tool)
  ```cmd
  winget install --id Cloudflare.cloudflared
  ```
  Atau download manual: https://github.com/cloudflare/cloudflared/releases

- **Domain** di Cloudflare
  - Domain `sinan.my.id` sudah terdaftar
  - Nameserver diarahkan ke Cloudflare

- **Backend** berjalan di `localhost:3000`

---

## 2. Quick Start (Setup Cepat)

### Langkah 1: Login ke Cloudflare
```cmd
cloudflared tunnel login
```
- Browser akan terbuka
- Pilih domain `sinan.my.id`
- Authorize akses

### Langkah 2: Buat Tunnel
```cmd
cloudflared tunnel create SIMANIS
```
Catat **Tunnel ID** yang muncul (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)

### Langkah 3: Setup DNS Route
```cmd
cloudflared tunnel route dns SIMANIS api.sinan.my.id
```

### Langkah 4: Jalankan Tunnel
```cmd
cloudflared tunnel --config cloudflare/config.yml run SIMANIS
```

Atau gunakan batch file: **double-click `setup-permanent-tunnel.bat`**

---

## 3. Install sebagai Windows Service (Auto-Start)

### 3.1 Jalankan sebagai Administrator
```cmd
:: Klik kanan Command Prompt -> Run as Administrator
:: Atau PowerShell (Admin)
```

### 3.2 Install Service
```cmd
cloudflared service install
```

### 3.3 Configure & Start
```cmd
:: Start service
net start cloudflared

:: Set auto-start
sc config cloudflared start= auto
```

### 3.4 Verifikasi
```cmd
:: Cek status
sc query cloudflared

:: Lihat service
services.msc
```

---

## 4. Struktur File

```
siakad_login1/
├── cloudflare/
│   └── config.yml          # Konfigurasi tunnel
├── backend/
│   └── server.js           # CORS & security headers updated
├── lib/
│   └── config/
│       └── api_config.dart  # Base URL updated
├── setup-permanent-tunnel.bat    # Setup wizard
└── CLOUDFLARE_TUNNEL_SETUP.md   # Dokumentasi ini
```

---

## 5. Troubleshooting

### 5.1 CORS Errors

**Error:**
```
Access to XMLHttpRequest at 'https://api.sinan.my.id/api/auth/login'
from origin 'null' has been blocked by CORS policy
```

**Solusi:**
1. Verifikasi `origin` di `server.js` mencakup domain Flutter:
   ```javascript
   const allowedOrigins = [
     'https://api.sinan.my.id',
     // Tambahkan jika perlu:
     'capacitor://localhost',      // Ionic/Capacitor
     'ionic://localhost',
     'http://localhost',
   ];
   ```

2. Pastikan server restart setelah edit

3. Check debug endpoint:
   ```
   https://api.sinan.my.id/debug
   ```

### 5.2 SSL/Certificate Errors

**Error:**
```
HandshakeException: Handshake error in client
CERTIFICATE_VERIFY_FAILED
```

**Solusi:**
Cloudflare Tunnel menggunakan certificate valid, **jangan** disable certificate validation. Jika error:

1. Pastikan domain benar: `https://api.sinan.my.id`
2. Cek DNS propagation:
   ```cmd
   nslookup api.sinan.my.id
   ```
3. Verifikasi tunnel berjalan:
   ```cmd
   cloudflared tunnel list
   ```

### 5.3 Tunnel Tidak Connect

**Error:**
```
ERR Connection refused
```

**Checklist:**
- [ ] Backend berjalan di `localhost:3000`
- [ ] Tunnel ID di `config.yml` benar
- [ ] Credentials file ada di `%USERPROFILE%\.cloudflared\`
- [ ] Tidak ada firewall block port 3000

**Perintah diagnostic:**
```cmd
:: Cek tunnel status
cloudflared tunnel list

:: Cek log
type cloudflared.log

:: Test local backend
curl http://localhost:3000/health

:: Test via tunnel
curl https://api.sinan.my.id/health
```

### 5.4 JWT Auth Failures setelah HTTPS

JWT tidak terpengaruh oleh HTTPS/HTTP. Jika auth gagal:

1. Pastikan `JWT_SECRET` di `.env` sama
2. Check token format di Flutter:
   ```dart
   headersWithAuth(token) => {
     'Authorization': 'Bearer $token',
   }
   ```
3. Verifikasi endpoint verify:
   ```
   GET https://api.sinan.my.id/api/auth/verify
   Headers: Authorization: Bearer <token>
   ```

### 5.5 Service Tidak Auto-Start

**Check:**
```cmd
:: Cek status service
sc query cloudflared

:: Restart manual
net stop cloudflared
net start cloudflared

:: Enable auto-start
sc config cloudflared start= auto
```

---

## 6. FAQ

### Q: Apakah perlu konfigurasi SSL di Node.js?
**A:** Tidak. Cloudflare Tunnel menangani SSL termination. Node.js tetap HTTP di localhost.

### Q: Bagaimana cara tunnel otomatis berjalan saat restart?
**A:** Install sebagai Windows Service (lihat section 3) atau gunakan Task Scheduler.

### Q: Apakah perlu setting khusus di Flutter untuk HTTPS?
**A:** Tidak. Cloudflare certificate valid, Flutter akan trust otomatis. Tidak perlu `badCertificateCallback`.

### Q: Bagaimana update tunnel config?
**A:** Edit `cloudflare/config.yml`, kemudian restart service:
```cmd
net stop cloudflared
net start cloudflared
```

### Q: Bisa pakai multiple subdomain?
**A:** Ya. Edit `config.yml`:
```yaml
ingress:
  - hostname: api.sinan.my.id
    service: http://localhost:3000
  - hostname: app.sinan.my.id
    service: http://localhost:8080
```

---

## 7. Perintah Berguna

```cmd
# List tunnels
cloudflared tunnel list

# Info tunnel
cloudflared tunnel info SIMANIS

# Delete tunnel
cloudflared tunnel delete SIMANIS

# Update tunnel
cloudflared tunnel update SIMANIS

# Check credentials
cloudflared tunnel token SIMANIS

# Run dengan verbose logging
cloudflared tunnel --loglevel debug run SIMANIS
```

---

## 8. Testing Checklist

Setelah setup, verifikasi dengan:

- [ ] `curl https://api.sinan.my.id/health` -> 200 OK
- [ ] Login dari Flutter berhasil
- [ ] JWT token verify berhasil
- [ ] Semua API endpoints responsif
- [ ] Service auto-start setelah reboot

---

## 9. Kontak & Support

- **Cloudflare Docs:** https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/
- **Tunnel Issues:** https://github.com/cloudflare/cloudflared/issues
