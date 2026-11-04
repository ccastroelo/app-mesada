import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/pin_recovery_service.dart';

/// Fala com o servidor PHP de `servidor/` por HTTPS (ADR-0023), com o
/// `HttpClient` do próprio Dart: o contrato é de duas rotas JSON, não vale
/// uma dependência.
class HttpPinRecoveryService implements PinRecoveryService {
  HttpPinRecoveryService(
    String baseUrl, {
    this.timeout = const Duration(seconds: 15),
  }) : _baseUrl = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');

  final String _baseUrl;
  final Duration timeout;

  @override
  bool get available => _baseUrl.isNotEmpty;

  @override
  Future<Result<String>> register({
    required String email,
    required String installId,
    required String locale,
  }) async {
    final result = await _post('registrar.php', {
      'email': email,
      'installId': installId,
      'idioma': locale,
    });
    return switch (result) {
      Ok(:final value) =>
        value['token'] is String && (value['token'] as String).isNotEmpty
            ? Ok(value['token'] as String)
            : const Err(Unexpected()),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<void>> sendNewPin({
    required String email,
    required String installId,
    required String token,
    required String pin,
    required String locale,
  }) async {
    final result = await _post('recuperar.php', {
      'email': email,
      'installId': installId,
      'token': token,
      'pin': pin,
      'idioma': locale,
    });
    return switch (result) {
      Ok() => const Ok(null),
      Err(:final failure) => Err(failure),
    };
  }

  /// POST JSON. Rede fora, tempo esgotado ou TLS ruim viram [NoConnection];
  /// o resto vem do status e do campo `erro` da resposta.
  Future<Result<Map<String, dynamic>>> _post(
    String route,
    Map<String, Object?> body,
  ) async {
    if (!available) return const Err(Unexpected());
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client
          .postUrl(Uri.parse('$_baseUrl/$route'))
          .timeout(timeout);
      request.headers.contentType = ContentType('application', 'json');
      request.add(utf8.encode(jsonEncode(body)));
      final response = await request.close().timeout(timeout);
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(timeout);

      Map<String, dynamic> json = const {};
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map<String, dynamic>) json = decoded;
      } catch (_) {
        // Resposta que não é JSON (página de erro da hospedagem): trata pelo
        // status, abaixo.
      }

      if (response.statusCode == 200 && json['ok'] == true) return Ok(json);
      return Err(_failureFor(response.statusCode, json['erro']));
    } on SocketException {
      return const Err(NoConnection());
    } on HandshakeException {
      return const Err(NoConnection());
    } on TimeoutException {
      return const Err(NoConnection());
    } on HttpException {
      return const Err(NoConnection());
    } catch (error) {
      return Err(Unexpected(error));
    } finally {
      client.close(force: true);
    }
  }

  static Failure _failureFor(int status, Object? code) {
    if (status == 429) return const TooManyRequests();
    if (status == 403) return const PermissionDenied();
    if (status == 400 && code == 'email_invalido') return const InvalidEmail();
    return Unexpected('HTTP $status ${code ?? ''}'.trim());
  }
}
