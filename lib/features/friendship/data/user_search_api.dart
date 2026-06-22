import 'package:dio/dio.dart';

import '../domain/public_user.dart';

/// User search for adding friends (via BFF).
class UserSearchApi {
  UserSearchApi(this._dio);

  final Dio _dio;

  Future<List<PublicUser>> searchUsers(String term) async {
    final resp = await _dio.get('/bff/usuarios/busca', queryParameters: {'termo': term});
    return (resp.data as List<dynamic>)
        .map((e) => PublicUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
