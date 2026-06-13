import 'package:dio/dio.dart';

import '../domain/usuario_publico.dart';

/// Busca de usuarios para adicionar amigos (via BFF).
class UsuarioBuscaApi {
  UsuarioBuscaApi(this._dio);

  final Dio _dio;

  Future<List<UsuarioPublico>> autocomplete(String termo) async {
    final resp = await _dio.get('/bff/usuarios/busca', queryParameters: {'termo': termo});
    return (resp.data as List<dynamic>)
        .map((e) => UsuarioPublico.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
