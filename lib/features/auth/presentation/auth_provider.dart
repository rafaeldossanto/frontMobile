import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/usuario.dart';

/// Estado de autenticacao do app. O router escuta este ChangeNotifier
/// (refreshListenable) para reavaliar o guard quando a sessao muda.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  bool _loading = false;
  String? _error;
  Usuario? _usuario;
  String? _usuarioId;
  bool _isLoggedIn = false;

  bool get loading => _loading;
  String? get error => _error;
  Usuario? get usuario => _usuario;
  String? get usuarioId => _usuarioId;
  bool get isLoggedIn => _isLoggedIn;

  /// Restaura a sessao a partir do storage (chamado antes do runApp).
  Future<void> bootstrap() async {
    _isLoggedIn = await _repository.hasToken();
    if (_isLoggedIn) {
      _usuarioId = await _repository.usuarioId();
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String nome}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final usuario = await _repository.devLogin(email: email, nome: nome);
      _usuario = usuario;
      _usuarioId = usuario.id;
      _isLoggedIn = true;
    } catch (_) {
      _error = 'Falha ao entrar. Confira se o backend (profile dev) esta no ar.';
      _isLoggedIn = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _usuario = null;
    _usuarioId = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
