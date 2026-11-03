import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/features/ledger/data/report/child_report_pdf.dart';
import 'package:mesada/features/ledger/ledger.dart';

/// Documento com o que costuma quebrar um PDF: acento, "−" (U+2212) e espaço
/// não-quebrável, todos vindos do formato de moeda.
ReportDocument document({List<List<String>> rows = const []}) {
  return ReportDocument(
    fileName: 'mesada-lucas.pdf',
    title: 'Mesada de Lucas',
    subtitle: 'Gerado em 3 de novembro de 2026',
    summary: 'Lucas — mesada R 100,00, saldo R 99,50.',
    columns: const ['Regra', 'Valor', 'Qtd', 'Total'],
    rows: rows,
    totals: const [
      (label: 'Mesada', value: 'R 100,00'),
      (label: 'Saldo', value: '−R 99,50'),
    ],
    emptyMessage: 'Nenhum lançamento até agora.',
  );
}

void main() {
  test('gera um PDF de verdade, com tabela', () async {
    final bytes = await buildReportPdf(
      document(
        rows: const [
          ['Arrumar a cama', '+R 0,50', '2', '+R 1,00'],
          ['Luz acesa', '−R 0,50', '3', '−R 1,50'],
        ],
      ),
    );

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
    // Um documento com tabela não cabe em poucos bytes.
    expect(bytes.length, greaterThan(1000));
  });

  test('sem lançamento nenhum, ainda gera o documento', () async {
    final bytes = await buildReportPdf(document());

    expect(utf8.decode(bytes.take(4).toList()), '%PDF');
  });
}
