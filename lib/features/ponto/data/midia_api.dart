import 'package:dio/dio.dart';

import '../../../core/env/env.dart';

/// Upload de foto direto no servico de Midia (`:8083`, fora do BFF). Usa o mesmo
/// Dio (o interceptor injeta o Bearer mesmo em URL absoluta). Retorna a URL do
/// binario ja no storage, usada como evidencia do ponto.
class MidiaApi {
  MidiaApi(this._dio);

  final Dio _dio;

  Future<String> uploadFoto(String caminhoArquivo) async {
    final form = FormData.fromMap({
      'arquivo': await MultipartFile.fromFile(caminhoArquivo),
    });
    final resp = await _dio.post(
      '${Env.midiaBaseUrl}/arquivo/upload',
      queryParameters: {'tipo': 'FOTO'},
      data: form,
    );
    return (resp.data as Map<String, dynamic>)['url'] as String;
  }
}
