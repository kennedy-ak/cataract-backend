import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'upload.dart';
import 'package:bulleted_list/bulleted_list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
          stops: [0.5, 2.0], // Add stops to control the space distribution
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
                // decoration: BoxDecoration(
                //   border: Border.all(
                //     color: Colors.white,
                //     width: 2,
                //   ),
                //   borderRadius: BorderRadius.circular(10),
                // ),
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
          // SingleChildScrollView(
          // child:
          Container(
            // height: 1400,
            alignment: Alignment.center,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BulletedList(
                  listItems: [
                    'Take the picture indoors in a well-lit room',
                    'Remove glasses or contact lenses',
                    'Hold the rear camera at eye level',
                    "Use the camera's flash or a bright light",
                    'Keep the camera steady - the image should not be blurry',
                    'Open your eyes wide',
                  ],
                  // listOrder: ListOrder.ordered,
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
          // ),
          // Container(
          //   child: ListView(
          //     shrinkWrap: true,
          //     children: const [
          //       ListTile(
          //         title: Text(
          //           '1. Take the picture indoors in a well-lit room',
          //           style: TextStyle(
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //       ListTile(
          //         title: Text('2. Remove glasses or contact lenses',
          //             style: TextStyle(
          //               color: Colors.white,
          //             )),
          //       ),
          //       ListTile(
          //         title: Text('3. Hold the rear camera at eye level',
          //             style: TextStyle(
          //               color: Colors.white,
          //             )),
          //       ),
          //       ListTile(
          //         title: Text("4. Use the camera's flash or a bright light",
          //             style: TextStyle(
          //               color: Colors.white,
          //             )),
          //       ),
          //       ListTile(
          //         title: Text(
          //             '5. Keep the camera steady - the image should not be blurry',
          //             style: TextStyle(
          //               color: Colors.white,
          //             )),
          //       ),
          //       ListTile(
          //         title: Text('6. Open your eyes wide',
          //             style: TextStyle(
          //               color: Colors.white,
          //             )),
          //       ),
          //     ],
          //   ),
          // ),
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

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cataract Detection',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const ResultPage(),
//     );
//   }
// }

// class ResultPage extends StatelessWidget {
//   const ResultPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Back', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           style:
//               ButtonStyle(iconColor: MaterialStateProperty.all(Colors.white)),
//           onPressed: () {
//             // Handle back button press
//           },
//         ),
//       ),
//       extendBodyBehindAppBar: true,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color.fromARGB(255, 44, 137, 218),
//               Color.fromARGB(179, 250, 247, 247),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   'Cataract Detected⚠️',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'You are advised to consult your eye specialist',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Kindly note that this should not be used as a sole diagnostic tool',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontStyle: FontStyle.italic,
//                     color: Colors.white70,
//                   ),
//                 ),
//                 const SizedBox(height: 50),
//                 ElevatedButton(
//                   onPressed: () {
//                     // Handle download result button press
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black, // button background color
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 15),
//                   ),
//                   child: const Text(
//                     'Download Result',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
