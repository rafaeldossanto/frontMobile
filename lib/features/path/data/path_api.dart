import 'package:dio/dio.dart';

import '../../../core/network/page_response.dart';
import '../domain/path_model.dart';

/// Accesses paths via BFF. The distance on finalization does NOT come from the client —
/// the BFF gets it from the tracking session in the Location service.
class PathApi {
  PathApi(this._dio);

  final Dio _dio;

  Future<PageResponse<PathModel>> listByAdventure(
    String adventureId, {
    int page = 0,
    int size = 50,
  }) async {
    final resp = await _dio.get(
      '/bff/caminhos/aventura/$adventureId',
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(resp.data as Map<String, dynamic>, PathModel.fromJson);
  }

  Future<PathModel> start({required String adventureId, String? color}) async {
    final resp = await _dio.post(
      '/bff/caminhos',
      data: {'aventuraId': adventureId, 'cor': ?color},
    );
    return PathModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<PathModel> finish(String id) async {
    final resp = await _dio.patch('/bff/caminhos/$id/finalizar');
    return PathModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
