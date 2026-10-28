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
