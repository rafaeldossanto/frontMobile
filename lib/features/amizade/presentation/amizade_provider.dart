import 'package:flutter/foundation.dart';

import '../data/amizade_api.dart';
import '../data/usuario_busca_api.dart';
import '../domain/amizade.dart';
import '../domain/usuario_publico.dart';

/// Estado de amizades: amigos, solicitacoes pendentes e busca de usuarios.
class AmizadeProvider extends ChangeNotifier {
  AmizadeProvider(this._api, this._buscaApi);

  final AmizadeApi _api;
  final UsuarioBuscaApi _buscaApi;

  bool _loading = false;
  String? _error;
  List<Amizade> _amigos = const [];
  List<Amizade> _pendentes = const [];
  List<UsuarioPublico> _resultados = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Amizade> get amigos => List.unmodifiable(_amigos);
  List<Amizade> get pendentes => List.unmodifiable(_pendentes);
  List<UsuarioPublico> get resultados => List.unmodifiable(_resultados);

  Future<void> carregar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _amigos = (await _api.amigos()).conteudo;
      _pendentes = (await _api.pendentes()).conteudo;
    } catch (_) {
      _error = 'Nao foi possivel carregar as amizades.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> buscar(String termo) async {
    if (termo.trim().isEmpty) {
      _resultados = const [];
      notifyListeners();
      return;
    }
    try {
      _resultados = await _buscaApi.autocomplete(termo.trim());
    } catch (_) {
      _resultados = const [];
    }
    notifyListeners();
  }

  /// Solicita amizade pelo codigoUsuario. Retorna null no sucesso ou a mensagem.
  Future<String?> solicitar(String codigoUsuario) async {
    try {
      await _api.solicitar(codigoUsuario);
      return null;
    } catch (_) {
      return 'Nao foi possivel enviar a solicitacao.';
    }
  }

  Future<void> responder(String amizadeId, String status) async {
    try {
      await _api.responder(amizadeId, status);
      await carregar();
    } catch (_) {
      _error = 'Nao foi possivel responder a solicitacao.';
      notifyListeners();
    }
  }
}
