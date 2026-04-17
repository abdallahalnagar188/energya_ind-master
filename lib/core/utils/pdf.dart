import 'dart:io';
import 'package:energya_ind/core/helper/providers/excel_provider.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

Future<void> generateFilteredPdf(
  BuildContext context,
  List<List<dynamic>> filteredData,
  String name,
  ExcelProvider ex,
) async {
  final pdf = pw.Document();
  const int rowsPerPage = 50;
  final ByteData image = await rootBundle.load("images/logo.png");
  Uint8List imageData = (image).buffer.asUint8List();
  double s = 28;

  final doneSet = ex.doneExcelData.skip(1).map((e) => e.join()).toSet();
  final remaining = ex.allExcelData.skip(1).where((item) {
    return !doneSet.contains(item.join());
  }).toList();

  pw.Container container(
    String header,
    List<List<String>> filter, {
    int? index,
    List<List<String>>? another,
  }) {
    print('Header: $header');
    print('Filter: $filter');
    print('Another: $another');

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: PdfColors.grey100,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$header :',
            style: pw.TextStyle(
              fontSize: s,
            ),
          ),
          pw.Text(
            ex.getAllTotalsToPrint(filter, index: index, another: another),
            style: pw.TextStyle(
              fontSize: s,
            ),
          ),
        ],
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      pageTheme: const pw.PageTheme(
        margin: pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat(595.28, 1400),
      ),
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Row(
              children: [
                pw.Image(pw.MemoryImage(imageData), height: 100, width: 100),
                pw.SizedBox(width: 20),
                pw.Flexible(
                  child: pw.Text(
                    'Energya Steel Fabrication',
                    style: pw.TextStyle(
                      fontSize: 26,
                      color: PdfColor.fromHex('#032352'),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "General Report",
              style: pw.TextStyle(
                fontSize: 40,
                color: PdfColor.fromHex('#032352'),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              name,
              style: pw.TextStyle(
                fontSize: 28,
                color: PdfColor.fromHex('#032352'),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  container(
                    'All Marks',
                    ex.allExcelData,
                  ),
                  container(
                    'Hold Marks',
                    ex.holdExcelData,
                  ),
                  container(
                    'Under-Prepration Marks',
                    ex.underExcelData,
                    index: 0,
                  ),
                  container(
                    'Under-Assembly Marks',
                    ex.underExcelData,
                    index: 1,
                  ),
                  container(
                    'Under-Welding Marks',
                    ex.underExcelData,
                    index: 2,
                  ),
                  container(
                    'Under-Visual Marks',
                    ex.underExcelData,
                    index: 3,
                  ),
                  container(
                    'Production-Done Marks',
                    ex.doneExcelData,
                    index: 3,
                    another: ex.doneExcelData,
                  ),
                  container(
                    'Production-Remaining Marks',
                    [ex.headerRow] + remaining,
                    index: 3,
                    another: [ex.headerRow] + remaining,
                  ),
                  container(
                    'Under-Follow up Marks',
                    ex.underExcelData,
                    index: 4,
                  ),
                  container(
                    'Under-Painting Marks',
                    ex.underExcelData,
                    index: 5,
                  ),
                  container(
                    'Under-Galvanization Marks',
                    ex.underExcelData,
                    index: 7,
                  ),
                  container(
                    'Dispatch-Yard Marks',
                    ex.underExcelData,
                    index: 6,
                  ),
                  container('Dispatched Marks', ex.dispatchedExcelData),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  for (int i = 0; i < filteredData.length; i += rowsPerPage) {
    final rows = filteredData.skip(i).take(rowsPerPage).toList();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.TableHelper.fromTextArray(
            headers: filteredData.isNotEmpty
                ? filteredData.first.map((e) => e.toString()).toList()
                : [],
            data: rows
                .skip(1)
                .toList()
                .map((row) => row.map((cell) => cell.toString()).toList())
                .toList(),
          );
        },
      ),
    );
  }

  final output = await getTemporaryDirectory();
  final file = File("${output.path}/$name.pdf");
  await file.writeAsBytes(await pdf.save());
  print('file path: ${file.path}');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text(name)),
        body: PdfPreview(
          build: (format) => pdf.save(),
          allowPrinting: true,
          allowSharing: true,
        ),
      ),
    ),
  );
}

Future<void> generateProjectFullReport(
  BuildContext context,
  String projectName,
  Map<String, double> aggregatedWeights,
) async {
  final pdf = pw.Document();
  final ByteData image = await rootBundle.load("images/logo.png");
  Uint8List imageData = (image).buffer.asUint8List();
  double s = 28;

  pw.Container container(String header, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: PdfColors.grey100,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '$header :',
            style: pw.TextStyle(
              fontSize: s,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: s,
            ),
          ),
        ],
      ),
    );
  }

  pdf.addPage(
    pw.Page(
      pageTheme: const pw.PageTheme(
        margin: pw.EdgeInsets.all(20),
        pageFormat: PdfPageFormat(595.28, 1400),
      ),
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Row(
              children: [
                pw.Image(pw.MemoryImage(imageData), height: 100, width: 100),
                pw.SizedBox(width: 20),
                pw.Flexible(
                  child: pw.Text(
                    'Energya Steel Fabrication',
                    style: pw.TextStyle(
                      fontSize: 26,
                      color: PdfColor.fromHex('#032352'),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              "General Report",
              style: pw.TextStyle(
                fontSize: 40,
                color: PdfColor.fromHex('#032352'),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Text(
              projectName,
              style: pw.TextStyle(
                fontSize: 28,
                color: PdfColor.fromHex('#032352'),
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 30),
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  container('Total Weight', '${aggregatedWeights['Total']}'),
                  container('Hold Marks', '${aggregatedWeights['Hold Marks']}'),
                  pw.SizedBox(height: 30),
                  container('Under Cutting', '${aggregatedWeights['Under Cutting'] ?? 0.0}'),
                  container('Under Preparation', '${aggregatedWeights['Under Preparation'] ?? 0.0}'),
                  container('Under Assembly', '${aggregatedWeights['Under Assembly'] ?? 0.0}'),
                  container('Under Welding', '${aggregatedWeights['Under Welding'] ?? 0.0}'),
                  container('Under Visual', '${aggregatedWeights['Under Visual'] ?? 0.0}'),
                  container('Production-Done Marks', '${aggregatedWeights['Production-Done Marks']}'),
                  container('Production-Remaining Marks', '${aggregatedWeights['Production-Remaining Marks']}'),
                  container('Under Follow up', '${aggregatedWeights['Under Follow up'] ?? 0.0}'),
                  container('Under Painting', '${aggregatedWeights['Under Painting'] ?? 0.0}'),
                  container('Under Galvanization', '${aggregatedWeights['Under Galvanization'] ?? 0.0}'),
                  container('Dispatch Yard', '${aggregatedWeights['Dispatch Yard'] ?? 0.0}'),
                  pw.SizedBox(height: 30),
                  container('Dispatched (Done Weight)', '${aggregatedWeights['Done']}'),
                  container('Remaining Weight', '${aggregatedWeights['Remaining']}'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  final output = await getTemporaryDirectory();
  final sanitizedProjectName = projectName.replaceAll(' ', '_');
  final file = File("${output.path}/${sanitizedProjectName}_Full_Report.pdf");
  await file.writeAsBytes(await pdf.save());
  print('file path: ${file.path}');
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: Text('$projectName Report')),
        body: PdfPreview(
          build: (format) => pdf.save(),
          allowPrinting: true,
          allowSharing: true,
        ),
      ),
    ),
  );
}
