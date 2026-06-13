import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/aventura/presentation/aventuras_screen.dart';
import '../../features/home/home_screen.dart';

/// Monta o GoRouter com guard de autenticacao. `refreshListenable` reavalia o
/// redirect quando a sessao muda; sem token vai pra /login, logado em /login
/// volta pra /home. Criado uma vez (fora do build) e passado ao MaterialApp.
GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: auth,
    redirect: (context, state) {
      final indoParaLogin = state.matchedLocation == '/login';

      if (!auth.isLoggedIn) {
        return indoParaLogin ? null : '/login';
      }
      if (indoParaLogin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/aventuras', builder: (context, state) => const AventurasScreen()),
    ],
  );
}
