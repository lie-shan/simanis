class ApiConfig {
  // ==========================================
  // PILIH PLATFORM YANG DIGUNAKAN:
  // ==========================================
  // Uncomment SALAH SATU sesuai platform:
  // ==========================================

  // 1. Web/Chrome/Edge (Laptop):
  // static const String baseUrl = 'http://localhost:3000';

  // 2. Android Emulator:
  // static const String baseUrl = 'http://10.0.2.2:3000';

  // 3. iOS Simulator (Mac):
  // static const String baseUrl = 'http://localhost:3000';

  // 4. HP/Device Fisik (WiFi sama):
  // static const String baseUrl = 'http://192.168.1.177:3000';

  // 5. NGROK (Public URL - ganti setiap restart ngrok):
  // Contoh: https://xxxx.ngrok-free.app (tanpa / di akhir)
  // static const String baseUrl = 'https://xxxx.ngrok-free.app';

  // 6. CLOUDFLARE TUNNEL (URL tetap, lebih stabil):
  // Install: winget install --id Cloudflare.cloudflared
  // Login: cloudflared tunnel login
  // Create: cloudflared tunnel create SIMANIS
  // Route: cloudflared tunnel route dns SIMANIS SIMANIS.yourdomain.com
  // Run: cloudflared tunnel run SIMANIS
  static const String baseUrl = 'https://siakad-api.trycloudflare.com';

  // API Endpoints
  static const String apiVersion = '/api';

  // Auth Endpoints
  static const String login = '$apiVersion/auth/login';
  static const String logout = '$apiVersion/auth/logout';
  static const String forgotPassword = '$apiVersion/auth/forgot-password';
  static const String resetPassword = '$apiVersion/auth/reset-password';
  static const String verifyToken = '$apiVersion/auth/verify-token';

  // Users Endpoints
  static const String users = '$apiVersion/users';
  static String userById(int id) => '$users/$id';

  // Siswa Endpoints
  static const String siswa = '$apiVersion/siswa';
  static String siswaById(int id) => '$siswa/$id';
  static const String siswaCountByKelas = '$siswa/count-by-kelas';

  // Guru Endpoints
  static const String guru = '$apiVersion/guru';
  static String guruById(int id) => '$guru/$id';
  static const String guruAvailable = '$guru/available';

  // Kelas Endpoints
  static const String kelas = '$apiVersion/kelas';
  static String kelasById(int id) => '$kelas/$id';
  static const String kelasStats = '$kelas/stats/overview';
  static const String kelasAvailable = '$kelas/dropdown/available';

  // Mata Pelajaran Endpoints
  static const String mapel = '$apiVersion/mapel';
  static String mapelById(int id) => '$mapel/$id';
  static const String mapelAvailable = '$mapel/available';

  // Nilai Endpoints
  static const String nilai = '$apiVersion/nilai';
  static String nilaiById(int id) => '$nilai/$id';
  static String nilaiBySiswa(int siswaId) => '$nilai/siswa/$siswaId';
  static String nilaiByMapel(int mapelId) => '$nilai/mapel/$mapelId';
  static String nilaiByKelas(int kelasId) => '$nilai/kelas/$kelasId';

  // Presensi Endpoints
  static const String presensi = '$apiVersion/presensi';
  static String presensiById(int id) => '$presensi/$id';
  static String presensiBySiswa(int siswaId) => '$presensi/siswa/$siswaId';
  static String presensiByKelas(int kelasId) => '$presensi/kelas/$kelasId';
  static const String presensiStats = '$presensi/stats';
  static const String presensiBulk = '$presensi/bulk';

  // Pengumuman Endpoints
  static const String pengumuman = '$apiVersion/pengumuman';
  static String pengumumanById(int id) => '$pengumuman/$id';
  static const String pengumumanPublic = '$pengumuman/public/active';
  static const String pengumumanStats = '$pengumuman/stats';

  // Pembayaran Endpoints
  static const String pembayaran = '$apiVersion/pembayaran';
  static String pembayaranById(int id) => '$pembayaran/$id';
  static String pembayaranBySiswa(int siswaId) => '$pembayaran/siswa/$siswaId';
  static const String pembayaranStats = '$pembayaran/stats';
  static const String pembayaranTypes = '$pembayaran/options/jenis';
  static const String pembayaranBulk = '$pembayaran/bulk';
  static String pembayaranProcess(int id) => '$pembayaran/$id/bayar';
  static String pembayaranCancel(int id) => '$pembayaran/$id/batal';

  // Jadwal Endpoints
  static const String jadwal = '$apiVersion/jadwal';
  static String jadwalById(int id) => '$jadwal/$id';
  static String jadwalByKelas(int kelasId) => '$jadwal/kelas/$kelasId';
  static String jadwalByGuru(int guruId) => '$jadwal/guru/$guruId';

  // Dashboard Endpoints
  static const String dashboardOverview = '$apiVersion/dashboard/overview';
  static const String dashboardAcademicStats = '$apiVersion/dashboard/stats/academic';
  static const String dashboardFinancialStats = '$apiVersion/dashboard/stats/financial';
  static const String dashboardAttendanceStats = '$apiVersion/dashboard/stats/attendance';
  
  // Timeout settings
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> headersWithAuth(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
