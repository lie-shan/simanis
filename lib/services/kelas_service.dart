import 'api_service.dart';
import '../config/api_config.dart';

class KelasService {
  final ApiService _api = ApiService();

  // Get all kelas
  Future<List<Map<String, dynamic>>> getAllKelas() async {
    final response = await _api.get(ApiConfig.kelas);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data kelas');
  }

  // Get kelas by ID
  Future<Map<String, dynamic>> getKelasById(int id) async {
    final response = await _api.get(ApiConfig.kelasById(id));
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data kelas');
  }

  // Create kelas
  Future<Map<String, dynamic>> createKelas(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.kelas, body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal menambah kelas');
  }

  // Update kelas
  Future<Map<String, dynamic>> updateKelas(int id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.kelasById(id), body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengupdate kelas');
  }

  // Delete kelas
  Future<void> deleteKelas(int id) async {
    final response = await _api.delete(ApiConfig.kelasById(id));
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal menghapus kelas');
    }
  }

  // Get kelas statistics
  Future<Map<String, dynamic>> getKelasStats() async {
    final response = await _api.get(ApiConfig.kelasStats);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengambil statistik kelas');
  }

  // Get available kelas (for dropdown)
  Future<List<Map<String, dynamic>>> getAvailableKelas() async {
    final response = await _api.get(ApiConfig.kelasAvailable);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data kelas');
  }
}
