import 'dart:io';

import 'package:share_plus/share_plus.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/report_sharer.dart';
import '../report/child_report_pdf.dart';

/// Gera o PDF, grava num arquivo temporário e entrega à folha de
/// compartilhamento do sistema (ADR-0016). A pasta vem de fora
/// (`path_provider` no app, uma pasta temporária nos testes).
class SharePlusReportSharer implements ReportSharer {
  SharePlusReportSharer(this._directory);

  final Future<Directory> Function() _directory;

  @override
  Future<Result<void>> share(ReportDocument document) async {
    try {
      final bytes = await buildReportPdf(document);
      final directory = await _directory();
      final file = File(
        '${directory.path}${Platform.pathSeparator}${document.fileName}',
      );
      await file.writeAsBytes(bytes, flush: true);
      // Fechar a folha sem escolher nada não é erro.
      await SharePlus.instance.share(
        ShareParams(
          text: document.summary,
          subject: document.title,
          files: [XFile(file.path, mimeType: 'application/pdf')],
        ),
      );
      return const Ok(null);
    } catch (error) {
      return Err(Unexpected(error));
    }
  }
}
