import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfo {
  final String brand;
  final String model;
  final int? totalMemory;
  final int? storageSize;
  final String? processor;
  final int? cores;
  final double? screenSize;
  final int? screenWidth;
  final int? screenHeight;
  final String deviceType;
  final DevicePerformanceCategory performanceCategory;

  DeviceInfo({
    required this.brand,
    required this.model,
    this.totalMemory,
    this.storageSize,
    this.processor,
    this.cores,
    this.screenSize,
    this.screenWidth,
    this.screenHeight,
    required this.deviceType,
    required this.performanceCategory,
  });

  @override
  String toString() {
    return 'DeviceInfo(brand: $brand, model: $model, performance: $performanceCategory)';
  }
}

enum DevicePerformanceCategory {
  low,      // < 2GB RAM, low-end processors
  medium,   // 2-4GB RAM, mid-range processors
  high,     // 4-8GB RAM, high-end processors
  premium,  // > 8GB RAM, flagship processors
}

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  late DeviceInfo _deviceInfo;
  bool _isInitialized = false;

  DeviceInfo get deviceInfo {
    if (!_isInitialized) {
      throw Exception('DeviceService not initialized. Call init() first.');
    }
    return _deviceInfo;
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      if (kIsWeb) {
        _deviceInfo = _getWebDeviceInfo();
      } else if (Platform.isAndroid) {
        _deviceInfo = await _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        _deviceInfo = await _getIOSDeviceInfo();
      } else {
        _deviceInfo = _getGenericDeviceInfo();
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing device info: $e');
      _deviceInfo = _getGenericDeviceInfo();
      _isInitialized = true;
    }
  }

  Future<DeviceInfo> _getAndroidDeviceInfo() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final memoryInfo = await _getAndroidMemoryInfo();
    
    final totalMemory = memoryInfo?['totalMemory'] as int?;
    final cores = androidInfo.hardware['cores'] as int?;
    
    return DeviceInfo(
      brand: androidInfo.brand,
      model: androidInfo.model,
      totalMemory: totalMemory,
      storageSize: await _getStorageSize(),
      processor: androidInfo.hardware['processor'] as String?,
      cores: cores,
      screenSize: _calculateScreenSize(androidInfo.displayMetrics),
      screenWidth: androidInfo.displayMetrics.widthPx.toInt(),
      screenHeight: androidInfo.displayMetrics.heightPx.toInt(),
      deviceType: _getDeviceType(androidInfo.displayMetrics),
      performanceCategory: _calculatePerformanceCategory(totalMemory, androidInfo.brand, androidInfo.model),
    );
  }

  Future<DeviceInfo> _getIOSDeviceInfo() async {
    final iosInfo = await DeviceInfoPlugin().iosInfo;
    
    return DeviceInfo(
      brand: 'Apple',
      model: iosInfo.model,
      totalMemory: await _getIOSMemoryInfo(),
      storageSize: await _getStorageSize(),
      processor: iosInfo.utsname.machine,
      cores: null, // iOS doesn't expose core count easily
      screenSize: _calculateScreenSize(null, iosInfo),
      screenWidth: null,
      screenHeight: null,
      deviceType: _getIOSDeviceType(iosInfo.model),
      performanceCategory: _getIOSPerformanceCategory(iosInfo.model),
    );
  }

  DeviceInfo _getWebDeviceInfo() {
    return DeviceInfo(
      brand: 'Web',
      model: 'Browser',
      totalMemory: null,
      storageSize: null,
      processor: null,
      cores: null,
      screenSize: null,
      screenWidth: null,
      screenHeight: null,
      deviceType: 'web',
      performanceCategory: DevicePerformanceCategory.medium,
    );
  }

  DeviceInfo _getGenericDeviceInfo() {
    return DeviceInfo(
      brand: 'Unknown',
      model: 'Unknown',
      totalMemory: null,
      storageSize: null,
      processor: null,
      cores: null,
      screenSize: null,
      screenWidth: null,
      screenHeight: null,
      deviceType: 'unknown',
      performanceCategory: DevicePerformanceCategory.medium,
    );
  }

  Future<Map<String, int>?> _getAndroidMemoryInfo() async {
    try {
      // This would require additional native code or method channels
      // For now, we'll estimate based on common device patterns
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int?> _getIOSMemoryInfo() async {
    try {
      // iOS memory info requires native code
      // For now, we'll estimate based on device model
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<int?> _getStorageSize() async {
    try {
      // Storage size would require additional permissions and native code
      return null;
    } catch (e) {
      return null;
    }
  }

  double? _calculateScreenSize(dynamic displayMetrics, dynamic iosInfo) {
    try {
      if (displayMetrics != null) {
        final widthInches = displayMetrics.widthPx / displayMetrics.xdpi;
        final heightInches = displayMetrics.heightPx / displayMetrics.ydpi;
        final diagonal = (widthInches * widthInches + heightInches * heightInches).abs();
        return diagonal > 0 ? diagonal.sqrt() : null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _getDeviceType(dynamic displayMetrics) {
    try {
      if (displayMetrics != null) {
        final screenWidth = displayMetrics.widthPx;
        if (screenWidth >= 1200) return 'tablet';
        if (screenWidth >= 600) return 'large_phone';
        return 'phone';
      }
      return 'phone';
    } catch (e) {
      return 'phone';
    }
  }

  String _getIOSDeviceType(String model) {
    if (model.contains('iPad')) return 'tablet';
    if (model.contains('iPhone')) return 'phone';
    return 'unknown';
  }

  DevicePerformanceCategory _calculatePerformanceCategory(
    int? totalMemory, 
    String brand, 
    String model
  ) {
    // Estimate memory if not available
    final estimatedMemory = totalMemory ?? _estimateMemoryFromBrandModel(brand, model);
    
    if (estimatedMemory == null) return DevicePerformanceCategory.medium;
    
    if (estimatedMemory >= 8192) return DevicePerformanceCategory.premium;
    if (estimatedMemory >= 4096) return DevicePerformanceCategory.high;
    if (estimatedMemory >= 2048) return DevicePerformanceCategory.medium;
    return DevicePerformanceCategory.low;
  }

  DevicePerformanceCategory _getIOSPerformanceCategory(String model) {
    // iOS device performance based on model
    if (model.contains('iPhone 14') || model.contains('iPhone 15') || 
        model.contains('iPhone 13') || model.contains('iPhone 12')) {
      return DevicePerformanceCategory.premium;
    }
    if (model.contains('iPhone 11') || model.contains('iPhone X') ||
        model.contains('iPhone XS') || model.contains('iPhone 11')) {
      return DevicePerformanceCategory.high;
    }
    if (model.contains('iPhone 8') || model.contains('iPhone SE')) {
      return DevicePerformanceCategory.medium;
    }
    return DevicePerformanceCategory.low;
  }

  int? _estimateMemoryFromBrandModel(String brand, String model) {
    // Common device memory estimations
    final brandModel = '$brand $model'.toLowerCase();
    
    if (brandModel.contains('samsung') && brandModel.contains('galaxy')) {
      if (brandModel.contains('s23') || brandModel.contains('s22') || brandModel.contains('s21')) return 8192;
      if (brandModel.contains('s20') || brandModel.contains('s10')) return 4096;
      if (brandModel.contains('a54') || brandModel.contains('a34')) return 6144;
      if (brandModel.contains('a14') || brandModel.contains('a24')) return 4096;
      return 2048;
    }
    
    if (brandModel.contains('xiaomi') || brandModel.contains('redmi')) {
      if (brandModel.contains('13') || brandModel.contains('12')) return 6144;
      if (brandModel.contains('note 12') || brandModel.contains('note 11')) return 4096;
      return 3072;
    }
    
    if (brandModel.contains('oppo')) {
      if (brandModel.contains('find')) return 8192;
      if (brandModel.contains('reno')) return 6144;
      return 4096;
    }
    
    if (brandModel.contains('vivo')) {
      if (brandModel.contains('x90') || brandModel.contains('x80')) return 8192;
      if (brandModel.contains('y series')) return 4096;
      return 3072;
    }
    
    // Default estimation
    return 4096;
  }

  // Helper method to get recommended asset quality based on device performance
  String getRecommendedImageQuality() {
    switch (_deviceInfo.performanceCategory) {
      case DevicePerformanceCategory.low:
        return 'low';
      case DevicePerformanceCategory.medium:
        return 'medium';
      case DevicePerformanceCategory.high:
        return 'high';
      case DevicePerformanceCategory.premium:
        return 'ultra';
    }
  }

  // Helper method to get recommended video quality
  String getRecommendedVideoQuality() {
    switch (_deviceInfo.performanceCategory) {
      case DevicePerformanceCategory.low:
        return '360p';
      case DevicePerformanceCategory.medium:
        return '720p';
      case DevicePerformanceCategory.high:
        return '1080p';
      case DevicePerformanceCategory.premium:
        return '4K';
    }
  }

  // Helper method to check if device can handle heavy animations
  bool canHandleHeavyAnimations() {
    return _deviceInfo.performanceCategory.index >= DevicePerformanceCategory.high.index;
  }

  // Helper method to get cache size limit based on available memory
  int getCacheSizeLimit() {
    switch (_deviceInfo.performanceCategory) {
      case DevicePerformanceCategory.low:
        return 50 * 1024 * 1024; // 50MB
      case DevicePerformanceCategory.medium:
        return 100 * 1024 * 1024; // 100MB
      case DevicePerformanceCategory.high:
        return 200 * 1024 * 1024; // 200MB
      case DevicePerformanceCategory.premium:
        return 500 * 1024 * 1024; // 500MB
    }
  }
}
