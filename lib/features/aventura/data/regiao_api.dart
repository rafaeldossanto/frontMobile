import 'package:dio/dio.dart';

import '../../../core/network/pagina_response.dart';
import '../domain/regiao.dart';

/// Lista as minhas regioes (pastas) — GET /bff/regioes (paginado) — para o
/// seletor de aventura.
class RegiaoApi {
  RegiaoApi(this._dio);

  final Dio _dio;

  Future<List<Regiao>> listar() async {
    final resp = await _dio.get('/bff/regioes', queryParameters: {'page': 0, 'size': 100});
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, Regiao.fromJson).conteudo;
  }
}
