import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/repositories/pin_store.dart';
import 'repositories/pin_store_impl.dart';

/// Raiz de composição da feature; os testes trocam por uma versão falsa.
final pinStoreProvider = Provider<PinStore>(
  (ref) => PinStoreImpl(getApplicationDocumentsDirectory),
);
