import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'upload.dart';
import 'package:bulleted_list/bulleted_list.dart';
import 'widgets/consent_dialog.dart';
import 'services/tflite_model_service.dart';
import 'services/connectivity_service.dart';
import 'services/background_sync_service.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  try {
    if (!kIsWeb) {
      // Only initialize TFLite on mobile (Android/iOS)
      print('Initializing mobile services (TFLite, storage, sync)...');
      final modelService = TFLiteModelService();
      await modelService.initialize();

      // Initialize connectivity monitoring
      final connectivityService = ConnectivityService();
      await connectivityService.initialize();

      // Initialize background sync
      final syncService = BackgroundSyncService();
      await syncService.initialize();

      print('Mobile services initialized successfully');
    } else {
      print('Running on web - TFLite not supported, will use cloud API');
    }
  } catch (e) {
    print('Error initializing services: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Show consent dialog after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showConsentDialogIfNeeded();
    });
  }

  Future<void> _showConsentDialogIfNeeded() async {
    // Only show consent on mobile (where we collect data)
    if (kIsWeb) {
      print('Web platform - no data collection, skipping consent dialog');
      return;
    }

    final bool consented = await ConsentDialog.show(context);
    if (!consented) {
      // User declined - exit app
      exit(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cataract Detection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('i-SpEye'),
        ),
        body: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadPage(imagePath: image.path),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.5, 2.0], // Adding stops to control the space distribution
          colors: [
            Color.fromARGB(255, 12, 131, 200),
            Color.fromARGB(255, 5, 232, 186),
          ],
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Container(
                child: const Image(
                  image: AssetImage(
                    'images/i-Speye.png',
                  ),
                  width: 200,
                  height: 100,
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 20, top: 0),
            child: const Text(
              'For accurate results:',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'InriaSans'),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BulletedList(
                  listItems: [
                    'Take the picture indoors in a well-lit room (preferably by natural light)',
                    'Remove glasses or contact lenses',
                    'Hold the rear camera at eye level',
                    "Use the camera's flash or a bright light if in a poorly lit room",
                    'Keep the camera steady - the image should not be blurry',
                    'Open your eyes wide',
                  ],
                  bulletType: BulletType.conventional,
                  bulletColor: Colors.white,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'InriaSans'),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      onPressed: () => _pickImage(context, ImageSource.camera),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Text(
                          'Take Photo',
                          style: TextStyle(
                              color: Color.fromARGB(255, 13, 71, 161),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'InriaSans'),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: ElevatedButton(
                      onPressed: () => _pickImage(context, ImageSource.gallery),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Background color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                        ),
                        child: Text(
                          'Upload Photo',
                          style: TextStyle(
                              color: Color.fromARGB(255, 13, 71, 161),
                              fontWeight: FontWeight.w700,
                              fontFamily: 'InriaSans'),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}


