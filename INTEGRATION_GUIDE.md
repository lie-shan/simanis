# Panduan Integrasi Flutter dengan Backend MySQL

Panduan lengkap untuk mengintegrasikan aplikasi Flutter SIAKAD dengan backend API MySQL.

## 📋 Langkah-langkah Integrasi

### 1. Setup Backend

#### A. Install Dependencies Backend
```bash
cd backend
npm install
```

#### B. Setup Database MySQL

1. Buka MySQL (via phpMyAdmin, MySQL Workbench, atau command line):
```bash
mysql -u root -p
```

2. Import schema database:
```bash
mysql -u root -p < database/schema.sql
```

Atau copy-paste isi file `backend/database/schema.sql` ke phpMyAdmin.

#### C. Konfigurasi Environment

1. Copy `.env.example` menjadi `.env`:
```bash
cp .env.example .env
```

2. Edit `.env` sesuai konfigurasi MySQL Anda:
```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password
DB_NAME=siakad_db
DB_PORT=3306

PORT=3000
JWT_SECRET=siakad_secret_key_2024
NODE_ENV=development
```

#### D. Jalankan Backend Server

```bash
npm run dev
```

Server akan berjalan di `http://localhost:3000`

Test dengan browser: `http://localhost:3000` - Anda akan melihat response JSON.

### 2. Setup Flutter

#### A. Tambahkan Dependencies

Edit `pubspec.yaml`, tambahkan:
```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

Jalankan:
```bash
flutter pub get
```

#### B. Buat Service Layer

Buat folder `lib/services/` dan file-file berikut:

**1. `lib/services/api_service.dart`** - Base API service
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan IP komputer Anda jika test di device fisik
  // Untuk emulator Android: 10.0.2.2
  // Untuk iOS simulator: localhost
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Get token from storage
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  // Save token to storage
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }
  
  // Remove token from storage
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
  
  // GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    
    return json.decode(response.body);
  }
  
  // POST request
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    
    return json.decode(response.body);
  }
  
  // PUT request
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );
    
    return json.decode(response.body);
  }
  
  // DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    
    return json.decode(response.body);
  }
}
```

**2. `lib/services/auth_service.dart`** - Authentication service
```dart
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    if (response['success'] == true && response['data']['token'] != null) {
      await _api.saveToken(response['data']['token']);
    }
    
    return response;
  }
  
  // Logout
  Future<void> logout() async {
    await _api.post('/auth/logout', {});
    await _api.removeToken();
  }
  
  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String noWhatsapp) async {
    return await _api.post('/auth/forgot-password', {
      'no_whatsapp': noWhatsapp,
    });
  }
  
  // Verify token
  Future<Map<String, dynamic>> verifyToken() async {
    return await _api.get('/auth/verify');
  }
}
```

**3. `lib/services/nilai_service.dart`** - Nilai service
```dart
import 'api_service.dart';

class NilaiService {
  final ApiService _api = ApiService();
  
  // Get all nilai
  Future<Map<String, dynamic>> getAllNilai({
    int? mapelId,
    int? kelasId,
    String? semester,
    String? tahunAjaran,
  }) async {
    String endpoint = '/nilai?';
    if (mapelId != null) endpoint += 'mapel_id=$mapelId&';
    if (kelasId != null) endpoint += 'kelas_id=$kelasId&';
    if (semester != null) endpoint += 'semester=$semester&';
    if (tahunAjaran != null) endpoint += 'tahun_ajaran=$tahunAjaran&';
    
    return await _api.get(endpoint);
  }
  
  // Get nilai by siswa
  Future<Map<String, dynamic>> getNilaiBySiswa(int siswaId) async {
    return await _api.get('/nilai/siswa/$siswaId');
  }
  
  // Create nilai
  Future<Map<String, dynamic>> createNilai(Map<String, dynamic> data) async {
    return await _api.post('/nilai', data);
  }
  
  // Update nilai
  Future<Map<String, dynamic>> updateNilai(int id, Map<String, dynamic> data) async {
    return await _api.put('/nilai/$id', data);
  }
  
  // Delete nilai
  Future<Map<String, dynamic>> deleteNilai(int id) async {
    return await _api.delete('/nilai/$id');
  }
}
```

