import 'package:dio/dio.dart';

import '../domain/usuario.dart';

/// Resultado do login: usuario + token da app e sua validade.
class AuthResult {
  const AuthResult({
    required this.usuario,
    required this.accessToken,
    required this.expiresInSegundos,
  });

  final Usuario usuario;
  final String accessToken;
  final int expiresInSegundos;
}

/// Acesso aos endpoints de autenticacao do BFF.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<AuthResult> devLogin({required String email, required String nome}) async {
    final resp = await _dio.post(
      '/bff/auth/dev-login',
      data: {'email': email, 'nome': nome},
    );
    final data = resp.data as Map<String, dynamic>;
    return AuthResult(
      usuario: Usuario.fromJson(data['usuario'] as Map<String, dynamic>),
      accessToken: data['accessToken'] as String,
      expiresInSegundos: (data['expiresInSegundos'] as num).toInt(),
    );
  }
}
