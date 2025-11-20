import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'result.dart';
import 'processing.dart';
import 'services/tflite_model_service.dart';
import 'services/local_storage_service.dart';
import 'services/background_sync_service.dart';

class UploadPage extends StatefulWidget {
  final String imagePath;

  const UploadPage({super.key, required this.imagePath});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late String _imagePath;
  late double analysisTime;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.imagePath;
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  Future<void> _uploadImage(BuildContext context) async {
    if (_imagePath.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProcessingPage()),
    );

    try {
      if (kIsWeb) {
        // WEB: Use cloud API (TFLite doesn't work on web)
        print('Running on web - using cloud API');
        await _processWithCloudAPI(context);
      } else {
        // MOBILE: Use local TFLite inference (offline)
        print('Running on mobile - using local TFLite');
        await _processWithTFLite(context);
      }
    } catch (e) {
      print('Error processing image: $e');
      // Navigate back and show error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing image: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  /// Process using local TFLite (Android/iOS only)
  Future<void> _processWithTFLite(BuildContext context) async {
    // Initialize services
    final modelService = TFLiteModelService();
    final storageService = LocalStorageService();
    final syncService = BackgroundSyncService();

    // Read image bytes
    final imageBytes = await File(_imagePath).readAsBytes();

    // Run local inference
    final result = await modelService.predict(imageBytes);

    // Save image to local storage with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'cataract_$timestamp.jpg';
    final savedImagePath = await storageService.saveImage(imageBytes, filename);

    // Create prediction record
    final record = PredictionRecord(
      imagePath: savedImagePath,
      prediction: result['prediction'],
      predictedClass: result['class'],
      className: result['className'],
      confidence: result['confidence'],
      inferenceTime: result['inferenceTime'],
      timestamp: result['timestamp'],
      uploadStatus: 'pending',
    );

    // Save to local database
    await storageService.insertPrediction(record);

    // Trigger background sync if connected
    if (syncService.isAutoSyncEnabled) {
      syncService.syncPendingData().catchError((e) {
        print('Background sync failed: $e');
      });
    }

    // Navigate to results page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          prediction: result['prediction'],
          analysisTime: result['inferenceTime'].toStringAsFixed(2),
        ),
      ),
    );
  }

  /// Process using cloud API (Web platform)
  Future<void> _processWithCloudAPI(BuildContext context) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://macro-context-425319-h7.uc.r.appspot.com/predict'),
    );

    final stopwatch = Stopwatch()..start();

    // Read image as bytes
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      await XFile(_imagePath).readAsBytes(),
      filename: 'upload.png',
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      stopwatch.stop();
      var elapsed = stopwatch.elapsedMilliseconds / 1000;
      var responseData = await response.stream.bytesToString();
      var decodedResponse = json.decode(responseData);
      var predictionValue = double.parse(decodedResponse['prediction'][0][0].toString());
      var analysisTimeValue = elapsed.toStringAsFixed(2);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(
            prediction: predictionValue,
            analysisTime: analysisTimeValue,
          ),
        ),
      );
    } else {
      throw Exception('Cloud API returned status ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Upload Image',
          style: TextStyle(fontFamily: 'InriaSans'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.5, 2.0],
            colors: [
              Color.fromARGB(255, 12, 131, 200),
              Color.fromARGB(255, 5, 232, 186),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                width: 300,
                height: 300,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(30),
                // ),
                child: kIsWeb
                    ? Image.network(
                        _imagePath,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(_imagePath),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Re-take Photo',
                    style: TextStyle(
                        color: Color.fromARGB(255, 13, 71, 161),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'InriaSans'),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Re-select Image',
                      style: TextStyle(
                          color: Color.fromARGB(255, 13, 71, 161),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'InriaSans')),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _uploadImage(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Continue with diagnosis',
                  style: TextStyle(
                      color: Color.fromARGB(255, 13, 71, 161),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'InriaSans')),
            ),
          ],
        ),
      ),
    );
  }
}