**4. `lib/services/users_service.dart`** - Users service
```dart
import 'api_service.dart';

class UsersService {
  final ApiService _api = ApiService();
  
  // Get all users
  Future<Map<String, dynamic>> getAllUsers({String? role, String? status}) async {
    String endpoint = '/users?';
    if (role != null) endpoint += 'role=$role&';
    if (status != null) endpoint += 'status=$status&';
    
    return await _api.get(endpoint);
  }
  
  // Get user by ID
  Future<Map<String, dynamic>> getUserById(int id) async {
    return await _api.get('/users/$id');
  }
  
  // Create user
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    return await _api.post('/users', data);
  }
  
  // Update user
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    return await _api.put('/users/$id', data);
  }
  
  // Delete user
  Future<Map<String, dynamic>> deleteUser(int id) async {
    return await _api.delete('/users/$id');
  }
  
  // Change password
  Future<Map<String, dynamic>> changePassword(int id, String oldPassword, String newPassword) async {
    return await _api.put('/users/$id/change-password', {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }
}
```

### 3. Implementasi di UI

#### Contoh: Login Page

Edit `lib/main.dart`, ganti fungsi login:

```dart
import 'services/auth_service.dart';

// Di dalam _LoginPageState
final AuthService _authService = AuthService();

Future<void> onLogin() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => isLoading = true);
  
  try {
    final response = await _authService.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text.trim(),
    );
    
    if (response['success'] == true) {
      // Login berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    } else {
      // Login gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Login gagal')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}
```

#### Contoh: Nilai Page dengan API

```dart
import 'services/nilai_service.dart';

class _NilaiPageState extends State<NilaiPage> {
  final NilaiService _nilaiService = NilaiService();
  List<dynamic> _nilaiList = [];
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadNilai();
  }
  
  Future<void> _loadNilai() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _nilaiService.getAllNilai(
        mapelId: _selectedMapelId,
        kelasId: _selectedKelasId,
      );
      
      if (response['success'] == true) {
        setState(() {
          _nilaiList = response['data'];
        });
      }
    } catch (e) {
      print('Error loading nilai: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _tambahNilai(Map<String, dynamic> data) async {
    try {
      final response = await _nilaiService.createNilai(data);
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nilai berhasil ditambahkan')),
        );
        _loadNilai(); // Reload data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  // ... rest of the code
}
```

### 4. Testing

#### A. Test Backend
1. Jalankan backend: `npm run dev`
2. Test dengan Postman atau browser:
   - GET `http://localhost:3000` - Health check
   - POST `http://localhost:3000/api/auth/login` dengan body:
     ```json
     {
       "email": "admin@siakad.com",
       "password": "admin123"
     }
     ```

#### B. Test Flutter
1. Pastikan backend sudah running
2. Jalankan Flutter app: `flutter run`
3. Test login dengan:
   - Email: admin@siakad.com
   - Password: admin123

### 5. Troubleshooting

#### Error: Connection refused
- Pastikan backend server sudah running
- Cek IP address di `ApiService.baseUrl`
- Untuk Android emulator gunakan: `http://10.0.2.2:3000/api`
- Untuk iOS simulator gunakan: `http://localhost:3000/api`
- Untuk device fisik gunakan IP komputer: `http://192.168.x.x:3000/api`

#### Error: CORS
Backend sudah dikonfigurasi dengan CORS, tapi jika masih error:
- Pastikan `cors` package sudah terinstall di backend
- Restart backend server

#### Error: Token invalid
- Token expired (24 jam)
- Login ulang untuk mendapatkan token baru

### 6. Default Login Credentials

```
Email: admin@siakad.com
Password: admin123
```

**PENTING:** Ganti password default setelah login pertama kali!

## 📝 Catatan

- Semua endpoint (kecuali login dan forgot-password) memerlukan token JWT
- Token disimpan di SharedPreferences
- Token berlaku selama 24 jam
- Untuk production, ganti `JWT_SECRET` di file `.env`

## 🔗 Endpoint API Lengkap

Lihat file `backend/README.md` untuk daftar lengkap endpoint API.
