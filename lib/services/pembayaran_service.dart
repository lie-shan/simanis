import 'api_service.dart';
import '../config/api_config.dart';

class PembayaranService {
  final ApiService _api = ApiService();

  // Get all pembayaran
  Future<List<Map<String, dynamic>>> getAllPembayaran({
    String? siswaId,
    String? status,
    String? jenisPembayaran,
    String? bulan,
    String? tahun,
  }) async {
    final queryParams = <String, String>{};
    if (siswaId != null) queryParams['siswa_id'] = siswaId;
    if (status != null) queryParams['status'] = status;
    if (jenisPembayaran != null) queryParams['jenis_pembayaran'] = jenisPembayaran;
    if (bulan != null) queryParams['bulan'] = bulan;
    if (tahun != null) queryParams['tahun'] = tahun;

    final response = await _api.get(
      ApiConfig.pembayaran,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data pembayaran');
  }

  // Get pembayaran by ID
  Future<Map<String, dynamic>> getPembayaranById(int id) async {
    final response = await _api.get(ApiConfig.pembayaranById(id));
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data pembayaran');
  }

  // Get pembayaran by siswa
  Future<List<Map<String, dynamic>>> getPembayaranBySiswa(int siswaId) async {
    final response = await _api.get(ApiConfig.pembayaranBySiswa(siswaId));
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil data pembayaran siswa');
  }

  // Create pembayaran
  Future<Map<String, dynamic>> createPembayaran(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.pembayaran, body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal menambah pembayaran');
  }

  // Create bulk pembayaran
  Future<Map<String, dynamic>> createBulkPembayaran(Map<String, dynamic> data) async {
    final response = await _api.post(ApiConfig.pembayaranBulk, body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal menambah pembayaran bulk');
  }

  // Update pembayaran (bisa pakai id numerik atau kode_transaksi)
  Future<Map<String, dynamic>> updatePembayaran(String id, Map<String, dynamic> data) async {
    final response = await _api.put('${ApiConfig.pembayaran}/$id', body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengupdate pembayaran');
  }

  // Process payment (bayar) - bisa pakai id numerik atau kode_transaksi
  Future<Map<String, dynamic>> processPayment(String id, Map<String, dynamic> data) async {
    final response = await _api.put('${ApiConfig.pembayaran}/$id/bayar', body: data);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal memproses pembayaran');
  }

  // Cancel payment - bisa pakai id numerik atau kode_transaksi
  Future<Map<String, dynamic>> cancelPayment(String id) async {
    final response = await _api.put('${ApiConfig.pembayaran}/$id/batal');
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal membatalkan pembayaran');
  }

  // Delete pembayaran (bisa pakai id numerik atau kode_transaksi)
  Future<void> deletePembayaran(String id) async {
    final response = await _api.delete('${ApiConfig.pembayaran}/$id');
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Gagal menghapus pembayaran');
    }
  }

  // Get pembayaran statistics
  Future<Map<String, dynamic>> getPembayaranStats() async {
    final response = await _api.get(ApiConfig.pembayaranStats);
    if (response['success'] == true) {
      return Map<String, dynamic>.from(response['data'] ?? {});
    }
    throw Exception(response['message'] ?? 'Gagal mengambil statistik pembayaran');
  }

  // Get jenis pembayaran options
  Future<List<Map<String, dynamic>>> getJenisPembayaran() async {
    final response = await _api.get(ApiConfig.pembayaranTypes);
    if (response['success'] == true) {
      return List<Map<String, dynamic>>.from(response['data'] ?? []);
    }
    throw Exception(response['message'] ?? 'Gagal mengambil jenis pembayaran');
  }
}
