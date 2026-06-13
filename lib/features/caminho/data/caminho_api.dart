import 'package:dio/dio.dart';

import '../../../core/network/pagina_response.dart';
import '../domain/caminho.dart';

/// Acessa os caminhos via BFF. A distancia na finalizacao NAO vem do cliente —
/// o BFF a obtem da sessao de rastreamento no servico de Localizacao.
class CaminhoApi {
  CaminhoApi(this._dio);

  final Dio _dio;

  Future<PaginaResponse<Caminho>> listarPorAventura(
    String aventuraId, {
    int page = 0,
    int size = 50,
  }) async {
    final resp = await _dio.get(
      '/bff/caminhos/aventura/$aventuraId',
      queryParameters: {'page': page, 'size': size},
    );
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, Caminho.fromJson);
  }

  Future<Caminho> iniciar({required String aventuraId, String? cor}) async {
    final resp = await _dio.post(
      '/bff/caminhos',
      data: {'aventuraId': aventuraId, 'cor': ?cor},
    );
    return Caminho.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Caminho> finalizar(String id) async {
    final resp = await _dio.patch('/bff/caminhos/$id/finalizar');
    return Caminho.fromJson(resp.data as Map<String, dynamic>);
  }
}
