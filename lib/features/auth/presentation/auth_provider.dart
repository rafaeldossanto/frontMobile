import 'package:flutter/foundation.dart';

import '../data/auth_repository.dart';
import '../domain/user.dart';

/// Authentication state of the app. The router listens to this ChangeNotifier
/// (refreshListenable) to re-evaluate the guard when the session changes.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  bool _loading = false;
  String? _error;
  User? _user;
  String? _userId;
  bool _isLoggedIn = false;

  bool get loading => _loading;
  String? get error => _error;
  User? get user => _user;
  String? get userId => _userId;
  bool get isLoggedIn => _isLoggedIn;

  /// Restores the session from storage (called before runApp).
  Future<void> bootstrap() async {
    _isLoggedIn = await _repository.hasToken();
    if (_isLoggedIn) {
      _userId = await _repository.userId();
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String name}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _repository.devLogin(email: email, name: name);
      _user = user;
      _userId = user.id;
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
    _user = null;
    _userId = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
