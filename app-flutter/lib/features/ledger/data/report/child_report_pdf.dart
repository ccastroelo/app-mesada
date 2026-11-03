import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/repositories/report_sharer.dart';

/// Desenha o relatório em PDF A4 (ADR-0016). Dart puro: dá para testar sem
/// aparelho.
///
/// A fonte é a Helvetica embutida no pacote, que só cobre Latin-1 — então o
/// sinal "−" (U+2212) que o `formatCents` usa nos negativos é trocado pelo
/// hífen comum. Sem isso o glifo sairia vazio no documento.
Future<Uint8List> buildReportPdf(ReportDocument document) {
  final pdf = pw.Document(title: document.title);
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _latin1(document.title),
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _latin1(document.subtitle),
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          if (document.rows.isEmpty)
            pw.Text(_latin1(document.emptyMessage))
          else
            _table(document),
          pw.SizedBox(height: 20),
          for (final total in document.totals)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    _latin1(total.label),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    _latin1(total.value),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
  return pdf.save();
}

pw.Widget _table(ReportDocument document) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    // A descrição fica larga; valor, quantidade e total pedem pouco.
    columnWidths: {
      0: const pw.FlexColumnWidth(4),
      for (var i = 1; i < document.columns.length; i++)
        i: const pw.FlexColumnWidth(),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          for (var i = 0; i < document.columns.length; i++)
            _cell(document.columns[i], bold: true, alignRight: i > 0),
        ],
      ),
      for (final row in document.rows)
        pw.TableRow(
          children: [
            for (var i = 0; i < row.length; i++)
              _cell(row[i], alignRight: i > 0),
          ],
        ),
    ],
  );
}

pw.Widget _cell(String text, {bool bold = false, bool alignRight = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: pw.Text(
      _latin1(text),
      textAlign: alignRight ? pw.TextAlign.right : pw.TextAlign.left,
      style: pw.TextStyle(
        fontSize: 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

/// Troca o que a Helvetica embutida não desenha.
String _latin1(String text) => text.replaceAll('−', '-');
