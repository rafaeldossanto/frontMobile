import 'package:flutter/foundation.dart';

import '../data/regiao_api.dart';
import '../domain/cidade.dart';
import '../domain/regiao.dart';

/// Estado das minhas regioes (pastas): listar / criar / editar / excluir.
class RegiaoProvider extends ChangeNotifier {
  RegiaoProvider(this._api);

  final RegiaoApi _api;

  bool _loading = false;
  String? _error;
  List<Regiao> _regioes = const [];

  bool get loading => _loading;
  String? get error => _error;
  List<Regiao> get regioes => List.unmodifiable(_regioes);

  Future<void> carregar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _regioes = await _api.listar();
    } catch (_) {
      _error = 'Nao foi possivel carregar as pastas.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> salvar({
    String? id,
    required String nome,
    String? descricao,
    required String visibilidade,
    required List<Cidade> cidades,
  }) async {
    try {
      if (id == null) {
        await _api.criar(nome: nome, descricao: descricao, visibilidade: visibilidade, cidades: cidades);
      } else {
        await _api.atualizar(id, nome: nome, descricao: descricao, visibilidade: visibilidade, cidades: cidades);
      }
      await carregar();
      return true;
    } catch (_) {
      _error = 'Nao foi possivel salvar a pasta.';
      notifyListeners();
      return false;
    }
  }

  Future<void> excluir(String id) async {
    try {
      await _api.deletar(id);
      await carregar();
    } catch (_) {
      _error = 'Nao foi possivel excluir a pasta.';
      notifyListeners();
    }
  }
}
