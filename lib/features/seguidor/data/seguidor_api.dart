import 'package:dio/dio.dart';

import '../../../core/network/pagina_response.dart';
import '../../amizade/domain/usuario_publico.dart';
import '../domain/contadores.dart';
import '../domain/status_seguir.dart';

/// Seguir via BFF, pelo codigoUsuario (o APP resolve para id). O codigo tem '#',
/// entao precisa ser URL-encodado no path.
class SeguidorApi {
  SeguidorApi(this._dio);

  final Dio _dio;

  String _enc(String codigo) => Uri.encodeComponent(codigo);

  Future<void> seguir(String codigo) async {
    await _dio.post('/bff/seguidores/${_enc(codigo)}');
  }

  Future<void> deixarDeSeguir(String codigo) async {
    await _dio.delete('/bff/seguidores/${_enc(codigo)}');
  }

  Future<StatusSeguir> status(String codigo) async {
    final resp = await _dio.get('/bff/seguidores/status/${_enc(codigo)}');
    return StatusSeguir.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Contadores> contadores(String codigo) async {
    final resp = await _dio.get('/bff/seguidores/contadores/${_enc(codigo)}');
    return Contadores.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<UsuarioPublico>> seguidores(String codigo) async {
    final resp = await _dio.get('/bff/seguidores/seguidores/${_enc(codigo)}',
        queryParameters: {'page': 0, 'size': 100});
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, UsuarioPublico.fromJson).conteudo;
  }

  Future<List<UsuarioPublico>> seguindo(String codigo) async {
    final resp = await _dio.get('/bff/seguidores/seguindo/${_enc(codigo)}',
        queryParameters: {'page': 0, 'size': 100});
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, UsuarioPublico.fromJson).conteudo;
  }
}
