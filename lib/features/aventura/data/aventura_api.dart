import 'package:dio/dio.dart';

import '../../../core/network/pagina_response.dart';
import '../domain/aventura.dart';

/// Acesso aos endpoints de aventura do BFF. Na criacao NAO mandamos usuarioId —
/// o dono vem do token (Bearer injetado pelo interceptor).
class AventuraApi {
  AventuraApi(this._dio);

  final Dio _dio;

  Future<PaginaResponse<Aventura>> listarDoUsuario(
    String usuarioId, {
    int page = 0,
    int size = 20,
  }) async {
    final resp = await _dio.get(
      '/bff/aventuras/usuario/$usuarioId',
      queryParameters: {'page': page, 'size': size},
    );
    return PaginaResponse.fromJson(
      resp.data as Map<String, dynamic>,
      Aventura.fromJson,
    );
  }

  Future<Aventura> criar({
    String? regiaoId,
    required String destino,
    String? visibilidade,
  }) async {
    final resp = await _dio.post(
      '/bff/aventuras',
      data: {
        'regiaoId': ?regiaoId,
        'destino': destino,
        'visibilidade': ?visibilidade,
      },
    );
    return Aventura.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Move a aventura para uma pasta (regiao) ou tira dela (regiaoId == null).
  Future<Aventura> moverRegiao(String aventuraId, String? regiaoId) async {
    final resp = await _dio.patch('/bff/aventuras/$aventuraId/regiao', data: {'regiaoId': regiaoId});
    return Aventura.fromJson(resp.data as Map<String, dynamic>);
  }
}
