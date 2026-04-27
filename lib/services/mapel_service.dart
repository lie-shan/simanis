import 'api_service.dart';
import '../config/api_config.dart';

class MapelService {
  final ApiService _api = ApiService();

  // Get all mapel
  Future<List<Map<String, dynamic>>> getAllMapel() async {
    final response = await _api.get(ApiConfig.mapel);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data mata pelajaran');
  }

  // Get mapel by ID
  Future<Map<String, dynamic>> getMapelById(int id) async {
    final response = await _api.get(ApiConfig.mapelById(id));
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data mata pelajaran');
  }

  // Create mapel
  Future<Map<String, dynamic>> createMapel(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.mapel, body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal menambah mata pelajaran');
  }

  // Update mapel
  Future<Map<String, dynamic>> updateMapel(int id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.mapelById(id), body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengupdate mata pelajaran');
  }

  // Delete mapel
  Future<void> deleteMapel(int id) async {
    final response = await _api.delete(ApiConfig.mapelById(id));
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal menghapus mata pelajaran');
    }
  }

  // Get available mapel (for dropdown)
  Future<List<Map<String, dynamic>>> getAvailableMapel() async {
    final response = await _api.get(ApiConfig.mapelAvailable);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data mata pelajaran');
  }
}
