import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  // Initialize token from storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token to storage
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Remove token from storage
  Future<void> removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers with or without auth
  Map<String, String> _getHeaders({bool requiresAuth = true}) {
    if (requiresAuth && _token != null) {
      return ApiConfig.headersWithAuth(_token!);
    }
    return ApiConfig.headers;
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint')
          .replace(queryParameters: queryParameters);

      final response = await http
          .get(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .post(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .put(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

      final response = await http
          .delete(
            uri,
            headers: _getHeaders(requiresAuth: requiresAuth),
          )
          .timeout(ApiConfig.connectionTimeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['message'] ?? 'Terjadi kesalahan',
        statusCode: response.statusCode,
        errors: data['errors'],
      );
    }
  }

  // Handle errors with specific server down detection
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    
    // Check if server is down (SocketException)
    if (error is SocketException || error is http.ClientException) {
      final errorStr = error.toString().toLowerCase();
      if (errorStr.contains('connection refused') || 
          errorStr.contains('failed host lookup') ||
          errorStr.contains('errno = 7') ||
          errorStr.contains('errno = 111') ||
          errorStr.contains('socket')) {
        return ApiException(
          message: 'Server sedang offline. Silakan hubungi administrator.',
          statusCode: 503, // Service Unavailable
          isServerDown: true,
        );
      }
    }
    
    return ApiException(
      message: 'Koneksi ke server gagal. Periksa koneksi internet Anda.',
      statusCode: 0,
    );
  }
  
  // Check if server is reachable
  Future<bool> isServerReachable() async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/health'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;
  final bool isServerDown;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
    this.isServerDown = false,
  });

  @override
  String toString() => message;
}
