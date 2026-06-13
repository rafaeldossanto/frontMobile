import 'package:dio/dio.dart';

import '../../../core/network/pagina_response.dart';
import '../domain/ponto_interesse.dart';

/// Acessa os pontos de interesse via BFF. A hierarquia e
/// Aventura -> Caminho -> Ponto, entao para os pontos de uma aventura
/// pegamos seus caminhos (no /detalhe) e juntamos os pontos de cada um.
class PontoApi {
  PontoApi(this._dio);

  final Dio _dio;

  Future<List<String>> caminhosDaAventura(String aventuraId) async {
    final resp = await _dio.get('/bff/aventuras/$aventuraId/detalhe');
    final data = resp.data as Map<String, dynamic>;
    final caminhos = (data['caminhos'] as List<dynamic>? ?? const []);
    return caminhos
        .map((c) => (c as Map<String, dynamic>)['id'] as String)
        .toList();
  }

  Future<List<PontoInteresse>> pontosDoCaminho(String caminhoId) async {
    final resp = await _dio.get('/bff/pontos-interesse/caminho/$caminhoId');
    final pagina = PaginaResponse.fromJson(
      resp.data as Map<String, dynamic>,
      PontoInteresse.fromJson,
    );
    return pagina.conteudo;
  }

  Future<List<PontoInteresse>> pontosDaAventura(String aventuraId) async {
    final caminhos = await caminhosDaAventura(aventuraId);
    final todos = <PontoInteresse>[];
    for (final caminhoId in caminhos) {
      todos.addAll(await pontosDoCaminho(caminhoId));
    }
    return todos;
  }

  Future<PontoInteresse> criar({
    required String caminhoId,
    required String tipo,
    String? nome,
    String? descricao,
    required double latitude,
    required double longitude,
  }) async {
    final resp = await _dio.post(
      '/bff/pontos-interesse',
      data: {
        'caminhoId': caminhoId,
        'tipo': tipo,
        'nome': ?nome,
        'descricao': ?descricao,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return PontoInteresse.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Adiciona evidencia (foto ja no storage). O APP valida a proximidade (<50m)
  /// e recalcula o nivel de confianca do ponto.
  Future<void> adicionarEvidencia({
    required String pontoId,
    required String fotoUrl,
    required String tipoEvidencia,
    required double latCaptura,
    required double lngCaptura,
  }) async {
    await _dio.post(
      '/bff/pontos-interesse/evidencia',
      data: {
        'pontoId': pontoId,
        'fotoUrl': fotoUrl,
        'tipoEvidencia': tipoEvidencia,
        'latCaptura': latCaptura,
        'lngCaptura': lngCaptura,
      },
    );
  }
}
