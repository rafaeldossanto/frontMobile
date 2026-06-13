import 'package:flutter/foundation.dart';

import '../data/caminho_api.dart';
import '../domain/caminho.dart';

/// Estado dos caminhos de uma aventura (listar / iniciar / finalizar).
class CaminhoProvider extends ChangeNotifier {
  CaminhoProvider(this._api);

  final CaminhoApi _api;

  bool _loading = false;
  String? _error;
  List<Caminho> _caminhos = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Caminho> get caminhos => List.unmodifiable(_caminhos);

  Future<void> carregar(String aventuraId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final pagina = await _api.listarPorAventura(aventuraId);
      _caminhos = pagina.conteudo;
    } catch (_) {
      _error = 'Nao foi possivel carregar os caminhos.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Caminho?> iniciar(String aventuraId, {String? cor}) async {
    try {
      final caminho = await _api.iniciar(aventuraId: aventuraId, cor: cor);
      await carregar(aventuraId);
      return caminho;
    } catch (_) {
      _error = 'Nao foi possivel iniciar o caminho.';
      notifyListeners();
      return null;
    }
  }

  Future<void> finalizar(String aventuraId, String caminhoId) async {
    try {
      await _api.finalizar(caminhoId);
      await carregar(aventuraId);
    } catch (_) {
      _error = 'Nao foi possivel finalizar o caminho.';
      notifyListeners();
    }
  }
}
