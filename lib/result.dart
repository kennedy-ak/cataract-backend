import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'dart:typed_data';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

class ResultsPage extends StatelessWidget {
  final double prediction;
  final String analysisTime;

  const ResultsPage(
      {super.key, required this.prediction, required this.analysisTime});

  Future<void> downloadReport(Uint8List pdfBytes, BuildContext context) async {
    if (Platform.isAndroid) {
      await downloadReportMobile(pdfBytes, context);
    } else if (Platform.isIOS) {
      await downloadReportIOS(pdfBytes, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unsupported platform')),
      );
    }
  }

  Future<void> downloadReportMobile(
      Uint8List pdfBytes, BuildContext context) async {
    // Request necessary permissions
    try {
      PermissionStatus storageStatus =
          await Permission.manageExternalStorage.status;
      PermissionStatus manageStorageStatus =
          await Permission.manageExternalStorage.status;

      if (!storageStatus.isGranted || !manageStorageStatus.isGranted) {
        storageStatus = await Permission.manageExternalStorage.request();
        manageStorageStatus = await Permission.manageExternalStorage.request();
      }

      if (storageStatus.isGranted && manageStorageStatus.isGranted) {
        // Define the path to the common Downloads directory
        const path = '/storage/emulated/0/Download';
        final dir = Directory(path);

        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        final file = File('$path/diagnosis_report.pdf');
        await file.writeAsBytes(pdfBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report downloaded successfully!')),
        );

        OpenFilex.open(file.path);

      } else if (storageStatus.isPermanentlyDenied ||
          manageStorageStatus.isPermanentlyDenied) {
        openAppSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Storage permission permanently denied. Please enable it in settings.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Error downloading report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download report: $e')),
      );
    }
  }

  Future<void> downloadReportIOS(
      Uint8List pdfBytes, BuildContext context) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/diagnosis_report.pdf');
    await file.writeAsBytes(pdfBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report downloaded successfully!')),
    );

    OpenFilex.open(file.path);
  }

  Future<void> _createAndDownloadReport(BuildContext context) async {
    final pdf = pw.Document();

    double confidence =
        prediction > 0.7 ? (prediction * 100) : ((1 - prediction) * 100);

    
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Diagnosis Report',
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text(
                'Date: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                style: const pw.TextStyle(fontSize: 18),
              ),
              pw.Text(
                'Time: ${DateTime.now().toLocal().toString().split(' ')[1].split('.')[0]}',
                style: const pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                prediction < 0.7
                    ? 'Diagnosis: Cataract Detected'
                    : 'Diagnosis: No Cataract Detected',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Analysis Time: $analysisTime seconds',
                style: const pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Recommendation:',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Bullet(
                  text:
                      'This app is a screening tool and has limitations in detecting cataracts. A comprehensive eye exam by a qualified ophthalmologist is necessary for a more accurate diagnosis.',
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Technical Details:',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                prediction < 0.7
                    ? '- Certainty of diagnosis: ${confidence.toStringAsFixed(2)} %'
                    : '- Certainty of diagnosis: ${confidence.toStringAsFixed(2)} %',
                style: const pw.TextStyle(fontSize: 15),
              ),
              pw.Text(
                '- Accuracy of model: 96%',
                style: const pw.TextStyle(fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
    try {
      if (kIsWeb) {
        final now = DateTime.now();
        final date = DateTime.now().toLocal().toString().split(' ')[0];
        final time =
            "${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}_${now.second.toString().padLeft(2, '0')}";

        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'diagnosis_report_${date}_$time.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report downloaded successfully!')),
        );
      } else if (Platform.isAndroid) {
        final bytes = await pdf.save();
        final now = DateTime.now();
        final directory = Directory('/storage/emulated/0/Download');
        final date = DateTime.now().toLocal().toString().split(' ')[0];
        final time =
            "${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}_${now.second.toString().padLeft(2, '0')}";

        final file =
            File('${directory.path}/diagnosis_report_${date}_$time.pdf');
        final path = '${directory.path}/diagnosis_report_${date}_$time.pdf';
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report downloaded successfully! Path:$path')),
        );
        OpenFilex.open(path);
        
      } else {
        final now = DateTime.now();
        final directory = await getApplicationDocumentsDirectory();
        final date = DateTime.now().toLocal().toString().split(' ')[0];
        final time =
            "${now.hour.toString().padLeft(2, '0')}_${now.minute.toString().padLeft(2, '0')}_${now.second.toString().padLeft(2, '0')}";

        final file =
            File('${directory.path}/diagnosis_report_${date}_$time.pdf');
        await file.writeAsBytes(await pdf.save());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Report downloaded successfully! path: ${file.path}')),
        );

        OpenFilex.open(file.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isCataractDetected = prediction < 0.7;
    double confidence =
        prediction > 0.7 ? (prediction * 100) : ((1 - prediction) * 100);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.5, 2.0],
            colors: [
              Color(0xff087ee1),
              Color(0xff05e8ba),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Image(
                  image: AssetImage(
                    isCataractDetected
                        ? 'images/warning.png'
                        : 'images/check.png',
                  ),
                  width: 200,
                  height: 100,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Stack(
                children: [
                  Text(
                    isCataractDetected
                        ? 'Cataract Detected'
                        : 'No Cataract Detected',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'InriaSans',
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color =
                            isCataractDetected ? Colors.red : Colors.green,
                    ),
                  ),
                  Text(
                    isCataractDetected
                        ? 'Cataract Detected'
                        : 'No Cataract Detected',
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'InriaSans',
                        color: Colors.white),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'You are advised to consult your eye specialist',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'InriaSans'),
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'Kindly note that this should not be used as a sole diagnostic tool',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decorationColor: Colors.white,
                    fontFamily: 'InriaSans'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _createAndDownloadReport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Download Result',
                  style: TextStyle(
                      color: Color.fromARGB(255, 13, 71, 161),
                      fontWeight: FontWeight.w700,
                      fontFamily: 'InriaSans'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
