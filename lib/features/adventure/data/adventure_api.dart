import 'package:dio/dio.dart';

import '../../../core/network/page_response.dart';
import '../domain/adventure.dart';

/// Access to adventure endpoints from the BFF. On creation we do NOT send userId —
/// the owner comes from the token (Bearer injected by the interceptor).
class AdventureApi {
  AdventureApi(this._dio);

  final Dio _dio;

  Future<PageResponse<Adventure>> listByUser(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    final resp = await _dio.get(
      '/bff/aventuras/usuario/$userId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      resp.data as Map<String, dynamic>,
      Adventure.fromJson,
    );
  }

  Future<Adventure> create({
    String? regionId,
    required String destination,
    String? visibility,
  }) async {
    final resp = await _dio.post(
      '/bff/aventuras',
      data: {
        'regiaoId': ?regionId,
        'destino': destination,
        'visibilidade': ?visibility,
      },
    );
    return Adventure.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Moves the adventure to a folder (region) or removes it (regionId == null).
  Future<Adventure> moveToRegion(String adventureId, String? regionId) async {
    final resp = await _dio.patch('/bff/aventuras/$adventureId/regiao', data: {'regiaoId': regionId});
    return Adventure.fromJson(resp.data as Map<String, dynamic>);
  }
}
