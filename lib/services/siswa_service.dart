import 'api_service.dart';
import '../config/api_config.dart';

class SiswaService {
  final ApiService _api = ApiService();

  // Get all siswa
  Future<List<Map<String, dynamic>>> getAllSiswa({String? kelasId}) async {
    final queryParams = kelasId != null ? {'kelas_id': kelasId} : null;
    final response = await _api.get(ApiConfig.siswa, queryParameters: queryParams);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data siswa');
  }

  // Get siswa by ID
  Future<Map<String, dynamic>> getSiswaById(int id) async {
    final response = await _api.get(ApiConfig.siswaById(id));
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data siswa');
  }

  // Create siswa
  Future<Map<String, dynamic>> createSiswa(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.siswa, body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal menambah siswa');
  }

  // Update siswa
  Future<Map<String, dynamic>> updateSiswa(int id, Map<String, dynamic> data) async {
    final response = await _api.put(ApiConfig.siswaById(id), body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengupdate siswa');
  }

  // Delete siswa
  Future<void> deleteSiswa(int id) async {
    final response = await _api.delete(ApiConfig.siswaById(id));
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal menghapus siswa');
    }
  }

  // Get siswa count by kelas
  Future<List<Map<String, dynamic>>> getSiswaCountByKelas() async {
    final response = await _api.get(ApiConfig.siswaCountByKelas);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil statistik siswa');
  }
}
