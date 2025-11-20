import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

/// Service for running TFLite inference locally on device
class TFLiteModelService {
  static const String _modelAsset = 'resnet50_cataract_99percent_float16.tflite';
  static const int _inputSize = 224;
  static const double _threshold = 0.5;

  bool _isInitialized = false;

  /// Get singleton instance
  static final TFLiteModelService _instance = TFLiteModelService._internal();
  factory TFLiteModelService() => _instance;
  TFLiteModelService._internal();

  /// Initialize the TFLite interpreter
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Tflite.loadModel(
        model: _modelAsset,
        numThreads: 4,
      );
      _isInitialized = true;
      print('TFLite model loaded successfully');
    } catch (e) {
      print('Error loading TFLite model: $e');
      throw Exception('Failed to load TFLite model: $e');
    }
  }

  /// Run inference on image file path
  /// Returns prediction result with probability, class, and confidence
  Future<Map<String, dynamic>> predict(Uint8List imageBytes) async {
    if (!_isInitialized) {
      await initialize();
    }

    final stopwatch = Stopwatch()..start();

    try {
      // Save image bytes to temporary file (tflite_v2 requires file path)
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.jpg');
      await tempFile.writeAsBytes(imageBytes);

      // Preprocess image to 224x224
      final processedImagePath = await _preprocessImage(tempFile.path);

      // Run inference
      var recognitions = await Tflite.runModelOnImage(
        path: processedImagePath,
        numResults: 1,
        threshold: 0.0,
        imageMean: 0.0,
        imageStd: 255.0,
      );

      stopwatch.stop();
      final inferenceTime = stopwatch.elapsedMilliseconds / 1000.0;

      // Clean up temp files
      await tempFile.delete();
      await File(processedImagePath).delete();

      if (recognitions == null || recognitions.isEmpty) {
        throw Exception('No prediction result');
      }

      // Parse result
      // tflite_v2 returns confidence value directly
      final probability = recognitions[0]['confidence'] as double;

      // Determine class (1 = Cataract, 0 = Normal)
      final predictedClass = probability > _threshold ? 1 : 0;
      final className = predictedClass == 1 ? 'Cataract' : 'Normal';

      // Calculate confidence
      final confidence = predictedClass == 1 ? probability : (1 - probability);

      return {
        'prediction': probability,
        'class': predictedClass,
        'className': className,
        'confidence': confidence * 100,
        'inferenceTime': inferenceTime,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error during inference: $e');
      throw Exception('Inference failed: $e');
    }
  }

  /// Preprocess image to 224x224 RGB
  Future<String> _preprocessImage(String imagePath) async {
    // Read image
    final imageFile = File(imagePath);
    final imageBytes = await imageFile.readAsBytes();

    // Decode image
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Resize to 224x224
    img.Image resized = img.copyResize(image, width: _inputSize, height: _inputSize);

    // Save processed image
    final tempDir = await getTemporaryDirectory();
    final processedPath = '${tempDir.path}/processed_image.jpg';
    final processedFile = File(processedPath);
    await processedFile.writeAsBytes(img.encodeJpg(resized));

    return processedPath;
  }

  /// Dispose of the interpreter
  Future<void> dispose() async {
    await Tflite.close();
    _isInitialized = false;
  }
}
