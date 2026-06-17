import 'package:dio/dio.dart';

import '../../../core/network/pagina_response.dart';
import '../../amizade/domain/usuario_publico.dart';
import '../domain/contadores.dart';
import '../domain/status_seguir.dart';

/// Seguir via BFF, pelo codigoUsuario. O codigo vai no corpo (seguir/deixar) ou
/// em ?codigo= (gets) — evita o '#' do codigo no path.
class SeguidorApi {
  SeguidorApi(this._dio);

  final Dio _dio;

  Future<void> seguir(String codigo) async {
    await _dio.post('/bff/seguidores', data: {'seguidoCodigo': codigo});
  }

  Future<void> deixarDeSeguir(String codigo) async {
    await _dio.delete('/bff/seguidores', data: {'seguidoCodigo': codigo});
  }

  Future<StatusSeguir> status(String codigo) async {
    final resp = await _dio.get('/bff/seguidores/status', queryParameters: {'codigo': codigo});
    return StatusSeguir.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Contadores> contadores(String codigo) async {
    final resp = await _dio.get('/bff/seguidores/contadores', queryParameters: {'codigo': codigo});
    return Contadores.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<UsuarioPublico>> seguidores(String codigo) async {
    final resp = await _dio.get('/bff/seguidores/seguidores',
        queryParameters: {'codigo': codigo, 'page': 0, 'size': 100});
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, UsuarioPublico.fromJson).conteudo;
  }

  Future<List<UsuarioPublico>> seguindo(String codigo) async {
    final resp = await _dio.get('/bff/seguidores/seguindo',
        queryParameters: {'codigo': codigo, 'page': 0, 'size': 100});
    return PaginaResponse.fromJson(resp.data as Map<String, dynamic>, UsuarioPublico.fromJson).conteudo;
  }
}
