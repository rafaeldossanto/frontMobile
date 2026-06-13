import 'package:dio/dio.dart';

import '../domain/sessao.dart';

/// Rastreio ao vivo via BFF (HTTP). O app publica cada ponto GPS; o BFF repassa
/// ao servico de Localizacao (sem MQTT no cliente).
class RastreioApi {
  RastreioApi(this._dio);

  final Dio _dio;

  Future<Sessao> iniciarSessao({
    required String caminhoId,
    required String usuarioId,
    bool? terminoAutomatico,
    double? distanciaTerminoMetros,
  }) async {
    final resp = await _dio.post(
      '/bff/localizacao/sessao',
      data: {
        'caminhoId': caminhoId,
        'usuarioId': usuarioId,
        'terminoAutomatico': ?terminoAutomatico,
        'distanciaTerminoMetros': ?distanciaTerminoMetros,
      },
    );
    return Sessao.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> registrarPonto({
    required String sessaoId,
    required double latitude,
    required double longitude,
    double? altitude,
    double? precisao,
    double? velocidade,
  }) async {
    await _dio.post(
      '/bff/localizacao/ponto',
      data: {
        'sessaoId': sessaoId,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': ?altitude,
        'precisao': ?precisao,
        'velocidade': ?velocidade,
      },
    );
  }

  Future<Sessao> finalizarSessao(String sessaoId) async {
    final resp = await _dio.patch('/bff/localizacao/sessao/$sessaoId/finalizar');
    return Sessao.fromJson(resp.data as Map<String, dynamic>);
  }
}
