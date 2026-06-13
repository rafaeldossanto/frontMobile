import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda a sessao do usuario de forma segura (Keystore no Android). O token e o
/// usuarioId ficam aqui: o token vai no header das chamadas; o usuarioId e
/// necessario para montar as telas que dependem do dono (ex.: aventuras).
class TokenStorage {
  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _kToken = 'access_token';
  static const _kUsuarioId = 'usuario_id';

  Future<void> saveSession({required String token, required String usuarioId}) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kUsuarioId, value: usuarioId);
  }

  Future<String?> readToken() => _storage.read(key: _kToken);

  Future<String?> readUsuarioId() => _storage.read(key: _kUsuarioId);

  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kUsuarioId);
  }
}
