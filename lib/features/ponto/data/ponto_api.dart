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
}
