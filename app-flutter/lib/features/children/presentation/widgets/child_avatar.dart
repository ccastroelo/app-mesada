import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/children_state.dart';

/// Foto local do filho; sem foto, a inicial do nome num círculo de uma de 6
/// cores fixas, sempre a mesma para o mesmo filho.
class ChildAvatar extends ConsumerWidget {
  const ChildAvatar({
    super.key,
    required this.childId,
    required this.name,
    this.radius = 24,
  });

  final String childId;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(childPhotoPathProvider(childId)).value;
    return ExcludeSemantics(
      child: path == null
          ? InitialAvatar(seed: childId, name: name, radius: radius)
          : CircleAvatar(
              radius: radius,
              backgroundImage: FileImage(File(path)),
            ),
    );
  }
}

/// Círculo com a inicial. Usado também na edição, antes de existir foto.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({
    super.key,
    required this.seed,
    required this.name,
    this.radius = 24,
  });

  final String seed;
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final (light, strong) = _palette[stableIndex(seed, _palette.length)];
    final initial = name.trim().isEmpty
        ? '?'
        : String.fromCharCode(name.trim().runes.first).toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: dark ? strong : light,
      foregroundColor: dark ? light : strong,
      child: Text(
        initial,
        style: TextStyle(fontSize: radius * 0.85, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Índice estável entre execuções (String.hashCode não é).
int stableIndex(String seed, int length) {
  var hash = 0;
  for (final unit in seed.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash % length;
}

// (fundo no claro / texto no claro). No escuro as duas trocam de lugar.
const _palette = [
  (Color(0xFFCDE6EA), Color(0xFF0B4552)),
  (Color(0xFFF3DCC4), Color(0xFF6B3A0B)),
  (Color(0xFFDCD3F0), Color(0xFF3C2A72)),
  (Color(0xFFD7EEDD), Color(0xFF14562B)),
  (Color(0xFFF6D5DE), Color(0xFF7A1F3D)),
  (Color(0xFFD9E2F5), Color(0xFF1F3C73)),
];
