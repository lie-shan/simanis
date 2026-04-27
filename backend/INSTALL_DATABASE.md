# Cara Install Database SIAKAD

Ada beberapa cara untuk mengimport database schema ke MySQL di Windows:

## Cara 1: Menggunakan phpMyAdmin (Paling Mudah)

1. Buka phpMyAdmin di browser (biasanya `http://localhost/phpmyadmin`)
2. Login dengan username dan password MySQL Anda
3. Klik tab "SQL" di menu atas
4. Klik tombol "Choose File" atau "Browse"
5. Pilih file `backend/database/schema.sql`
6. Klik tombol "Go" atau "Kirim"
7. Database `siakad_db` akan otomatis dibuat beserta semua tabelnya

## Cara 2: Menggunakan MySQL Workbench

1. Buka MySQL Workbench
2. Connect ke MySQL server Anda
3. Klik menu "File" → "Open SQL Script"
4. Pilih file `backend/database/schema.sql`
5. Klik icon "Execute" (petir) atau tekan Ctrl+Shift+Enter
6. Database akan dibuat otomatis

## Cara 3: Menggunakan Command Prompt (CMD)

1. Buka Command Prompt (CMD), bukan PowerShell
2. Masuk ke folder project:
   ```cmd
   cd D:\Projects\siakad_login
   ```

3. Jalankan command:
   ```cmd
   mysql -u root -p < backend\database\schema.sql
   ```

4. Masukkan password MySQL Anda ketika diminta

**Catatan:** Jika command `mysql` tidak ditemukan, tambahkan MySQL ke PATH atau gunakan full path:
```cmd
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -p < backend\database\schema.sql
```

## Cara 4: Manual Copy-Paste

1. Buka file `backend/database/schema.sql` dengan text editor
2. Copy semua isinya (Ctrl+A, Ctrl+C)
3. Buka phpMyAdmin atau MySQL Workbench
4. Paste di tab SQL
5. Execute/Run

## Verifikasi Database Berhasil Dibuat

Setelah import, cek apakah database berhasil dibuat:

### Via phpMyAdmin:
1. Refresh halaman
2. Lihat di sidebar kiri, seharusnya ada database `siakad_db`
3. Klik database tersebut
4. Seharusnya ada 10 tabel:
   - users
   - siswa
   - guru
   - kelas
   - mata_pelajaran
   - jadwal
   - nilai
   - presensi
   - pengumuman
   - pembayaran

### Via MySQL Command:
```sql
SHOW DATABASES;
USE siakad_db;
SHOW TABLES;
```

## Troubleshooting

### Error: Access denied
- Pastikan username dan password MySQL benar
- Default username biasanya `root`
- Jika menggunakan XAMPP, password default kosong

### Error: Database already exists
- Database sudah ada, Anda bisa:
  1. Drop database dulu: `DROP DATABASE siakad_db;`
  2. Atau skip error dan lanjutkan

### Error: Table already exists
- Tabel sudah ada, Anda bisa:
  1. Drop semua tabel dulu
  2. Atau drop database dan buat ulang

## Default Data

Setelah import berhasil, Anda akan memiliki:

**Default Admin User:**
- Email: admin@siakad.com
- Password: admin123

**Sample Data:**
- 5 Mata Pelajaran
- 6 Kelas (VII-A, VII-B, VIII-A, VIII-B, IX-A, IX-B)

## Langkah Selanjutnya

Setelah database berhasil dibuat:

1. Edit file `backend/.env`:
   ```env
   DB_HOST=localhost
   DB_USER=root
   DB_PASSWORD=your_password_here
   DB_NAME=siakad_db
   DB_PORT=3306
   ```

2. Install dependencies backend:
   ```bash
   cd backend
   npm install
   ```

3. Jalankan server:
   ```bash
   npm run dev
   ```

4. Test di browser: `http://localhost:3000`

Jika ada pertanyaan, silakan hubungi tim development.
