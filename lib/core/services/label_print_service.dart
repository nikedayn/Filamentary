import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:injectable/injectable.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

@lazySingleton
class LabelPrintService {
  Future<void> printSpoolLabel(String spoolId, String manufacturer, String type, String color) async {
    final doc = pw.Document();

    // Еталонний розмір етикетки Phomemo (40x30 мм)
    final labelFormat = PdfPageFormat(
      40.0 * PdfPageFormat.mm, 
      30.0 * PdfPageFormat.mm, 
      marginAll: 1.5 * PdfPageFormat.mm,
    );

    doc.addPage(
      pw.Page(
        pageFormat: labelFormat,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.SizedBox(
                  width: 18 * PdfPageFormat.mm,
                  height: 18 * PdfPageFormat.mm,
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: 'filamentary://spool/$spoolId',
                  ),
                ),
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Text(
                '$manufacturer $type', 
                style: const pw.TextStyle(fontSize: 7),
                maxLines: 1,
              ),
              pw.Text(
                color, 
                style: const pw.TextStyle(fontSize: 6),
                maxLines: 1,
              ),
            ],
          );
        },
      ),
    );

    // Кросплатформена логіка обробки
    if (Platform.isWindows) {
      // Зберігаємо PDF та відкриваємо нативний діалог "Поділитися" у Windows
      await Printing.sharePdf(bytes: await doc.save(), filename: 'spool_$spoolId.pdf');
    } else {
      // Для мобільних платформ залишаємо прямий друк
      await Printing.layoutPdf(
        name: 'spool_label_$spoolId',
        onLayout: (PdfPageFormat format) async => doc.save(),
      );
    }
  }
}