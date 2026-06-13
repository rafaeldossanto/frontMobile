import '../../../core/storage/token_storage.dart';
import '../domain/usuario.dart';
import 'auth_api.dart';

/// Orquestra API + storage: ao logar, persiste token e usuarioId; expoe o
/// estado de sessao (hasToken/usuarioId) e o logout.
class AuthRepository {
  AuthRepository(this._api, this._storage);

  final AuthApi _api;
  final TokenStorage _storage;

  Future<Usuario> devLogin({required String email, required String nome}) async {
    final result = await _api.devLogin(email: email, nome: nome);
    await _storage.saveSession(token: result.accessToken, usuarioId: result.usuario.id);
    return result.usuario;
  }

  Future<bool> hasToken() async {
    final token = await _storage.readToken();
    return token != null && token.isNotEmpty;
  }

  Future<String?> usuarioId() => _storage.readUsuarioId();

  Future<void> logout() => _storage.clear();
}
