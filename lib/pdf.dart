// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;

// import 'package:file_saver/file_saver.dart';
// import 'package:printing/printing.dart';

// class PdfSaveExample extends StatelessWidget {
//   const PdfSaveExample({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Save PDF Example')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             final pdfBytes = await _generatePdf();
//             await _savePdf('MyPDF', pdfBytes);
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('PDF saved successfully!')),
//             );
//           },
//           child: const Text('Save PDF'),
//         ),
//       ),
//     );
//   }

//   Future<Uint8List> _generatePdf() async {
//     final pdf = pw.Document();
//     final font = await PdfGoogleFonts.nunitoExtraLight();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) {
//           return pw.Center(
//             child: pw.Text('Hello PDF!', style: pw.TextStyle(font: font, fontSize: 30)),
//           );
//         },
//       ),
//     );

//     return pdf.save();
//   }

//   Future<void> _savePdf(String name, Uint8List bytes) async {
//     // Save the PDF to visible folder cross-platform
//     await FileSaver.instance.saveFile(
//       name: name,
//       bytes: bytes,
//       fileExtension: "pdf",
//       mimeType: MimeType.pdf,
//     );
//   }
// }
