// Gera os PNGs do ícone do app (design.md §19) em `assets/icon/` a partir da
// ilustração `assets/icon/fonte.png` (cofrinho amarelo sobre verde).
//
// Não é um teste de verdade: usa o `flutter_test` só porque ele traz o motor
// de imagem para fora do app. Rode a partir de `app-flutter/`:
//
//   flutter test tool/icon/generate_icon_test.dart
//
// e depois aplique nas plataformas:
//
//   dart run flutter_launcher_icons
//
// Saídas:
//  - `icon.png`: a ilustração inteira em 1024 px (iOS e ícone clássico).
//  - `icon_foreground.png`: só o cofrinho, com o fundo verde removido por
//    chave de cor (Android adaptativo).
//  - `icon_background.png`: um degradê verde tirado das cores da própria
//    ilustração (Android adaptativo).
//  - `icon_monochrome.png`: a silhueta do cofrinho, com olho, sorriso,
//    narinas e fenda vazados (Android 13+, ícone temático).
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _out = 1024;

/// O primeiro plano entra reduzido: o flutter_launcher_icons ainda o recua em
/// 16%, e os brilhos do alto não podem passar da zona segura da máscara.
const _foregroundScale = 0.92;

/// A splash mostra o cofrinho em 62% do quadro.
const _splashScale = 0.62;

