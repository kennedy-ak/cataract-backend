import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';

/// Service for background syncing of predictions to backend
class BackgroundSyncService {
  // Backend URL - use 10.0.2.2 for Android emulator
  static const String _baseUrl = 'http://10.0.2.2:8080';
  static const String _uploadEndpoint = '/api/training-data';

  static const int _maxRetries = 3;
  static const int _batchSize = 5; // Upload 5 records at a time

  final LocalStorageService _storageService = LocalStorageService();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isSyncing = false;
  bool _autoSyncEnabled = true;

  /// Get singleton instance
  static final BackgroundSyncService _instance = BackgroundSyncService._internal();
  factory BackgroundSyncService() => _instance;
  BackgroundSyncService._internal();

  /// Initialize sync service
  Future<void> initialize() async {
    // Load auto-sync preference
    final prefs = await SharedPreferences.getInstance();
    _autoSyncEnabled = prefs.getBool('auto_sync_enabled') ?? true;

    // Listen for connectivity changes
    _connectivityService.connectionStream.listen((isConnected) {
      if (isConnected && _autoSyncEnabled && !_isSyncing) {
        print('Connection restored - starting auto-sync');
        syncPendingData();
      }
    });

    // Try initial sync if connected
    if (_connectivityService.isConnected && _autoSyncEnabled) {
      syncPendingData();
    }
  }

  /// Set auto-sync enabled/disabled
  Future<void> setAutoSyncEnabled(bool enabled) async {
    _autoSyncEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_sync_enabled', enabled);

    if (enabled && _connectivityService.isConnected && !_isSyncing) {
      syncPendingData();
    }
  }

  /// Get auto-sync status
  bool get isAutoSyncEnabled => _autoSyncEnabled;

  /// Sync all pending predictions to backend
  Future<void> syncPendingData() async {
    if (_isSyncing || !_autoSyncEnabled) return;

    if (!_connectivityService.isConnected) {
      print('No internet connection - skipping sync');
      return;
    }

    _isSyncing = true;
    print('Starting background sync...');

    try {
      // Get pending uploads
      List<PredictionRecord> pendingRecords = await _storageService.getPendingUploads();

      // Also retry failed uploads (up to max retries)
      List<PredictionRecord> failedRecords = await _storageService.getFailedUploads();
      failedRecords = failedRecords.where((r) => r.retryCount < _maxRetries).toList();

      List<PredictionRecord> allRecords = [...pendingRecords, ...failedRecords];

      if (allRecords.isEmpty) {
        print('No pending records to sync');
        _isSyncing = false;
        return;
      }

      print('Found ${allRecords.length} records to sync');

      // Upload in batches
      int successCount = 0;
      int failCount = 0;

      for (int i = 0; i < allRecords.length; i += _batchSize) {
        int end = (i + _batchSize < allRecords.length) ? i + _batchSize : allRecords.length;
        List<PredictionRecord> batch = allRecords.sublist(i, end);

        for (var record in batch) {
          try {
            await _uploadRecord(record);
            successCount++;
          } catch (e) {
            print('Failed to upload record ${record.id}: $e');
            failCount++;
          }
        }
      }

      print('Sync completed: $successCount succeeded, $failCount failed');
    } catch (e) {
      print('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Upload a single prediction record
  Future<void> _uploadRecord(PredictionRecord record) async {
    if (record.id == null) return;

    // Mark as uploading
    await _storageService.updateUploadStatus(record.id!, 'uploading');

    try {
      // Read image file
      final imageFile = File(record.imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file not found: ${record.imagePath}');
      }

      // Prepare multipart request
      final uri = Uri.parse('$_baseUrl$_uploadEndpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          record.imagePath,
          filename: record.imagePath.split('/').last,
        ),
      );

      // Add metadata as JSON
      request.fields['metadata'] = json.encode({
        'prediction': record.prediction,
        'predictedClass': record.predictedClass,
        'className': record.className,
        'confidence': record.confidence,
        'inferenceTime': record.inferenceTime,
        'timestamp': record.timestamp,
        'deviceInfo': {
          'platform': Platform.operatingSystem,
          'version': Platform.operatingSystemVersion,
        },
      });

      // Send request
      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Upload timeout');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Upload successful - mark as uploaded and delete
        await _storageService.updateUploadStatus(record.id!, 'uploaded');
        await _storageService.deletePrediction(record.id!);
        print('Successfully uploaded record ${record.id}');
      } else {
        throw Exception('Server returned status ${response.statusCode}');
      }
    } catch (e) {
      // Upload failed - update retry count
      final newRetryCount = record.retryCount + 1;
      await _storageService.updateUploadStatus(
        record.id!,
        newRetryCount >= _maxRetries ? 'failed' : 'pending',
        retryCount: newRetryCount,
      );
      print('Upload failed for record ${record.id} (retry $newRetryCount/$_maxRetries): $e');
      rethrow;
    }
  }

  /// Get sync status
  bool get isSyncing => _isSyncing;

  /// Get pending upload count
  Future<int> getPendingCount() async {
    return await _storageService.getPendingCount();
  }
}
