# 🚀 Quick Start Guide - SIAKAD Backend

Panduan cepat untuk menjalankan backend SIAKAD.

## 📋 Langkah-langkah

### 1. Install Database

**Cara Termudah - Menggunakan phpMyAdmin:**

1. Buka phpMyAdmin: `http://localhost/phpmyadmin`
2. Klik tab **"SQL"**
3. Klik **"Choose File"**
4. Pilih file: `backend/database/schema.sql`
5. Klik **"Go"**
6. ✅ Selesai! Database `siakad_db` sudah dibuat

**Alternatif lain:** Lihat file `backend/INSTALL_DATABASE.md`

### 2. Install Dependencies Backend

```bash
cd backend
npm install
```

Tunggu sampai selesai (sekitar 1-2 menit).

### 3. Konfigurasi Database

File `backend/.env` sudah dibuat. Edit jika perlu:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=           # Isi password MySQL Anda (kosongkan jika tidak ada)
DB_NAME=siakad_db
DB_PORT=3306
```

### 4. Jalankan Backend Server

```bash
npm run dev
```

Anda akan melihat:
```
🚀 Server running on http://localhost:3000
📝 Environment: development
✅ Database connected successfully
```

### 5. Test Backend

Buka browser: `http://localhost:3000`

Anda akan melihat:
```json
{
  "message": "SIAKAD API Server",
  "version": "1.0.0",
  "status": "running"
}
```

### 6. Test Login API

Gunakan Postman atau Thunder Client (VS Code extension):

**Request:**
- Method: `POST`
- URL: `http://localhost:3000/api/auth/login`
- Headers: `Content-Type: application/json`
- Body (raw JSON):
```json
{
  "email": "admin@siakad.com",
  "password": "admin123"
}
```

**Response (jika berhasil):**
```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "user": {
      "id": 1,
      "nama": "Administrator",
      "email": "admin@siakad.com",
      "role": "admin"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

## 🎯 Integrasi dengan Flutter

Setelah backend berjalan, ikuti panduan di `INTEGRATION_GUIDE.md` untuk:
1. Menambahkan dependencies Flutter
2. Membuat service layer
3. Mengintegrasikan dengan UI

## 📝 Default Login

```
Email: admin@siakad.com
Password: admin123
```

## 🔧 Troubleshooting

### Backend tidak bisa connect ke database

**Error:** `❌ Error connecting to database`

**Solusi:**
1. Pastikan MySQL sudah running (XAMPP/WAMP/MAMP)
2. Cek username dan password di file `.env`
3. Pastikan database `siakad_db` sudah dibuat

### Port 3000 sudah digunakan

**Error:** `Port 3000 is already in use`

**Solusi:**
1. Matikan aplikasi yang menggunakan port 3000
2. Atau ganti port di file `.env`:
   ```env
   PORT=3001
   ```

### npm install error

**Solusi:**
1. Pastikan Node.js sudah terinstall: `node --version`
2. Jika belum, download dari: https://nodejs.org/
3. Restart terminal setelah install Node.js

## 📚 Dokumentasi Lengkap

- **Backend API:** `backend/README.md`
- **Install Database:** `backend/INSTALL_DATABASE.md`
- **Integrasi Flutter:** `INTEGRATION_GUIDE.md`

## 🆘 Butuh Bantuan?

Jika ada masalah, cek file dokumentasi di atas atau hubungi tim development.

---

**Selamat mencoba! 🎉**
