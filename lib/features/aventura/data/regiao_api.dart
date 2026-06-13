import 'package:dio/dio.dart';

import '../domain/regiao.dart';

/// Lista as regioes disponiveis (GET /bff/regioes) para o seletor de aventura.
class RegiaoApi {
  RegiaoApi(this._dio);

  final Dio _dio;

  Future<List<Regiao>> listar() async {
    final resp = await _dio.get('/bff/regioes');
    return (resp.data as List<dynamic>)
        .map((e) => Regiao.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
