import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/providers.dart';
import '../domain/repositories/intro_store.dart';
import 'repositories/intro_store_impl.dart';

/// Raiz de composição da feature; os testes trocam por uma versão falsa.
final introStoreProvider = Provider<IntroStore>(
  (ref) => IntroStoreImpl(ref.watch(deviceSettingsProvider)),
);
