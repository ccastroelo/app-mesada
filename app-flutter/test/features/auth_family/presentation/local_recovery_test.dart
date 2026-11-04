import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesada/core/error/result.dart';
import 'package:mesada/core/storage/local_document.dart';
import 'package:mesada/core/storage/local_store.dart';
import 'package:mesada/core/storage/providers.dart';

import '../../../support/pump_app.dart';

/// Um arquivo que não abre até alguém mandar "começar de novo". Num teste de
/// widget o disco de verdade não completa, então a troca é toda em memória; o
/// que `LocalStore.startOver` faz no disco está em `local_store_test.dart`.
class _BrokenStore extends LocalStore {
  _BrokenStore() : super(() async => Directory.systemTemp);

  bool broken = true;
  int startOvers = 0;

  @override
  Stream<LocalDocument> watch() => broken
      ? Stream<LocalDocument>.error(const FormatException('arquivo ruim'))
      : Stream.value(LocalDocument.initial());

  @override
  Future<Result<void>> startOver() async {
    startOvers++;
    broken = false;
    return const Ok(null);
  }
}

void main() {
  testWidgets(
    'arquivo ilegível: explica e oferece tentar de novo e recomeçar',
    (tester) async {
      final store = _BrokenStore();
      await pumpApp(tester, mode: AppMode.local, store: store);

      expect(
        find.text('Não consegui ler os dados deste aparelho'),
        findsOneWidget,
      );
      expect(find.text('Tentar de novo'), findsOneWidget);
      expect(find.text('Começar de novo'), findsOneWidget);
      // Sem conta no modo local: não há "Sair".
      expect(find.text('Sair'), findsNothing);
    },
  );

  testWidgets('tentar de novo reabre a leitura do arquivo', (tester) async {
    final store = _BrokenStore();
    await pumpApp(tester, mode: AppMode.local, store: store);

    // A pessoa consertou o arquivo por fora.
    store.broken = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(find.text('Não consegui ler os dados deste aparelho'), findsNothing);
    expect(find.text('Filhos'), findsWidgets);
  });

  testWidgets('começar de novo pede confirmação e abre o app vazio', (
    tester,
  ) async {
    final store = _BrokenStore();
    await pumpApp(tester, mode: AppMode.local, store: store);

    await tester.tap(find.text('Começar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('Começar de novo?'), findsOneWidget);
    expect(find.textContaining('mesada.json.bak'), findsOneWidget);
    expect(store.startOvers, 0);

    await tester.tap(find.widgetWithText(FilledButton, 'Começar de novo'));
    await tester.pumpAndSettle();

    expect(store.startOvers, 1);
    expect(find.text('Não consegui ler os dados deste aparelho'), findsNothing);
    expect(find.text('Filhos'), findsWidgets);
  });

  testWidgets('cancelar a confirmação não mexe em nada', (tester) async {
    final store = _BrokenStore();
    await pumpApp(tester, mode: AppMode.local, store: store);

    await tester.tap(find.text('Começar de novo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(store.startOvers, 0);
    expect(
      find.text('Não consegui ler os dados deste aparelho'),
      findsOneWidget,
    );
  });

  group('nome da família no modo local', () {
    Future<void> openSettings(WidgetTester tester) async {
      await pumpApp(tester, mode: AppMode.local);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text('Ajustes'),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets(
      'a linha da família abre o campo, em branco enquanto não há nome',
      (tester) async {
        await openSettings(tester);

        await tester.tap(find.widgetWithText(ListTile, 'Minha família'));
        await tester.pumpAndSettle();

        expect(find.text('Nome da família'), findsWidgets);
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller!.text, isEmpty);
      },
    );

    testWidgets('cancelar fecha sem mudar o nome', (tester) async {
      await openSettings(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Minha família'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Família Castro');
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
      expect(find.widgetWithText(ListTile, 'Minha família'), findsOneWidget);
    });
  });
}
