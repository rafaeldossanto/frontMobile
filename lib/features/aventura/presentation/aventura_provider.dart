import 'package:flutter/foundation.dart';

import '../data/aventura_api.dart';
import '../domain/aventura.dart';

/// Estado da lista de aventuras do usuario logado.
class AventuraProvider extends ChangeNotifier {
  AventuraProvider(this._api);

  final AventuraApi _api;

  bool _loading = false;
  String? _error;
  List<Aventura> _aventuras = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Aventura> get aventuras => List.unmodifiable(_aventuras);

  Future<void> carregar(String usuarioId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final pagina = await _api.listarDoUsuario(usuarioId);
      _aventuras = pagina.conteudo;
    } catch (_) {
      _error = 'Nao foi possivel carregar as aventuras.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Cria e recarrega a lista. A regiao (pasta) e opcional. Retorna true no
  /// sucesso; em erro guarda a mensagem.
  Future<bool> criar({
    required String usuarioId,
    String? regiaoId,
    required String destino,
    String? visibilidade,
  }) async {
    try {
      await _api.criar(regiaoId: regiaoId, destino: destino, visibilidade: visibilidade);
      await carregar(usuarioId);
      return true;
    } catch (_) {
      _error = 'Nao foi possivel criar a aventura.';
      notifyListeners();
      return false;
    }
  }
}