void main() {
  testWidgets('gera os PNGs do ícone', (tester) async {
    await tester.runAsync(() async {
      final source = await _decode('assets/icon/fonte.png');
      final w = source.width;
      final h = source.height;
      final raw = (await source.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!.buffer.asUint8List();

      // Ícone cheio.
      await _write('assets/icon/icon.png', (c) {
        c.drawImageRect(
          source,
          Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
          Rect.fromLTWH(0, 0, _out.toDouble(), _out.toDouble()),
          Paint()..filterQuality = FilterQuality.high,
        );
      });

      // Fundo do adaptativo: degradê com as cores do verde da ilustração.
      final centerGreen = _average(raw, w, h, 0.5, 0.10);
      final edgeGreen = _average(raw, w, h, 0.03, 0.97);
      await _write('assets/icon/icon_background.png', (c) {
        c.drawRect(
          Rect.fromLTWH(0, 0, _out.toDouble(), _out.toDouble()),
          Paint()
            ..shader = ui.Gradient.radial(
              Offset(_out * 0.5, _out * 0.35),
              _out * 0.85,
              [centerGreen, edgeGreen],
            ),
        );
      });

      // Recorta o verde: o cofrinho fica com o alfa.
      final keyed = _keyOutGreen(raw);
      final cutout = await _fromPixels(keyed, w, h);
      await _write('assets/icon/icon_foreground.png', (c) {
        _drawCentered(c, cutout, w, h);
      });

      // Silhueta para o tema do Android 13: só o alfa conta. O que é escuro
      // (olho, sorriso, narinas, fenda) fica vazado.
      final mono = _silhouette(raw, keyed);
      final monoImage = await _fromPixels(mono, w, h);
      await _write('assets/icon/icon_monochrome.png', (c) {
        _drawCentered(c, monoImage, w, h);
      });

      // Splash: só o cofrinho, menor, para caber na zona segura do ícone da
      // splash do Android 12 (círculo de 2/3 do quadro) e sobrar respiro.
      await _write('assets/icon/splash_logo.png', (c) {
        _drawCentered(c, cutout, w, h, scale: _splashScale);
      });
      // Cor lisa da splash: a média do degradê do fundo (vai para o YAML).
      final splash = Color.lerp(centerGreen, edgeGreen, 0.5)!;
      debugPrint(
        'cor da splash: #${(splash.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      );

      // Play Store: o mesmo ícone cheio em 512 px.
      await _write('assets/icon/icon_play_store_512.png', (c) {
        c.drawImageRect(
          source,
          Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
          const Rect.fromLTWH(0, 0, 512, 512),
          Paint()..filterQuality = FilterQuality.high,
        );
      }, size: 512);
    });
  });
}

Future<ui.Image> _decode(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  return (await codec.getNextFrame()).image;
}

Future<ui.Image> _fromPixels(Uint8List pixels, int w, int h) {
  final done = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    w,
    h,
    ui.PixelFormat.rgba8888,
    done.complete,
  );
  return done.future;
}

Future<void> _write(
  String path,
  void Function(Canvas) draw, {
  int size = _out,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
  );
  draw(canvas);
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

/// Desenha [image] (w × h) no centro do quadro de saída, reduzida.
void _drawCentered(
  Canvas c,
  ui.Image image,
  int w,
  int h, {
  double scale = _foregroundScale,
}) {
  final side = _out * scale;
  final offset = (_out - side) / 2;
  c.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    Rect.fromLTWH(offset, offset, side, side),
    Paint()..filterQuality = FilterQuality.high,
  );
}

/// Cor média de um bloco pequeno em ([fx], [fy]) da imagem, em frações.
Color _average(Uint8List px, int w, int h, double fx, double fy) {
  final cx = (w * fx).round();
  final cy = (h * fy).round();
  var r = 0, g = 0, b = 0, n = 0;
  for (var y = math.max(0, cy - 6); y < math.min(h, cy + 6); y++) {
    for (var x = math.max(0, cx - 6); x < math.min(w, cx + 6); x++) {
      final i = (y * w + x) * 4;
      r += px[i];
      g += px[i + 1];
      b += px[i + 2];
      n++;
    }
  }
  return Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
}

/// Matiz em graus (0–360), saturação e valor (0–1) de um pixel.
({double hue, double sat, double val}) _hsv(int r, int g, int b) {
  final mx = math.max(r, math.max(g, b)).toDouble();
  final mn = math.min(r, math.min(g, b)).toDouble();
  final d = mx - mn;
  var hue = 0.0;
  if (d > 0) {
    if (mx == r) {
      hue = 60 * (((g - b) / d) % 6);
    } else if (mx == g) {
      hue = 60 * ((b - r) / d + 2);
    } else {
      hue = 60 * ((r - g) / d + 4);
    }
  }
  return (hue: hue, sat: mx == 0 ? 0 : d / mx, val: mx / 255);
}

/// Alfa de um pixel pela chave de cor: o verde do fundo (e a sombra verde
/// escura) some; o amarelo e os tons quentes ficam; o meio-termo, que é a
/// borda misturada, fica translúcido.
double _alphaOf(int r, int g, int b) {
  final c = _hsv(r, g, b);
  if (c.sat < 0.28 || c.val < 0.08) return 1; // branco, cinza, quase preto
  if (c.hue >= 100 && c.hue <= 220) return 0;
  if (c.hue > 62 && c.hue < 100) return (100 - c.hue) / (100 - 62);
  return 1;
}

/// Pixels RGBA **pré-multiplicados** do cofrinho sem o fundo.
Uint8List _keyOutGreen(Uint8List raw) {
  final out = Uint8List(raw.length);
  for (var i = 0; i < raw.length; i += 4) {
    final r = raw[i];
    var g = raw[i + 1];
    final b = raw[i + 2];
    final a = _alphaOf(r, g, b);
    if (a == 0) continue;
    if (a < 1) g = math.min(g, r); // tira o verde que sobrou na borda
    out[i] = (r * a).round();
    out[i + 1] = (g * a).round();
    out[i + 2] = (b * a).round();
    out[i + 3] = (255 * a).round();
  }
  return out;
}

/// Silhueta branca: alfa do recorte, menos o que é escuro (traços do rosto).
Uint8List _silhouette(Uint8List raw, Uint8List keyed) {
  final out = Uint8List(raw.length);
  for (var i = 0; i < raw.length; i += 4) {
    final alpha = keyed[i + 3];
    if (alpha == 0) continue;
    final c = _hsv(raw[i], raw[i + 1], raw[i + 2]);
    if (c.val < 0.55) continue; // olho, sorriso, narinas, fenda
    out[i] = alpha;
    out[i + 1] = alpha;
    out[i + 2] = alpha;
    out[i + 3] = alpha;
  }
  return out;
}
