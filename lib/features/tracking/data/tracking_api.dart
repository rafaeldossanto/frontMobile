import 'package:dio/dio.dart';

import '../domain/session.dart';

/// Live tracking via BFF (HTTP). The app publishes each GPS point; the BFF forwards
/// it to the Location service (no MQTT on the client).
class TrackingApi {
  TrackingApi(this._dio);

  final Dio _dio;

  Future<Session> startSession({
    required String pathId,
    required String userId,
    bool? autoFinish,
    double? finishDistanceMeters,
  }) async {
    final resp = await _dio.post(
      '/bff/localizacao/sessao',
      data: {
        'caminhoId': pathId,
        'usuarioId': userId,
        'terminoAutomatico': ?autoFinish,
        'distanciaTerminoMetros': ?finishDistanceMeters,
      },
    );
    return Session.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> recordPoint({
    required String sessionId,
    required double latitude,
    required double longitude,
    double? altitude,
    double? accuracy,
    double? speed,
  }) async {
    await _dio.post(
      '/bff/localizacao/ponto',
      data: {
        'sessaoId': sessionId,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': ?altitude,
        'precisao': ?accuracy,
        'velocidade': ?speed,
      },
    );
  }

  Future<Session> finishSession(String sessionId) async {
    final resp = await _dio.patch('/bff/localizacao/sessao/$sessionId/finalizar');
    return Session.fromJson(resp.data as Map<String, dynamic>);
  }
}
