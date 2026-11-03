import '../../../../core/error/result.dart';

/// O relatório pronto para sair do app: **tudo já em texto**, formatado pela
/// tela, porque moeda, data e idioma vivem lá (ADR-0016).
class ReportDocument {
  const ReportDocument({
    required this.fileName,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.columns,
    required this.rows,
    required this.totals,
    required this.emptyMessage,
  });

  /// Nome do arquivo anexado, com extensão.
  final String fileName;

  /// Título do documento (e assunto sugerido no compartilhamento).
  final String title;

  /// Linha menor sob o título (a data de geração).
  final String subtitle;

  /// Texto que acompanha o compartilhamento, para quem recebe bater o olho
  /// sem abrir o anexo.
  final String summary;

  /// Cabeçalho da tabela; cada lista de [rows] segue esta mesma ordem.
  final List<String> columns;

  final List<List<String>> rows;

  /// Linhas de fecho (mesada e saldo).
  final List<({String label, String value})> totals;

  /// O que mostrar quando não houve lançamento nenhum.
  final String emptyMessage;
}

/// Entrega o relatório ao sistema (folha de compartilhamento). A implementação
/// gera o PDF e escreve o arquivo; os testes trocam por uma versão falsa.
abstract class ReportSharer {
  Future<Result<void>> share(ReportDocument document);
}
