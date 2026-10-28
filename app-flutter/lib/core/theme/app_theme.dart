import 'package:flutter/material.dart';

import 'tokens.dart';

const Color _seed = Color(0xFF0E5A6B);

/// Cores com significado de negócio que o `ColorScheme` não cobre (design.md §6).
/// Nunca é o único indicador: o valor sempre vem com sinal e ícone.
@immutable
class MesadaColors extends ThemeExtension<MesadaColors> {
  const MesadaColors({
    required this.positive,
    required this.negative,
    required this.accent,
  });

  final Color positive;
  final Color negative;
  final Color accent;

  static const light = MesadaColors(
    positive: Color(0xFF1F7A3E),
    negative: Color(0xFFB3261E),
    accent: Color(0xFFE0A526),
  );

  static const dark = MesadaColors(
    positive: Color(0xFF7AD99A),
    negative: Color(0xFFF2B8B5),
    accent: Color(0xFFF2C14E),
  );

  @override
  MesadaColors copyWith({Color? positive, Color? negative, Color? accent}) {
    return MesadaColors(
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      accent: accent ?? this.accent,
    );
  }

  @override
  MesadaColors lerp(ThemeExtension<MesadaColors>? other, double t) {
    if (other is! MesadaColors) return this;
    return MesadaColors(
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
    );
  }
}

extension MesadaThemeX on BuildContext {
  MesadaColors get mesadaColors => Theme.of(this).extension<MesadaColors>()!;
}

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, MesadaColors.light);

  static ThemeData dark() => _build(Brightness.dark, MesadaColors.dark);

  static ThemeData _build(Brightness brightness, MesadaColors colors) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      extensions: [colors],
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.button),
        ),
      ),
    );
  }
}
