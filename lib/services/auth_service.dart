import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response['success'] == true && response['data'] != null) {
        final token = response['data']['token'];
        final user = response['data']['user'];

        // Save token
        await _apiService.saveToken(token);

        // Save user data
        await _saveUserData(user);

        return response;
      }

      throw Exception(response['message'] ?? 'Login gagal');
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logout);
    } catch (e) {
      // Ignore error, just clear local data
    } finally {
      await _apiService.removeToken();
      await _clearUserData();
    }
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword({
    required String whatsapp,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.forgotPassword,
        body: {
          'whatsapp': whatsapp,
        },
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.resetPassword,
        body: {
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        requiresAuth: false,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return Map<String, dynamic>.from(
        // ignore: avoid_dynamic_calls
        (await Future.value(userJson)) as Map,
      );
    }
    return null;
  }

  // Save user data to local storage
  Future<void> _saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toString());
    await prefs.setInt('user_id', user['id'] as int);
    await prefs.setString('user_name', user['nama'] as String);
    await prefs.setString('user_email', user['email'] as String);
    await prefs.setString('user_role', user['role'] as String);
  }

  // Clear user data from local storage
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
  }
}
