import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:trilha_app/core/storage/token_storage.dart';
import 'package:trilha_app/features/auth/data/auth_api.dart';
import 'package:trilha_app/features/auth/data/auth_repository.dart';
import 'package:trilha_app/features/auth/presentation/auth_provider.dart';
import 'package:trilha_app/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('login screen mostra os campos e o botao Entrar', (tester) async {
    final auth = AuthProvider(AuthRepository(AuthApi(Dio()), TokenStorage()));

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: auth,
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
