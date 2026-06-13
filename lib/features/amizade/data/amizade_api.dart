import 'package:dio/dio.dart';

import '../../../core/network/pagina_response.dart';
import '../domain/amizade.dart';

/// Acessa as amizades via BFF. O solicitante vem do token; o alvo e informado
/// pelo codigoUsuario (handle publico), resolvido para id no APP.
class AmizadeApi {
  AmizadeApi(this._dio);

  final Dio _dio;

  Future<PaginaResponse<Amizade>> pendentes({int page = 0, int size = 50}) async {
    final resp = await _dio.get(
      '/bff/amizades/pendentes',
      queryParameters: {'page': page, 'size': size},
    );
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, Amizade.fromJson);
  }

  Future<PaginaResponse<Amizade>> amigos({int page = 0, int size = 50}) async {
    final resp = await _dio.get(
      '/bff/amizades/amigos',
      queryParameters: {'page': page, 'size': size},
    );
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, Amizade.fromJson);
  }

  Future<void> solicitar(String receptorCodigo) async {
    await _dio.post('/bff/amizades', data: {'receptorCodigo': receptorCodigo});
  }

  Future<void> responder(String amizadeId, String status) async {
    await _dio.patch(
      '/bff/amizades/$amizadeId/responder',
      queryParameters: {'status': status},
    );
  }
}
