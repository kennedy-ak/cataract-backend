import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
// import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> generatePdfReport(String content, BuildContext context) async {
  final pdf = pw.Document();
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Text(content, style: const pw.TextStyle(fontSize: 12)),
        );
      },
    ),
  );

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/diagnosis_report.pdf");
  await file.writeAsBytes(await pdf.save());

  // Open the PDF file
  // Printing.sharePdf(bytes: await pdf.save(), filename: 'diagnosis_report.pdf');
}

String generateReportContent(String diagnosis, String analysisTime, List<String> pastDiagnoses) {
  StringBuffer buffer = StringBuffer();
  buffer.writeln("------------------------------------");
  buffer.writeln("Diagnosis Report");
  buffer.writeln("------------------------------------");
  buffer.writeln("");
  buffer.writeln("Date: ${DateTime.now().toLocal().toString().split(' ')[0]}");
  buffer.writeln("Time: ${DateTime.now().toLocal().toString().split(' ')[1]}");
  buffer.writeln("");
  buffer.writeln("Diagnosis: $diagnosis");
  buffer.writeln("Analysis Time: $analysisTime");
  buffer.writeln("");
  buffer.writeln("Recommendations:");
  buffer.writeln("- You are advised to consult your eye specialist.");
  buffer.writeln("- Kindly note that this should not be used as a sole diagnostic tool.");
  buffer.writeln("");
  buffer.writeln("Additional Notes:");
  buffer.writeln("- [Any user-added notes or comments]");
  buffer.writeln("");
  buffer.writeln("------------------------------------");
  
  buffer.writeln("");
  buffer.writeln("------------------------------------");
  buffer.writeln("Technical Details");
  buffer.writeln("------------------------------------");
  buffer.writeln("- Model Used: [Model Name/Version]");
  buffer.writeln("- Analysis Time: $analysisTime");
  buffer.writeln("- Accuracy: [Model Accuracy]");
  buffer.writeln("");
  buffer.writeln("------------------------------------");

  return buffer.toString();
}
