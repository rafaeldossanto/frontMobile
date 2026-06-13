import 'package:dio/dio.dart';

import '../env/env.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// Cliente HTTP unico do app: baseUrl vem do .env (BFF), timeouts razoaveis e o
/// AuthInterceptor ja acoplado. As features recebem o `dio` daqui.
class DioClient {
  DioClient(TokenStorage tokenStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            contentType: 'application/json',
          ),
        ) {
    dio.interceptors.add(AuthInterceptor(tokenStorage));
  }

  final Dio dio;
}
