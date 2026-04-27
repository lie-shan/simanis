import 'api_service.dart';
import '../config/api_config.dart';

class GuruService {
  final ApiService _api = ApiService();

  // Get all guru
  Future<List<Map<String, dynamic>>> getAllGuru() async {
    final response = await _api.get(ApiConfig.guru);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data guru');
  }

  // Get guru by ID
  Future<Map<String, dynamic>> getGuruById(int id) async {
    final response = await _api.get(ApiConfig.guruById(id));
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data guru');
  }

  // Create guru
  Future<Map<String, dynamic>> createGuru(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.guru, body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal menambah guru');
  }

  // Update guru
  Future<Map<String, dynamic>> updateGuru(int id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.guruById(id), body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengupdate guru');
  }

  // Delete guru
  Future<void> deleteGuru(int id) async {
    final response = await _api.delete(ApiConfig.guruById(id));
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal menghapus guru');
    }
  }

  // Get available guru (for dropdown)
  Future<List<Map<String, dynamic>>> getAvailableGuru() async {
    final response = await _api.get(ApiConfig.guruAvailable);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data guru');
  }
}
