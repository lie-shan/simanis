import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'device_service.dart';
import '../config/asset_config.dart';

enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  paused,
  cancelled,
}

enum AssetType {
  image,
  video,
  audio,
  document,
  font,
  other,
}

class DownloadTask {
  final String id;
  final String url;
  final String fileName;
  final AssetType type;
  final Map<String, dynamic> metadata;
  final String? quality;
  final Function(double progress)? onProgress;
  final Function(DownloadStatus status)? onStatusChange;
  final Function(String filePath)? onComplete;
  final Function(String error)? onError;

  DownloadStatus status = DownloadStatus.pending;
  double progress = 0.0;
  String? localPath;
  String? errorMessage;
  int retryCount = 0;
  DateTime? createdAt;
  DateTime? completedAt;

  DownloadTask({
    required this.id,
    required this.url,
    required this.fileName,
    required this.type,
    this.metadata = const {},
    this.quality,
    this.onProgress,
    this.onStatusChange,
    this.onComplete,
    this.onError,
  }) {
    createdAt = DateTime.now();
  }

  void updateProgress(double value) {
    progress = value;
    onProgress?.call(value);
  }

  void updateStatus(DownloadStatus newStatus, {String? error}) {
    status = newStatus;
    if (error != null) {
      errorMessage = error;
      onError?.call(error);
    }
    if (newStatus == DownloadStatus.completed) {
      completedAt = DateTime.now();
    }
    onStatusChange?.call(newStatus);
  }
}

class DownloadManager {
  static final DownloadManager _instance = DownloadManager._internal();
  factory DownloadManager() => _instance;
  DownloadManager._internal();

  late Dio _dio;
  late AssetConfig _assetConfig;
  final Map<String, DownloadTask> _activeDownloads = {};
  final Map<String, DownloadTask> _completedDownloads = {};
  final Map<String, DownloadTask> _failedDownloads = {};
  final List<DownloadTask> _downloadQueue = [];
  
  bool _isInitialized = false;
  int _currentConcurrentDownloads = 0;
  Timer? _cleanupTimer;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _dio = Dio();
      _assetConfig = AssetConfig();
      await _assetConfig.init();
      
      // Configure Dio with settings based on device performance
      _configureDio();
      
      // Start cleanup timer
      _startCleanupTimer();
      
      // Request necessary permissions
      await _requestPermissions();
      
