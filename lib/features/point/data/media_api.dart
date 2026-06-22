import 'package:dio/dio.dart';

import '../../../core/env/env.dart';

/// Photo upload directly to the Media service (`:8083`, outside the BFF). Uses the same
/// Dio (the interceptor injects the Bearer even on absolute URL). Returns the URL of
/// the binary already in storage, used as evidence for the point.
class MediaApi {
  MediaApi(this._dio);

  final Dio _dio;

  Future<String> uploadMedia(String filePath) async {
    final form = FormData.fromMap({
      'arquivo': await MultipartFile.fromFile(filePath),
    });
    final resp = await _dio.post(
      '${Env.midiaBaseUrl}/arquivo/upload',
      queryParameters: {'tipo': 'FOTO'},
      data: form,
    );
    return (resp.data as Map<String, dynamic>)['url'] as String;
  }
}
