import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/money.dart';

/// Máscara de centavos: os dígitos entram pela direita ("5" → 0,05; "50" →
/// 0,50), como o campo de valor do app antigo. Passar de [maxCents] rejeita a
/// digitação.
class CentsInputFormatter extends TextInputFormatter {
  CentsInputFormatter({required this.locale, required this.maxCents});

  final String locale;
  final int maxCents;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    // Mais de 15 dígitos já passa de qualquer teto e estouraria o int.
    if (digits.length > 15) return oldValue;
    final cents = centsFromMaskedText(digits);
    if (cents > maxCents) return oldValue;
    final text = formatCentsPlain(cents, locale: locale);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Campo de valor em dinheiro, em centavos. O sinal não faz parte do campo:
/// quem usa decide (ex.: Desconto/Recompensa).
class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.label,
    required this.maxCents,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final int maxCents;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      inputFormatters: [
        CentsInputFormatter(locale: locale, maxCents: maxCents),
      ],
      decoration: InputDecoration(labelText: label),
    );
  }
}