      _isInitialized = true;
      debugPrint('DownloadManager initialized successfully');
    } catch (e) {
      debugPrint('Error initializing DownloadManager: $e');
      rethrow;
    }
  }

  void _configureDio() {
    final timeout = Duration(seconds: _assetConfig.getNetworkTimeout());
    final chunkSize = _assetConfig.getDownloadChunkSize();
    
    _dio.options = BaseOptions(
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      receiveDataWhenStatusError: true,
      headers: {
        'User-Agent': 'SIMANIS-App/${_getUserAgent()}',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate',
      },
    );

    // Add interceptors for retry logic and progress tracking
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: _assetConfig.getMaxRetryAttempts(),
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );
  }

  String _getUserAgent() {
    final deviceInfo = DeviceService().deviceInfo;
    return '${deviceInfo.brand} ${deviceInfo.model} (${deviceInfo.deviceType})';
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      if (Platform.version.contains('13') || Platform.version.contains('33')) {
        await Permission.photos.request();
        await Permission.videos.request();
      }
    }
  }

  void _startCleanupTimer() {
    final intervalHours = _assetConfig.cache['cleanup_interval_hours'];
    _cleanupTimer = Timer.periodic(
      Duration(hours: intervalHours),
      (_) => _cleanupOldFiles(),
    );
  }

  // Public download methods
  Future<String> downloadAsset({
    required String url,
    required String fileName,
    required AssetType type,
    Map<String, dynamic> metadata = const {},
    String? quality,
    Function(double progress)? onProgress,
    Function(DownloadStatus status)? onStatusChange,
    Function(String filePath)? onComplete,
    Function(String error)? onError,
  }) async {
    final taskId = _generateTaskId(url, fileName);
    
    // Check if already downloaded
    final existingPath = await _getLocalPath(fileName, type);
    if (existingPath != null && await File(existingPath).exists()) {
      onComplete?.call(existingPath);
      return existingPath;
    }

    // Create download task
    final task = DownloadTask(
      id: taskId,
      url: _optimizeUrlForDevice(url, type, quality),
      fileName: fileName,
      type: type,
      metadata: metadata,
      quality: quality ?? _getDefaultQuality(type),
      onProgress: onProgress,
      onStatusChange: onStatusChange,
      onComplete: onComplete,
      onError: onError,
    );

    _activeDownloads[taskId] = task;
    _downloadQueue.add(task);
    
    // Start download if we have capacity
    _processQueue();
    
    return taskId;
  }

  Future<String> downloadImage(
    String url, {
    String? fileName,
    String? quality,
    Function(double progress)? onProgress,
    Function(DownloadStatus status)? onStatusChange,
    Function(String filePath)? onComplete,
    Function(String error)? onError,
  }) async {
    return downloadAsset(
      url: url,
      fileName: fileName ?? _extractFileName(url) ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      type: AssetType.image,
      quality: quality,
      onProgress: onProgress,
      onStatusChange: onStatusChange,
      onComplete: onComplete,
      onError: onError,
    );
  }

  Future<String> downloadVideo(
    String url, {
    String? fileName,
    String? quality,
    Function(double progress)? onProgress,
    Function(DownloadStatus status)? onStatusChange,
    Function(String filePath)? onComplete,
    Function(String error)? onError,
  }) async {
    return downloadAsset(
      url: url,
      fileName: fileName ?? _extractFileName(url) ?? 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
      type: AssetType.video,
      quality: quality,
      onProgress: onProgress,
      onStatusChange: onStatusChange,
      onComplete: onComplete,
      onError: onError,
    );
  }

  Future<String> downloadDocument(
    String url, {
    String? fileName,
    Function(double progress)? onProgress,
    Function(DownloadStatus status)? onStatusChange,
    Function(String filePath)? onComplete,
    Function(String error)? onError,
  }) async {
    return downloadAsset(
      url: url,
      fileName: fileName ?? _extractFileName(url) ?? 'document_${DateTime.now().millisecondsSinceEpoch}.pdf',
      type: AssetType.document,
      onProgress: onProgress,
      onStatusChange: onStatusChange,
      onComplete: onComplete,
      onError: onError,
    );
  }

  // Queue management
  void _processQueue() {
    final maxConcurrent = _assetConfig.getMaxConcurrentDownloads();
    
    while (_currentConcurrentDownloads < maxConcurrent && _downloadQueue.isNotEmpty) {
      final task = _downloadQueue.removeAt(0);
      _currentConcurrentDownloads++;
      _executeDownload(task);
    }
  }

  Future<void> _executeDownload(DownloadTask task) async {
    try {
      task.updateStatus(DownloadStatus.downloading);
      
      final saveDir = await _getDownloadDirectory(task.type);
      final savePath = '$saveDir/${task.fileName}';
      
      // Ensure directory exists
      await Directory(saveDir).create(recursive: true);
      
      // Download with progress tracking
      await _dio.download(
        task.url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final progress = received / total;
            task.updateProgress(progress);
          }
        },
        options: Options(
          headers: _getHeadersForAssetType(task.type),
        ),
      );

      // Update task and move to completed
      task.localPath = savePath;
      task.updateStatus(DownloadStatus.completed);
      task.onComplete?.call(savePath);
      
      _completedDownloads[task.id] = task;
      _activeDownloads.remove(task.id);
      
    } catch (e) {
      task.errorMessage = e.toString();
      task.updateStatus(DownloadStatus.failed, error: e.toString());
      
      _failedDownloads[task.id] = task;
      _activeDownloads.remove(task.id);
      
      debugPrint('Download failed for ${task.fileName}: $e');
    } finally {
      _currentConcurrentDownloads--;
      _processQueue(); // Process next in queue
    }
  }

  // URL optimization for device
  String _optimizeUrlForDevice(String url, AssetType type, String? quality) {
    if (!url.contains('?')) return url;
    
    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters);
    
    // Add quality parameters based on device capabilities
    switch (type) {
      case AssetType.image:
        params['quality'] = quality ?? _assetConfig.getImageQuality();
        params['max_width'] = _assetConfig.getMaxImageSize().toString();
        params['format'] = _assetConfig.getImageFormats().first;
        break;
      case AssetType.video:
        params['quality'] = quality ?? _assetConfig.getVideoQuality();
        params['max_bitrate'] = _assetConfig.videos['max_bitrate'].toString();
        break;
      case AssetType.audio:
        params['bitrate'] = _assetConfig.getAudioBitrate().toString();
        params['quality'] = _assetConfig.getAudioQuality();
        break;
      default:
        break;
    }
    
    return uri.replace(queryParameters: params).toString();
  }

  String _getDefaultQuality(AssetType type) {
    switch (type) {
      case AssetType.image:
        return _assetConfig.getImageQuality();
      case AssetType.video:
        return _assetConfig.getVideoQuality();
      case AssetType.audio:
        return _assetConfig.getAudioQuality();
      default:
        return 'medium';
    }
  }

  Map<String, String> _getHeadersForAssetType(AssetType type) {
    final headers = <String, String>{};
    
    switch (type) {
      case AssetType.image:
        headers['Accept'] = 'image/${_assetConfig.getImageFormats().join(', image/')}';
        break;
      case AssetType.video:
        headers['Accept'] = 'video/${_assetConfig.getVideoFormats().join(', video/')}';
        break;
      case AssetType.audio:
        headers['Accept'] = 'audio/${_assetConfig.audio['formats'].join(', audio/')}';
        break;
      default:
        headers['Accept'] = '*/*';
    }
    
    return headers;
  }

  // File management
  Future<String> _getDownloadDirectory(AssetType type) async {
    final directory = await getApplicationDocumentsDirectory();
    final basePath = '${directory.path}/assets';
    
    switch (type) {
      case AssetType.image:
        return '$basePath/images';
      case AssetType.video:
        return '$basePath/videos';
      case AssetType.audio:
        return '$basePath/audio';
      case AssetType.document:
        return '$basePath/documents';
      case AssetType.font:
        return '$basePath/fonts';
      default:
        return '$basePath/other';
    }
  }

  Future<String?> _getLocalPath(String fileName, AssetType type) async {
    try {
      final dir = await _getDownloadDirectory(type);
      final path = '$dir/$fileName';
      if (await File(path).exists()) {
        return path;
      }
    } catch (e) {
      debugPrint('Error checking local path: $e');
    }
    return null;
  }

  // Utility methods
  String _generateTaskId(String url, String fileName) {
    return '${url.hashCode}_${fileName.hashCode}';
  }

  String? _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cleanupOldFiles() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final assetsDir = Directory('${documentsDir.path}/assets');
      
      if (!await assetsDir.exists()) return;
      
      final now = DateTime.now();
      final maxAge = Duration(days: 30); // Clean up files older than 30 days
      
      await for (final entity in assetsDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          if (now.difference(stat.modified) > maxAge) {
            await entity.delete();
            debugPrint('Cleaned up old file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }

  // Public control methods
  void pauseDownload(String taskId) {
    final task = _activeDownloads[taskId];
    if (task != null && task.status == DownloadStatus.downloading) {
      task.updateStatus(DownloadStatus.paused);
    }
  }

  void resumeDownload(String taskId) {
    final task = _activeDownloads[taskId];
    if (task != null && task.status == DownloadStatus.paused) {
      _downloadQueue.add(task);
      _processQueue();
    }
  }

  void cancelDownload(String taskId) {
    final task = _activeDownloads[taskId];
    if (task != null) {
      task.updateStatus(DownloadStatus.cancelled);
      _activeDownloads.remove(taskId);
      _currentConcurrentDownloads--;
      _processQueue();
    }
  }

  void retryDownload(String taskId) {
    final task = _failedDownloads[taskId];
    if (task != null) {
      task.retryCount++;
      task.updateStatus(DownloadStatus.pending);
      _failedDownloads.remove(taskId);
      _activeDownloads[taskId] = task;
      _downloadQueue.add(task);
      _processQueue();
    }
  }

  // Status methods
  DownloadTask? getTask(String taskId) {
    return _activeDownloads[taskId] ?? 
           _completedDownloads[taskId] ?? 
           _failedDownloads[taskId];
  }

  List<DownloadTask> getActiveDownloads() {
    return _activeDownloads.values.toList();
  }

  List<DownloadTask> getCompletedDownloads() {
    return _completedDownloads.values.toList();
  }

  List<DownloadTask> getFailedDownloads() {
    return _failedDownloads.values.toList();
  }

  Future<int> getCacheSize() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final assetsDir = Directory('${documentsDir.path}/assets');
      
      if (!await assetsDir.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in assetsDir.list(recursive: true)) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('Error calculating cache size: $e');
      return 0;
    }
  }

  Future<void> clearCache() async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final assetsDir = Directory('${documentsDir.path}/assets');
      
      if (await assetsDir.exists()) {
        await assetsDir.delete(recursive: true);
        debugPrint('Cache cleared successfully');
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _dio.close();
  }
}

// Custom retry interceptor for Dio
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.retries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;

    if (retryCount < retries && _shouldRetry(err)) {
      extra['retryCount'] = retryCount + 1;
      
      if (retryCount < retryDelays.length) {
        await Future.delayed(retryDelays[retryCount]);
      }
      
      try {
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue with error if retry fails
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && 
            err.response!.statusCode! >= 500);
  }
}
