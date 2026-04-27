# SIAKAD Backend API

Backend API untuk Aplikasi SIAKAD menggunakan Node.js, Express, dan MySQL.

## 📋 Prerequisites

- Node.js (v14 atau lebih baru)
- MySQL (v5.7 atau lebih baru)
- npm atau yarn

## 🚀 Instalasi

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Setup Database

1. Buat database MySQL:
```bash
mysql -u root -p
```

2. Import schema database:
```bash
mysql -u root -p < database/schema.sql
```

Atau jalankan file `database/schema.sql` melalui phpMyAdmin atau MySQL Workbench.

### 3. Konfigurasi Environment

1. Copy file `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```

2. Edit file `.env` sesuai konfigurasi database Anda:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=siakad_db
DB_PORT=3306

PORT=3000
JWT_SECRET=your_secret_key_here
NODE_ENV=development
```

### 4. Jalankan Server

Development mode (dengan auto-reload):
```bash
npm run dev
```

Production mode:
```bash
npm start
```

Server akan berjalan di `http://localhost:3000`

## 📚 API Endpoints

### Authentication
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `POST /api/auth/forgot-password` - Lupa password (kirim via WhatsApp)
- `POST /api/auth/reset-password` - Reset password
- `GET /api/auth/verify` - Verify token

### Users (Data Pengguna)
- `GET /api/users` - Get all users
- `GET /api/users/:id` - Get user by ID
- `POST /api/users` - Create user
- `PUT /api/users/:id` - Update user
- `DELETE /api/users/:id` - Delete user

### Nilai
- `GET /api/nilai` - Get all nilai
- `GET /api/nilai/siswa/:siswa_id` - Get nilai by siswa
- `GET /api/nilai/mapel/:mapel_id` - Get nilai by mapel
- `GET /api/nilai/kelas/:kelas_id` - Get nilai by kelas
- `POST /api/nilai` - Create nilai
- `PUT /api/nilai/:id` - Update nilai
- `DELETE /api/nilai/:id` - Delete nilai

## 🔐 Authentication

Semua endpoint (kecuali login dan forgot-password) memerlukan token JWT.

Cara menggunakan:
1. Login untuk mendapatkan token
2. Sertakan token di header setiap request:
```
Authorization: Bearer <your_token>
```

## 📝 Default Login

```
Email: admin@siakad.com
Password: admin123
```

## 🗄️ Database Schema

Database terdiri dari tabel-tabel berikut:
- `users` - Data pengguna (login)
- `siswa` - Data siswa
- `guru` - Data guru
- `kelas` - Data kelas
- `mata_pelajaran` - Data mata pelajaran
- `jadwal` - Jadwal pelajaran
- `nilai` - Data nilai siswa
- `presensi` - Data presensi siswa
- `pengumuman` - Data pengumuman
- `pembayaran` - Data pembayaran
