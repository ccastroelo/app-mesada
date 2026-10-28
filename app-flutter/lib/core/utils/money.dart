import 'package:intl/intl.dart';

/// Formata centavos com o símbolo e o formato da região do aparelho (como no
/// legado). O valor guardado é só inteiro em centavos, sem moeda.
///
/// Com [signed], mostra "+" nos positivos; negativos sempre levam "−" (U+2212).
String formatCents(int cents, {required String locale, bool signed = false}) {
  final format = NumberFormat.simpleCurrency(locale: locale);
  final text = format.format(cents.abs() / 100);
  if (cents < 0) return '−$text';
  if (signed && cents > 0) return '+$text';
  return text;
}

/// Número com duas casas e separadores da região, sem símbolo nem sinal
/// ("1.234,50"). É o texto que aparece dentro de um campo de valor.
String formatCentsPlain(int cents, {required String locale}) {
  return NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: 2,
  ).format(cents.abs() / 100);
}

/// Lê os dígitos de um texto mascarado ("1.234,50" → 123450). Vazio vira 0.
int centsFromMaskedText(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  return digits.isEmpty ? 0 : int.parse(digits);
}
