-- ============================================
-- SIAKAD Database Schema
-- ============================================

-- Create Database
CREATE DATABASE IF NOT EXISTS siakad_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE siakad_db;

-- ============================================
-- Table: users (Data Pengguna)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  no_whatsapp VARCHAR(20),
  role ENUM('siswa', 'guru', 'admin', 'bendahara') NOT NULL,
  status ENUM('aktif', 'nonaktif') DEFAULT 'aktif',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_email (email),
  INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: guru (Data Guru)
-- ============================================
CREATE TABLE IF NOT EXISTS guru (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  nama VARCHAR(100) NOT NULL,
  jenis_kelamin ENUM('L', 'P') NOT NULL,
  alamat TEXT,
  no_hp VARCHAR(20),
  foto_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: kelas (Data Kelas)
-- ============================================
CREATE TABLE IF NOT EXISTS kelas (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama_kelas VARCHAR(20) NOT NULL,
  tingkat VARCHAR(10),
  wali_kelas_id INT,
  tahun_ajaran VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (wali_kelas_id) REFERENCES guru(id) ON DELETE SET NULL,
  INDEX idx_nama_kelas (nama_kelas)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: siswa (Data Siswa)
-- ============================================
CREATE TABLE IF NOT EXISTS siswa (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT,
  nis VARCHAR(20) UNIQUE NOT NULL,
  nama VARCHAR(100) NOT NULL,
  jenis_kelamin ENUM('L', 'P') NOT NULL,
  tempat_lahir VARCHAR(50),
  tanggal_lahir DATE,
  alamat TEXT,
  kelas_id INT,
  tahun_masuk YEAR,
  nama_ayah VARCHAR(100),
  nama_ibu VARCHAR(100),
  no_hp_ortu VARCHAR(20),
  foto_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE SET NULL,
  INDEX idx_nis (nis),
  INDEX idx_kelas (kelas_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: mata_pelajaran (Data Mata Pelajaran)
-- ============================================
CREATE TABLE IF NOT EXISTS mata_pelajaran (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kode_mapel VARCHAR(20) UNIQUE NOT NULL,
  nama_mapel VARCHAR(100) NOT NULL,
  deskripsi TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_kode_mapel (kode_mapel)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: jadwal (Jadwal Pelajaran)
-- ============================================
CREATE TABLE IF NOT EXISTS jadwal (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kelas_id INT NOT NULL,
  mapel_id INT NOT NULL,
  guru_id INT NOT NULL,
  hari ENUM('Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu') NOT NULL,
  jam_mulai TIME NOT NULL,
  jam_selesai TIME NOT NULL,
  ruangan VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE CASCADE,
  FOREIGN KEY (mapel_id) REFERENCES mata_pelajaran(id) ON DELETE CASCADE,
  FOREIGN KEY (guru_id) REFERENCES guru(id) ON DELETE CASCADE,
  INDEX idx_kelas_hari (kelas_id, hari)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: nilai (Data Nilai)
-- ============================================
CREATE TABLE IF NOT EXISTS nilai (
  id INT AUTO_INCREMENT PRIMARY KEY,
  siswa_id INT NOT NULL,
  mapel_id INT NOT NULL,
  kelas_id INT NOT NULL,
  guru_id INT,
  semester ENUM('1', '2') NOT NULL,
  tahun_ajaran VARCHAR(20) NOT NULL,
  nilai_harian DECIMAL(5,2) DEFAULT 0,
  nilai_uts DECIMAL(5,2) DEFAULT 0,
  nilai_uas DECIMAL(5,2) DEFAULT 0,
  nilai_akhir DECIMAL(5,2) GENERATED ALWAYS AS ((nilai_harian * 0.4) + (nilai_uts * 0.3) + (nilai_uas * 0.3)) STORED,
  grade VARCHAR(2) GENERATED ALWAYS AS (
    CASE
      WHEN ((nilai_harian * 0.4) + (nilai_uts * 0.3) + (nilai_uas * 0.3)) >= 90 THEN 'A'
      WHEN ((nilai_harian * 0.4) + (nilai_uts * 0.3) + (nilai_uas * 0.3)) >= 80 THEN 'B'
      WHEN ((nilai_harian * 0.4) + (nilai_uts * 0.3) + (nilai_uas * 0.3)) >= 70 THEN 'C'
      WHEN ((nilai_harian * 0.4) + (nilai_uts * 0.3) + (nilai_uas * 0.3)) >= 60 THEN 'D'
      ELSE 'E'
    END
  ) STORED,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (siswa_id) REFERENCES siswa(id) ON DELETE CASCADE,
  FOREIGN KEY (mapel_id) REFERENCES mata_pelajaran(id) ON DELETE CASCADE,
  FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE CASCADE,
  FOREIGN KEY (guru_id) REFERENCES guru(id) ON DELETE SET NULL,
  UNIQUE KEY unique_nilai (siswa_id, mapel_id, semester, tahun_ajaran),
  INDEX idx_siswa_mapel (siswa_id, mapel_id),
  INDEX idx_guru (guru_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: presensi (Data Presensi)
-- ============================================
CREATE TABLE IF NOT EXISTS presensi (
  id INT AUTO_INCREMENT PRIMARY KEY,
  siswa_id INT NOT NULL,
  tanggal DATE NOT NULL,
  status ENUM('hadir', 'izin', 'sakit', 'alpha') NOT NULL,
  keterangan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (siswa_id) REFERENCES siswa(id) ON DELETE CASCADE,
  UNIQUE KEY unique_presensi (siswa_id, tanggal),
  INDEX idx_tanggal (tanggal)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: pengumuman (Data Pengumuman)
-- ============================================
CREATE TABLE IF NOT EXISTS pengumuman (
  id INT AUTO_INCREMENT PRIMARY KEY,
  judul VARCHAR(200) NOT NULL,
  isi TEXT NOT NULL,
  kategori ENUM('umum', 'akademik', 'kegiatan', 'penting') DEFAULT 'umum',
  tanggal_mulai DATE,
  tanggal_selesai DATE,
  dibuat_oleh INT,
  status ENUM('draft', 'published') DEFAULT 'published',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (dibuat_oleh) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_kategori (kategori),
  INDEX idx_tanggal (tanggal_mulai, tanggal_selesai)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Table: pembayaran (Data Pembayaran)
-- ============================================
CREATE TABLE IF NOT EXISTS pembayaran (
  id INT AUTO_INCREMENT PRIMARY KEY,
  kode_transaksi VARCHAR(50) UNIQUE,
  siswa_id INT NOT NULL,
  jenis_pembayaran VARCHAR(100) NOT NULL,
  jumlah DECIMAL(15,2) NOT NULL,
  tanggal_jatuh_tempo DATE,
  tanggal_bayar DATE,
  status ENUM('belum_bayar', 'lunas', 'terlambat') DEFAULT 'belum_bayar',
  metode_pembayaran VARCHAR(50),
  bukti_pembayaran VARCHAR(255),
  keterangan TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (siswa_id) REFERENCES siswa(id) ON DELETE CASCADE,
  INDEX idx_siswa_status (siswa_id, status),
  INDEX idx_tanggal (tanggal_jatuh_tempo),
  INDEX idx_kode_transaksi (kode_transaksi)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Insert Complete Sample Data
-- ============================================

-- Password hash: admin123 (bcrypt)
SET @password_hash = '$2a$10$dNET3fmlwVjmU1mfo9ygkuzNsFx.qVBUMSnQPDDB8l4y14KUHDJqO';

-- ============================================
-- 1. Users (Admin, Guru, Bendahara)
-- ============================================
INSERT INTO users (nama, email, password, role, no_whatsapp, status) VALUES
('Administrator', 'admin@siakad.com', @password_hash, 'admin', '081234567890', 'aktif'),
('Budi Santoso, S.Pd', 'budi.santoso@siakad.com', @password_hash, 'guru', '081234567891', 'aktif'),
('Siti Aminah, M.Pd', 'siti.aminah@siakad.com', @password_hash, 'guru', '081234567892', 'aktif'),
('Ahmad Yani, S.Pd.I', 'ahmad.yani@siakad.com', @password_hash, 'guru', '081234567893', 'aktif'),
('Dewi Kusuma, S.Si', 'dewi.kusuma@siakad.com', @password_hash, 'guru', '081234567894', 'aktif'),
('Rini Susanti, S.Pd', 'rini.susanti@siakad.com', @password_hash, 'guru', '081234567895', 'aktif'),
('Agus Salim, S.Kom', 'agus.salim@siakad.com', @password_hash, 'guru', '081234567896', 'aktif'),
('Maya Sari, S.Pd', 'maya.sari@siakad.com', @password_hash, 'bendahara', '081234567897', 'aktif');

-- ============================================
-- 2. Guru
-- ============================================
INSERT INTO guru (user_id, nama, jenis_kelamin, alamat, no_hp) VALUES
(2, 'Budi Santoso, S.Pd', 'L', 'Jl. Merdeka No. 1, Jakarta', '081234567891'),
(3, 'Siti Aminah, M.Pd', 'P', 'Jl. Sudirman No. 5, Bandung', '081234567892'),
(4, 'Ahmad Yani, S.Pd.I', 'L', 'Jl. Ahmad Yani No. 10, Surabaya', '081234567893'),
(5, 'Dewi Kusuma, S.Si', 'P', 'Jl. Malioboro No. 15, Yogyakarta', '081234567894'),
(6, 'Rini Susanti, S.Pd', 'P', 'Jl. Pemuda No. 20, Semarang', '081234567895'),
(7, 'Agus Salim, S.Kom', 'L', 'Jl. Gatot Subroto No. 25, Medan', '081234567896');

-- ============================================
-- 3. Kelas
-- ============================================
INSERT INTO kelas (nama_kelas, tingkat, wali_kelas_id, tahun_ajaran) VALUES
('X IPA 1', '10', 2, '2024/2025'),
('X IPA 2', '10', 3, '2024/2025'),
('X IPS 1', '10', 4, '2024/2025'),
('XI IPA 1', '11', 2, '2024/2025'),
('XI IPA 2', '11', 5, '2024/2025'),
('XI IPS 1', '11', 6, '2024/2025'),
('XII IPA 1', '12', 2, '2024/2025'),
('XII IPS 1', '12', 3, '2024/2025');

-- ============================================
-- 4. Mata Pelajaran
-- ============================================
INSERT INTO mata_pelajaran (kode_mapel, nama_mapel, deskripsi) VALUES
('MTK', 'Matematika', 'Pelajaran matematika dasar dan lanjutan'),
('BIND', 'Bahasa Indonesia', 'Bahasa Indonesia'),
('BING', 'Bahasa Inggris', 'Bahasa Inggris'),
('PAI', 'Pendidikan Agama Islam', 'Agama Islam'),
('PBO', 'Pendidikan Agama Kristen', 'Agama Kristen'),
('PKN', 'Pendidikan Kewarganegaraan', 'Kewarganegaraan'),
('FIS', 'Fisika', 'Ilmu fisika'),
('KIM', 'Kimia', 'Ilmu kimia'),
('BIO', 'Biologi', 'Ilmu biologi'),
('GEO', 'Geografi', 'Ilmu geografi'),
('EKO', 'Ekonomi', 'Ilmu ekonomi'),
('SOS', 'Sosiologi', 'Ilmu sosiologi'),
('SEJ', 'Sejarah', 'Ilmu sejarah'),
('SBD', 'Seni Budaya', 'Seni dan budaya'),
('PJOK', 'Pendidikan Jasmani', 'Olahraga dan kesehatan'),
('INF', 'Informatika', 'Komputer dan pemrograman');

-- ============================================
-- 5. Siswa
-- ============================================
INSERT INTO siswa (user_id, nis, nama, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, kelas_id, tahun_masuk, nama_ayah, nama_ibu, no_hp_ortu) VALUES
-- Kelas X IPA 1
(NULL, '20240001', 'Ahmad Fauzi', 'L', 'Jakarta', '2008-05-15', 'Jl. Mawar No. 1, Jakarta', 1, 2024, 'Bapak Fauzi', 'Ibu Fauzi', '081300000001'),
(NULL, '20240002', 'Bella Safitri', 'P', 'Bandung', '2008-08-20', 'Jl. Melati No. 2, Bandung', 1, 2024, 'Bapak Safitri', 'Ibu Safitri', '081300000002'),
(NULL, '20240003', 'Candra Wijaya', 'L', 'Surabaya', '2008-03-10', 'Jl. Anggrek No. 3, Surabaya', 1, 2024, 'Bapak Wijaya', 'Ibu Wijaya', '081300000003'),
(NULL, '20240004', 'Diana Putri', 'P', 'Yogyakarta', '2008-11-25', 'Jl. Kenanga No. 4, Yogyakarta', 1, 2024, 'Bapak Putri', 'Ibu Putri', '081300000004'),
-- Kelas X IPA 2
(NULL, '20240005', 'Eko Prasetyo', 'L', 'Semarang', '2008-07-12', 'Jl. Cempaka No. 5, Semarang', 2, 2024, 'Bapak Prasetyo', 'Ibu Prasetyo', '081300000005'),
(NULL, '20240006', 'Fani Indah', 'P', 'Medan', '2008-09-18', 'Jl. Flamboyan No. 6, Medan', 2, 2024, 'Bapak Indah', 'Ibu Indah', '081300000006'),
(NULL, '20240007', 'Gilang Ramadhan', 'L', 'Makassar', '2008-01-30', 'Jl. Bougenville No. 7, Makassar', 2, 2024, 'Bapak Ramadhan', 'Ibu Ramadhan', '081300000007'),
-- Kelas X IPS 1
(NULL, '20240008', 'Hani Nurfadillah', 'P', 'Palembang', '2008-06-22', 'Jl. Dahlia No. 8, Palembang', 3, 2024, 'Bapak Nurfadillah', 'Ibu Nurfadillah', '081300000008'),
(NULL, '20240009', 'Indra Kusuma', 'L', 'Malang', '2008-04-14', 'Jl. Tulip No. 9, Malang', 3, 2024, 'Bapak Kusuma', 'Ibu Kusuma', '081300000009'),
(NULL, '20240010', 'Jasmine Aulia', 'P', 'Bogor', '2008-12-05', 'Jl. Lavender No. 10, Bogor', 3, 2024, 'Bapak Aulia', 'Ibu Aulia', '081300000010'),
-- Kelas XI IPA 1
(NULL, '20230001', 'Kevin Sanjaya', 'L', 'Jakarta', '2007-02-28', 'Jl. Sakura No. 11, Jakarta', 4, 2023, 'Bapak Sanjaya', 'Ibu Sanjaya', '081300000011'),
(NULL, '20230002', 'Larasati Dewi', 'P', 'Bandung', '2007-07-19', 'Jl. Kamboja No. 12, Bandung', 4, 2023, 'Bapak Dewi', 'Ibu Dewi', '081300000012'),
(NULL, '20230003', 'Mario Pratama', 'L', 'Surabaya', '2007-10-03', 'Jl. Teratai No. 13, Surabaya', 4, 2023, 'Bapak Pratama', 'Ibu Pratama', '081300000013'),
-- Kelas XI IPA 2
(NULL, '20230004', 'Nadia Fitriani', 'P', 'Yogyakarta', '2007-09-11', 'Jl. Lotus No. 14, Yogyakarta', 5, 2023, 'Bapak Fitriani', 'Ibu Fitriani', '081300000014'),
(NULL, '20230005', 'Oscar Widodo', 'L', 'Semarang', '2007-05-27', 'Jl. Iris No. 15, Semarang', 5, 2023, 'Bapak Widodo', 'Ibu Widodo', '081300000015'),
-- Kelas XII IPA 1
(NULL, '20220001', 'Putri Handayani', 'P', 'Medan', '2006-08-16', 'Jl. Orchid No. 16, Medan', 7, 2022, 'Bapak Handayani', 'Ibu Handayani', '081300000016'),
(NULL, '20220002', 'Rizky Pratama', 'L', 'Makassar', '2006-03-08', 'Jl. Jasmine No. 17, Makassar', 7, 2022, 'Bapak Pratama', 'Ibu Pratama', '081300000017');

-- ============================================
-- 6. Jadwal Pelajaran
-- ============================================
-- Note: guru_id = ID auto-increment guru table (1-6), NOT user_id
-- Mapping: Budi=1, Siti=2, Ahmad=3, Dewi=4, Rini=5, Agus=6
INSERT INTO jadwal (kelas_id, mapel_id, guru_id, hari, jam_mulai, jam_selesai, ruangan) VALUES
-- Senin
(1, 1, 1, 'Senin', '07:00:00', '08:30:00', 'R101'), -- X IPA 1 - MTK (Budi)
(1, 2, 2, 'Senin', '08:45:00', '10:15:00', 'R101'), -- X IPA 1 - B.Ind (Siti)
(1, 4, 3, 'Senin', '10:30:00', '12:00:00', 'R101'), -- X IPA 1 - PAI (Ahmad)
(2, 1, 1, 'Senin', '07:00:00', '08:30:00', 'R102'), -- X IPA 2 - MTK (Budi)
(4, 1, 1, 'Senin', '07:00:00', '08:30:00', 'R201'), -- XI IPA 1 - MTK (Budi)
-- Selasa
(1, 5, 4, 'Selasa', '07:00:00', '08:30:00', 'R101'), -- X IPA 1 - BIO (Dewi)
(1, 3, 5, 'Selasa', '08:45:00', '10:15:00', 'R101'), -- X IPA 1 - B.Ing (Rini)
(2, 5, 4, 'Selasa', '07:00:00', '08:30:00', 'R102'), -- X IPA 2 - BIO (Dewi)
-- Rabu
(1, 7, 3, 'Rabu', '07:00:00', '08:30:00', 'R101'), -- X IPA 1 - PKN (Ahmad)
(1, 3, 5, 'Rabu', '08:45:00', '10:15:00', 'R101'), -- X IPA 1 - B.Ing (Rini)
-- Kamis
(1, 16, 6, 'Kamis', '07:00:00', '08:30:00', 'Lab Kom'), -- X IPA 1 - INF (Agus)
(1, 15, 1, 'Kamis', '08:45:00', '10:15:00', 'Lapangan'), -- X IPA 1 - PJOK (Budi)
-- Jumat
(1, 2, 2, 'Jumat', '07:00:00', '08:30:00', 'R101'), -- X IPA 1 - B.Ind (Siti)
(1, 4, 3, 'Jumat', '08:45:00', '10:15:00', 'R101'); -- X IPA 1 - PAI (Ahmad)

-- ============================================
-- 7. Nilai (Data Nilai Siswa)
-- ============================================
-- guru_id mapping: MTK=1(Budi), B.Ind=2(Siti), PAI=3(Ahmad), BIO=4(Dewi), B.Ing=5(Rini)
INSERT INTO nilai (siswa_id, mapel_id, kelas_id, guru_id, semester, tahun_ajaran, nilai_harian, nilai_uts, nilai_uas) VALUES
-- Siswa 1 (Ahmad Fauzi) - Kelas X IPA 1
(1, 1, 1, 1, '1', '2024/2025', 85, 78, 88), -- MTK (Budi)
(1, 2, 1, 2, '1', '2024/2025', 88, 85, 90), -- B.Ind (Siti)
(1, 4, 1, 3, '1', '2024/2025', 90, 88, 92), -- PAI (Ahmad)
(1, 5, 1, 4, '1', '2024/2025', 82, 75, 85), -- BIO (Dewi)
(1, 3, 1, 5, '1', '2024/2025', 78, 80, 82), -- B.Ing (Rini)
-- Siswa 2 (Bella Safitri) - Kelas X IPA 1
(2, 1, 1, 1, '1', '2024/2025', 92, 88, 95), -- MTK (Budi)
(2, 2, 1, 2, '1', '2024/2025', 90, 92, 88), -- B.Ind (Siti)
(2, 4, 1, 3, '1', '2024/2025', 88, 90, 92), -- PAI (Ahmad)
(2, 5, 1, 4, '1', '2024/2025', 85, 88, 90), -- BIO (Dewi)
(2, 3, 1, 5, '1', '2024/2025', 90, 85, 88), -- B.Ing (Rini)
-- Siswa 3 (Candra Wijaya) - Kelas X IPA 1
(3, 1, 1, 1, '1', '2024/2025', 75, 70, 78), -- MTK (Budi)
(3, 2, 1, 2, '1', '2024/2025', 80, 78, 82), -- B.Ind (Siti)
(3, 4, 1, 3, '1', '2024/2025', 85, 88, 90), -- PAI (Ahmad)
(3, 5, 1, 4, '1', '2024/2025', 78, 72, 80), -- BIO (Dewi)
(3, 3, 1, 5, '1', '2024/2025', 70, 75, 78), -- B.Ing (Rini)
-- Siswa 12 (Kevin Sanjaya) - Kelas XI IPA 1
(12, 1, 4, 1, '1', '2024/2025', 88, 85, 90), -- MTK (Budi)
(12, 2, 4, 2, '1', '2024/2025', 85, 88, 92), -- B.Ind (Siti)
(12, 5, 4, 4, '1', '2024/2025', 90, 88, 95), -- BIO (Dewi)
(12, 3, 4, 5, '1', '2024/2025', 82, 85, 88); -- B.Ing (Rini)

-- ============================================
-- 8. Presensi
-- ============================================
INSERT INTO presensi (siswa_id, tanggal, status, keterangan) VALUES
-- Oktober 2024
(1, '2024-10-01', 'hadir', NULL),
(1, '2024-10-02', 'hadir', NULL),
(1, '2024-10-03', 'izin', 'Sakit flu'),
(1, '2024-10-04', 'hadir', NULL),
(1, '2024-10-05', 'hadir', NULL),
(2, '2024-10-01', 'hadir', NULL),
(2, '2024-10-02', 'hadir', NULL),
(2, '2024-10-03', 'hadir', NULL),
(2, '2024-10-04', 'alpha', 'Tanpa keterangan'),
(2, '2024-10-05', 'hadir', NULL),
(3, '2024-10-01', 'hadir', NULL),
(3, '2024-10-02', 'sakit', 'Demam'),
(3, '2024-10-03', 'sakit', 'Demam'),
(3, '2024-10-04', 'hadir', NULL),
(3, '2024-10-05', 'hadir', NULL);

-- ============================================
-- 9. Pengumuman
-- ============================================
INSERT INTO pengumuman (judul, isi, kategori, tanggal_mulai, tanggal_selesai, dibuat_oleh, status) VALUES
('Jadwal UTS Semester 1', 'Ujian Tengah Semester akan dilaksanakan pada tanggal 16-20 Oktober 2024. Silakan persiapkan diri dengan baik.', 'akademik', '2024-10-01', '2024-10-20', 1, 'published'),
('Libur Nasional', 'Dalam rangka perayaan Hari Pahlawan, sekolah libur pada tanggal 10 November 2024.', 'umum', '2024-11-10', '2024-11-10', 1, 'published'),
('Pembayaran SPP', 'Pembayaran SPP bulan Oktober 2024 dapat dilakukan hingga tanggal 10 Oktober 2024.', 'penting', '2024-10-01', '2024-10-10', 8, 'published'),
('Kegiatan OSIS', 'Rapat koordinasi OSIS akan dilaksanakan pada hari Sabtu, 5 Oktober 2024 pukul 09.00 di Aula Sekolah.', 'kegiatan', '2024-10-05', '2024-10-05', 1, 'published'),
('Perubahan Jadwal', 'Mata pelajaran Matematika hari Senin dipindahkan ke hari Rabu untuk kelas X IPA 1.', 'akademik', '2024-10-07', '2024-10-07', 1, 'published');

-- ============================================
-- 10. Pembayaran
-- ============================================
INSERT INTO pembayaran (siswa_id, jenis_pembayaran, jumlah, tanggal_jatuh_tempo, tanggal_bayar, status, metode_pembayaran) VALUES
-- SPP Oktober 2024 (Lunas)
(1, 'SPP Oktober 2024', 500000, '2024-10-10', '2024-10-05', 'lunas', 'Transfer Bank'),
(2, 'SPP Oktober 2024', 500000, '2024-10-10', '2024-10-08', 'lunas', 'Tunai'),
(3, 'SPP Oktober 2024', 500000, '2024-10-10', NULL, 'belum_bayar', NULL),
(4, 'SPP Oktober 2024', 500000, '2024-10-10', '2024-10-03', 'lunas', 'Transfer Bank'),
(5, 'SPP Oktober 2024', 500000, '2024-10-10', '2024-10-09', 'lunas', 'Tunai'),
-- SPP November 2024
(1, 'SPP November 2024', 500000, '2024-11-10', NULL, 'belum_bayar', NULL),
(2, 'SPP November 2024', 500000, '2024-11-10', NULL, 'belum_bayar', NULL),
(3, 'SPP November 2024', 500000, '2024-11-10', NULL, 'belum_bayar', NULL),
-- Uang Pangkal (Lunas)
(1, 'Uang Pangkal', 2000000, '2024-07-15', '2024-07-10', 'lunas', 'Transfer Bank'),
(2, 'Uang Pangkal', 2000000, '2024-07-15', '2024-07-12', 'lunas', 'Transfer Bank'),
(3, 'Uang Pangkal', 2000000, '2024-07-15', NULL, 'belum_bayar', NULL),
-- Uang Kegiatan
(1, 'Uang Kegiatan Semester 1', 300000, '2024-08-01', '2024-07-28', 'lunas', 'Tunai'),
(2, 'Uang Kegiatan Semester 1', 300000, '2024-08-01', NULL, 'belum_bayar', NULL);

-- ============================================
-- Create Useful Views
-- ============================================

-- View: Rekap Nilai per Siswa
CREATE OR REPLACE VIEW v_rekap_nilai_siswa AS
SELECT
  s.id as siswa_id,
  s.nis,
  s.nama as nama_siswa,
  k.nama_kelas,
  n.semester,
  n.tahun_ajaran,
  COUNT(n.id) as total_mapel,
  AVG(n.nilai_akhir) as rata_rata,
  MAX(CASE WHEN n.grade = 'A' THEN 1 ELSE 0 END) as punya_a,
  SUM(CASE WHEN n.grade = 'E' THEN 1 ELSE 0 END) as total_e
FROM siswa s
JOIN nilai n ON s.id = n.siswa_id
JOIN kelas k ON n.kelas_id = k.id
GROUP BY s.id, s.nis, s.nama, k.nama_kelas, n.semester, n.tahun_ajaran;

-- View: Rekap Presensi per Siswa
CREATE OR REPLACE VIEW v_rekap_presensi_siswa AS
SELECT
  s.id as siswa_id,
  s.nis,
  s.nama as nama_siswa,
  k.nama_kelas,
  YEAR(p.tanggal) as tahun,
  MONTH(p.tanggal) as bulan,
  COUNT(*) as total_hari,
  SUM(CASE WHEN p.status = 'hadir' THEN 1 ELSE 0 END) as total_hadir,
  SUM(CASE WHEN p.status = 'izin' THEN 1 ELSE 0 END) as total_izin,
  SUM(CASE WHEN p.status = 'sakit' THEN 1 ELSE 0 END) as total_sakit,
  SUM(CASE WHEN p.status = 'alpha' THEN 1 ELSE 0 END) as total_alpha,
  ROUND(SUM(CASE WHEN p.status = 'hadir' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as persentase_hadir
FROM siswa s
JOIN presensi p ON s.id = p.siswa_id
LEFT JOIN kelas k ON s.kelas_id = k.id
GROUP BY s.id, s.nis, s.nama, k.nama_kelas, YEAR(p.tanggal), MONTH(p.tanggal);

-- View: Jadwal Mengajar Guru
CREATE OR REPLACE VIEW v_jadwal_mengajar AS
SELECT
  j.id,
  j.hari,
  j.jam_mulai,
  j.jam_selesai,
  j.ruangan,
  g.nama as nama_guru,
  g.nip as nip_guru,
  m.nama_mapel,
  m.kode_mapel,
  k.nama_kelas,
  k.tingkat
FROM jadwal j
JOIN guru g ON j.guru_id = g.id
JOIN mata_pelajaran m ON j.mapel_id = m.id
JOIN kelas k ON j.kelas_id = k.id
ORDER BY FIELD(j.hari, 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'), j.jam_mulai;

-- View: Pembayaran Summary per Siswa
CREATE OR REPLACE VIEW v_pembayaran_summary AS
SELECT
  s.id as siswa_id,
  s.nis,
  s.nama as nama_siswa,
  k.nama_kelas,
  COUNT(*) as total_tagihan,
  SUM(CASE WHEN p.status = 'lunas' THEN 1 ELSE 0 END) as total_lunas,
  SUM(CASE WHEN p.status = 'belum_bayar' THEN 1 ELSE 0 END) as total_belum_bayar,
  SUM(CASE WHEN p.status = 'terlambat' THEN 1 ELSE 0 END) as total_terlambat,
  SUM(p.jumlah) as total_tagihan_jumlah,
  SUM(CASE WHEN p.status = 'lunas' THEN p.jumlah ELSE 0 END) as total_lunas_jumlah,
  SUM(CASE WHEN p.status != 'lunas' THEN p.jumlah ELSE 0 END) as total_belum_bayar_jumlah
FROM pembayaran p
JOIN siswa s ON p.siswa_id = s.id
LEFT JOIN kelas k ON s.kelas_id = k.id
GROUP BY s.id, s.nis, s.nama, k.nama_kelas;

-- View: Statistik Kelas
CREATE OR REPLACE VIEW v_statistik_kelas AS
SELECT
  k.id as kelas_id,
  k.nama_kelas,
  k.tingkat,
  k.tahun_ajaran,
  g.nama as wali_kelas,
  COUNT(DISTINCT s.id) as total_siswa,
  COUNT(DISTINCT j.id) as total_jadwal,
  COUNT(DISTINCT n.id) as total_nilai,
  AVG(n.nilai_akhir) as rata_rata_nilai
FROM kelas k
LEFT JOIN guru g ON k.wali_kelas_id = g.id
LEFT JOIN siswa s ON k.id = s.kelas_id
LEFT JOIN jadwal j ON k.id = j.kelas_id
LEFT JOIN nilai n ON k.id = n.kelas_id
GROUP BY k.id, k.nama_kelas, k.tingkat, k.tahun_ajaran, g.nama;
