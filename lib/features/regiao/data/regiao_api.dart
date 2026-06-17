import 'package:dio/dio.dart';

import '../../../core/network/pagina_response.dart';
import '../../aventura/domain/aventura.dart';
import '../domain/cidade.dart';
import '../domain/regiao.dart';

/// CRUD de regioes (pastas) + descoberta, sobre /bff/regioes.
class RegiaoApi {
  RegiaoApi(this._dio);

  final Dio _dio;

  Map<String, dynamic> _body(String nome, String? descricao, String visibilidade, List<Cidade> cidades) => {
        'nome': nome,
        'descricao': descricao,
        'visibilidade': visibilidade,
        'cidades': cidades.map((c) => c.toJson()).toList(),
      };

  Future<List<Regiao>> listar() async {
    final resp = await _dio.get('/bff/regioes', queryParameters: {'page': 0, 'size': 100});
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, Regiao.fromJson).conteudo;
  }

  Future<Regiao> criar({
    required String nome,
    String? descricao,
    required String visibilidade,
    required List<Cidade> cidades,
  }) async {
    final resp = await _dio.post('/bff/regioes', data: _body(nome, descricao, visibilidade, cidades));
    return Regiao.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Regiao> atualizar(
    String id, {
    required String nome,
    String? descricao,
    required String visibilidade,
    required List<Cidade> cidades,
  }) async {
    final resp = await _dio.put('/bff/regioes/$id', data: _body(nome, descricao, visibilidade, cidades));
    return Regiao.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deletar(String id) async {
    await _dio.delete('/bff/regioes/$id');
  }

  Future<List<Regiao>> descobrir() async {
    final resp = await _dio.get('/bff/regioes/descobrir', queryParameters: {'page': 0, 'size': 100});
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, Regiao.fromJson).conteudo;
  }

  Future<List<Aventura>> aventurasDaRegiao(String id) async {
    final resp = await _dio.get('/bff/regioes/$id/aventuras', queryParameters: {'page': 0, 'size': 100});
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, Aventura.fromJson).conteudo;
  }
}
