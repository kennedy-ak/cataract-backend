import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'result.dart';
import 'processing.dart';
// import 'reportgen.dart';

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
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://macro-context-425319-h7.uc.r.appspot.com/predict'));
      final stopwatch = Stopwatch();
      stopwatch.start();
      if (kIsWeb) {
        // For web, read the file as bytes
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          await XFile(_imagePath).readAsBytes(),
          filename: 'upload.png',
        ));
      } else {
        // For mobile, use the file path
        request.files.add(await http.MultipartFile.fromPath(
          'file',
          _imagePath,
        ));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        // var analysisTime;
        stopwatch.stop();
        var elapsed = stopwatch.elapsedMilliseconds / 1000;
        var responseData = await response.stream.bytesToString();
        var decodedResponse = json.decode(responseData);
        var predictionValue =
            double.parse(decodedResponse['prediction'][0][0].toString());
        // print(predictionValue.runtimeType);
        // var analysisTimeValue = decodedResponse['analysis_time'];
        var analysisTimeValue = elapsed.toStringAsFixed(2);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ResultsPage(
                    prediction: predictionValue,
                    analysisTime: analysisTimeValue,
                  )),
        );
      } else {
        print('Failed to upload image: ${response.statusCode}');
        //display an error message to the user
      }
    } catch (e) {
      print('Error uploading image: $e');
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
