import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/device_service.dart';

class AssetConfig {
  static final AssetConfig _instance = AssetConfig._internal();
  factory AssetConfig() => _instance;
  AssetConfig._internal();

  late Map<String, dynamic> _config;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Load configuration based on device capabilities
      final deviceInfo = DeviceService().deviceInfo;
      _config = _generateConfigForDevice(deviceInfo);
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing asset config: $e');
      _config = _getDefaultConfig();
      _isInitialized = true;
    }
  }

  Map<String, dynamic> _generateConfigForDevice(DeviceInfo deviceInfo) {
    final quality = _getQualityLevel(deviceInfo.performanceCategory);
    
    return {
      'images': {
        'quality': quality,
        'formats': _getSupportedImageFormats(deviceInfo),
        'max_size': _getMaxImageSize(deviceInfo),
        'compression_level': _getCompressionLevel(deviceInfo.performanceCategory),
        'lazy_load_threshold': _getLazyLoadThreshold(deviceInfo.performanceCategory),
      },
      'videos': {
        'quality': DeviceService().getRecommendedVideoQuality(),
        'formats': _getSupportedVideoFormats(deviceInfo),
        'max_bitrate': _getMaxVideoBitrate(deviceInfo.performanceCategory),
        'stream_buffer_size': _getStreamBufferSize(deviceInfo.performanceCategory),
      },
      'audio': {
        'quality': _getAudioQuality(deviceInfo.performanceCategory),
        'formats': ['mp3', 'aac', 'ogg'],
        'bitrate': _getAudioBitrate(deviceInfo.performanceCategory),
        'sample_rate': _getAudioSampleRate(deviceInfo.performanceCategory),
      },
      'documents': {
        'cache_enabled': deviceInfo.performanceCategory != DevicePerformanceCategory.low,
        'max_cache_size': DeviceService().getCacheSizeLimit(),
        'preload_pages': _getPreloadPages(deviceInfo.performanceCategory),
      },
      'animations': {
        'enabled': DeviceService().canHandleHeavyAnimations(),
        'fps': _getTargetFPS(deviceInfo.performanceCategory),
        'particle_effects': deviceInfo.performanceCategory.index >= DevicePerformanceCategory.high.index,
        'transition_duration': _getTransitionDuration(deviceInfo.performanceCategory),
      },
      'ui': {
        'theme': deviceInfo.performanceCategory == DevicePerformanceCategory.low ? 'light' : 'auto',
        'font_scaling': _getFontScaling(deviceInfo.screenSize),
        'icon_size': _getIconSize(deviceInfo.deviceType),
        'grid_columns': _getGridColumns(deviceInfo.deviceType),
      },
      'network': {
        'concurrent_downloads': _getMaxConcurrentDownloads(deviceInfo.performanceCategory),
        'chunk_size': _getDownloadChunkSize(deviceInfo.performanceCategory),
        'retry_attempts': _getMaxRetryAttempts(deviceInfo.performanceCategory),
        'timeout_seconds': _getNetworkTimeout(deviceInfo.performanceCategory),
      },
      'cache': {
        'image_cache_size': _getImageCacheSize(deviceInfo.performanceCategory),
        'video_cache_size': _getVideoCacheSize(deviceInfo.performanceCategory),
        'document_cache_size': _getDocumentCacheSize(deviceInfo.performanceCategory),
        'cleanup_interval_hours': _getCleanupInterval(deviceInfo.performanceCategory),
      }
    };
  }

  Map<String, dynamic> _getDefaultConfig() {
    return {
      'images': {
        'quality': 'medium',
        'formats': ['jpg', 'png', 'webp'],
        'max_size': 1024,
        'compression_level': 70,
        'lazy_load_threshold': 10,
      },
      'videos': {
        'quality': '720p',
        'formats': ['mp4', 'webm'],
        'max_bitrate': 2000,
        'stream_buffer_size': 1024 * 1024, // 1MB
      },
      'audio': {
        'quality': 'medium',
        'formats': ['mp3', 'aac'],
        'bitrate': 128,
        'sample_rate': 44100,
      },
      'documents': {
        'cache_enabled': true,
        'max_cache_size': 100 * 1024 * 1024, // 100MB
        'preload_pages': 3,
      },
      'animations': {
        'enabled': true,
        'fps': 60,
        'particle_effects': false,
        'transition_duration': 300,
      },
      'ui': {
        'theme': 'auto',
        'font_scaling': 1.0,
        'icon_size': 24,
        'grid_columns': 2,
      },
      'network': {
        'concurrent_downloads': 3,
        'chunk_size': 64 * 1024, // 64KB
        'retry_attempts': 3,
        'timeout_seconds': 30,
      },
      'cache': {
        'image_cache_size': 50 * 1024 * 1024, // 50MB
        'video_cache_size': 200 * 1024 * 1024, // 200MB
        'document_cache_size': 30 * 1024 * 1024, // 30MB
        'cleanup_interval_hours': 24,
      }
    };
  }

  // Quality level methods
  String _getQualityLevel(DevicePerformanceCategory category) {
    switch (category) {
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

  List<String> _getSupportedImageFormats(DeviceInfo deviceInfo) {
    final formats = ['jpg', 'png'];
    
    // WebP support for better performance
    if (deviceInfo.performanceCategory != DevicePerformanceCategory.low) {
      formats.add('webp');
    }
    
    // AVIF for premium devices
    if (deviceInfo.performanceCategory == DevicePerformanceCategory.premium) {
      formats.add('avif');
    }
    
    return formats;
  }

  int _getMaxImageSize(DeviceInfo deviceInfo) {
    switch (deviceInfo.performanceCategory) {
      case DevicePerformanceCategory.low:
        return 512;
      case DevicePerformanceCategory.medium:
        return 1024;
      case DevicePerformanceCategory.high:
        return 1536;
      case DevicePerformanceCategory.premium:
        return 2048;
    }
  }

  int _getCompressionLevel(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 90; // Higher compression (lower quality)
      case DevicePerformanceCategory.medium:
        return 70;
      case DevicePerformanceCategory.high:
        return 50;
      case DevicePerformanceCategory.premium:
        return 30; // Lower compression (higher quality)
    }
  }

  int _getLazyLoadThreshold(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 5; // Load fewer items at once
      case DevicePerformanceCategory.medium:
        return 10;
      case DevicePerformanceCategory.high:
        return 15;
      case DevicePerformanceCategory.premium:
        return 20;
    }
  }

  List<String> _getSupportedVideoFormats(DeviceInfo deviceInfo) {
    final formats = ['mp4'];
    
    if (deviceInfo.performanceCategory != DevicePerformanceCategory.low) {
      formats.add('webm');
    }
    
    return formats;
  }

  int _getMaxVideoBitrate(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 800; // kbps
      case DevicePerformanceCategory.medium:
        return 2000;
      case DevicePerformanceCategory.high:
        return 4000;
      case DevicePerformanceCategory.premium:
        return 8000;
    }
  }

  int _getStreamBufferSize(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 512 * 1024; // 512KB
      case DevicePerformanceCategory.medium:
        return 1024 * 1024; // 1MB
      case DevicePerformanceCategory.high:
        return 2 * 1024 * 1024; // 2MB
      case DevicePerformanceCategory.premium:
        return 4 * 1024 * 1024; // 4MB
    }
  }

  String _getAudioQuality(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 'low';
      case DevicePerformanceCategory.medium:
        return 'medium';
      case DevicePerformanceCategory.high:
        return 'high';
      case DevicePerformanceCategory.premium:
        return 'lossless';
    }
  }

  int _getAudioBitrate(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 64; // kbps
      case DevicePerformanceCategory.medium:
        return 128;
      case DevicePerformanceCategory.high:
        return 256;
      case DevicePerformanceCategory.premium:
        return 320;
    }
  }

  int _getAudioSampleRate(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 22050; // Hz
      case DevicePerformanceCategory.medium:
        return 44100;
      case DevicePerformanceCategory.high:
        return 48000;
      case DevicePerformanceCategory.premium:
        return 96000;
    }
  }

  int _getPreloadPages(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 1;
      case DevicePerformanceCategory.medium:
        return 3;
      case DevicePerformanceCategory.high:
        return 5;
      case DevicePerformanceCategory.premium:
        return 10;
    }
  }

  int _getTargetFPS(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 30;
      case DevicePerformanceCategory.medium:
        return 60;
      case DevicePerformanceCategory.high:
        return 60;
      case DevicePerformanceCategory.premium:
        return 120;
    }
  }

  int _getTransitionDuration(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 150; // ms - faster transitions
      case DevicePerformanceCategory.medium:
        return 300;
      case DevicePerformanceCategory.high:
        return 300;
      case DevicePerformanceCategory.premium:
        return 500; // smoother transitions
    }
  }

  double _getFontScaling(double? screenSize) {
    if (screenSize == null) return 1.0;
    
    if (screenSize < 5.0) return 0.9; // Small phones
    if (screenSize < 6.0) return 1.0; // Regular phones
    if (screenSize < 7.0) return 1.1; // Large phones
    return 1.2; // Tablets
  }

  int _getIconSize(String deviceType) {
    switch (deviceType) {
      case 'tablet':
        return 32;
      case 'large_phone':
        return 28;
      case 'phone':
        return 24;
      default:
        return 24;
    }
  }

  int _getGridColumns(String deviceType) {
    switch (deviceType) {
      case 'tablet':
        return 4;
      case 'large_phone':
        return 3;
      case 'phone':
        return 2;
      default:
        return 2;
    }
  }

  int _getMaxConcurrentDownloads(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 1;
      case DevicePerformanceCategory.medium:
        return 2;
      case DevicePerformanceCategory.high:
        return 3;
      case DevicePerformanceCategory.premium:
        return 5;
    }
  }

  int _getDownloadChunkSize(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 32 * 1024; // 32KB
      case DevicePerformanceCategory.medium:
        return 64 * 1024; // 64KB
      case DevicePerformanceCategory.high:
        return 128 * 1024; // 128KB
      case DevicePerformanceCategory.premium:
        return 256 * 1024; // 256KB
    }
  }

  int _getMaxRetryAttempts(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 2;
      case DevicePerformanceCategory.medium:
        return 3;
      case DevicePerformanceCategory.high:
        return 3;
      case DevicePerformanceCategory.premium:
        return 5;
    }
  }

  int _getNetworkTimeout(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 15; // seconds
      case DevicePerformanceCategory.medium:
        return 30;
      case DevicePerformanceCategory.high:
        return 30;
      case DevicePerformanceCategory.premium:
        return 60;
    }
  }

  int _getImageCacheSize(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 20 * 1024 * 1024; // 20MB
      case DevicePerformanceCategory.medium:
        return 50 * 1024 * 1024; // 50MB
      case DevicePerformanceCategory.high:
        return 100 * 1024 * 1024; // 100MB
      case DevicePerformanceCategory.premium:
        return 200 * 1024 * 1024; // 200MB
    }
  }

  int _getVideoCacheSize(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 50 * 1024 * 1024; // 50MB
      case DevicePerformanceCategory.medium:
        return 200 * 1024 * 1024; // 200MB
      case DevicePerformanceCategory.high:
        return 500 * 1024 * 1024; // 500MB
      case DevicePerformanceCategory.premium:
        return 1024 * 1024 * 1024; // 1GB
    }
  }

  int _getDocumentCacheSize(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 10 * 1024 * 1024; // 10MB
      case DevicePerformanceCategory.medium:
        return 30 * 1024 * 1024; // 30MB
      case DevicePerformanceCategory.high:
        return 50 * 1024 * 1024; // 50MB
      case DevicePerformanceCategory.premium:
        return 100 * 1024 * 1024; // 100MB
    }
  }

  int _getCleanupInterval(DevicePerformanceCategory category) {
    switch (category) {
      case DevicePerformanceCategory.low:
        return 6; // hours
      case DevicePerformanceCategory.medium:
        return 12;
      case DevicePerformanceCategory.high:
        return 24;
      case DevicePerformanceCategory.premium:
        return 48;
    }
  }

  // Public getters
  Map<String, dynamic> get images => _config['images'];
  Map<String, dynamic> get videos => _config['videos'];
  Map<String, dynamic> get audio => _config['audio'];
  Map<String, dynamic> get documents => _config['documents'];
  Map<String, dynamic> get animations => _config['animations'];
  Map<String, dynamic> get ui => _config['ui'];
  Map<String, dynamic> get network => _config['network'];
  Map<String, dynamic> get cache => _config['cache'];

  // Helper methods to get specific configurations
  String getImageQuality() => images['quality'];
  List<String> getImageFormats() => List<String>.from(images['formats']);
  int getMaxImageSize() => images['max_size'];
  
  String getVideoQuality() => videos['quality'];
  List<String> getVideoFormats() => List<String>.from(videos['formats']);
  
  String getAudioQuality() => audio['quality'];
  int getAudioBitrate() => audio['bitrate'];
  
  bool areAnimationsEnabled() => animations['enabled'];
  int getTargetFPS() => animations['fps'];
  
  int getMaxConcurrentDownloads() => network['concurrent_downloads'];
  int getDownloadChunkSize() => network['chunk_size'];
  int getNetworkTimeout() => network['timeout_seconds'];
  int getMaxRetryAttempts() => network['retry_attempts'];
  
  String getUITheme() => ui['theme'];
  double getFontScaling() => ui['font_scaling'];
  int getGridColumns() => ui['grid_columns'];
}
