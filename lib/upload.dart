import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'result.dart';
import 'processing.dart';
import 'config.dart';

class UploadPage extends StatefulWidget {
  final String imagePath;

  const UploadPage({super.key, required this.imagePath});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  late String _imagePath;

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
      final stopwatch = Stopwatch()..start();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.apiBaseUrl}/predict'),
      );

      final imageFile = XFile(_imagePath);
      final imageBytes = await imageFile.readAsBytes();

      // Determine content type based on file extension
      String extension = imageFile.path.split('.').last.toLowerCase();
      String imageType = 'png'; // default
      if (extension == 'jpg' || extension == 'jpeg') {
        imageType = 'jpeg';
      } else if (extension == 'png') {
        imageType = 'png';
      } else if (extension == 'gif') {
        imageType = 'gif';
      } else if (extension == 'bmp') {
        imageType = 'bmp';
      } else if (extension == 'webp') {
        imageType = 'webp';
      }

      request.files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'upload.$extension',
        contentType: http_parser.MediaType('image', imageType),
      ));

      var response = await request.send();

      if (response.statusCode == 200) {
        stopwatch.stop();
        var responseData = await response.stream.bytesToString();
        var decoded = json.decode(responseData);

        var predictionValue = (decoded['prediction'] as num).toDouble();
        var elapsed = stopwatch.elapsedMilliseconds / 1000;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              prediction: predictionValue,
              analysisTime: elapsed.toStringAsFixed(2),
            ),
          ),
        );
      } else {
        var body = await response.stream.bytesToString();
        throw Exception('Server returned ${response.statusCode}: $body');
      }
    } catch (e) {
      print('Error processing image: $e');
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
