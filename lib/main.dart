import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/token_storage.dart';
import 'features/auth/data/auth_api.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/aventura/data/aventura_api.dart';
import 'features/aventura/presentation/aventura_provider.dart';
import 'features/amizade/data/amizade_api.dart';
import 'features/amizade/data/usuario_busca_api.dart';
import 'features/amizade/presentation/amizade_provider.dart';
import 'features/caminho/data/caminho_api.dart';
import 'features/caminho/presentation/caminho_provider.dart';
import 'features/regiao/data/regiao_api.dart';
import 'features/regiao/presentation/regiao_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final tokenStorage = TokenStorage();
  final dioClient = DioClient(tokenStorage);
  final authRepository = AuthRepository(AuthApi(dioClient.dio), tokenStorage);
  final authProvider = AuthProvider(authRepository);
  await authProvider.bootstrap();

  // Router criado uma vez, fora do build, escutando o AuthProvider.
  final router = buildRouter(authProvider);

  runApp(
    MultiProvider(
      providers: [
        Provider<DioClient>.value(value: dioClient),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<AventuraProvider>(
          create: (_) => AventuraProvider(AventuraApi(dioClient.dio)),
        ),
        ChangeNotifierProvider<CaminhoProvider>(
          create: (_) => CaminhoProvider(CaminhoApi(dioClient.dio)),
        ),
        ChangeNotifierProvider<AmizadeProvider>(
          create: (_) => AmizadeProvider(
            AmizadeApi(dioClient.dio),
            UsuarioBuscaApi(dioClient.dio),
          ),
        ),
        ChangeNotifierProvider<RegiaoProvider>(
          create: (_) => RegiaoProvider(RegiaoApi(dioClient.dio)),
        ),
      ],
      child: TrilhaApp(router: router),
    ),
  );
}
