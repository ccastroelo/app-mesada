/// Estado compartilhado da feature `ledger`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_family/auth_family.dart';
import 'data/providers.dart';
import 'domain/entities/entry.dart';

/// Todos os lançamentos da família (poucas dezenas de documentos).
final entriesProvider = StreamProvider<List<Entry>>((ref) {
  final gate = ref.watch(gateProvider);
  if (gate is! GateReady) return Stream.value(const <Entry>[]);
  return ref.watch(ledgerRepositoryProvider).watchEntries(gate.family.id);
});
