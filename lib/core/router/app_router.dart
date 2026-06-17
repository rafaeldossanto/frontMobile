import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_provider.dart';
import '../../features/amizade/domain/usuario_publico.dart';
import '../../features/amizade/presentation/amizades_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/aventura/presentation/aventura_detalhe_screen.dart';
import '../../features/aventura/presentation/aventuras_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/mapa/presentation/mapa_screen.dart';
import '../../features/rastreio/presentation/rastreio_screen.dart';
import '../../features/regiao/domain/regiao.dart';
import '../../features/regiao/presentation/explorar_regioes_screen.dart';
import '../../features/regiao/presentation/minhas_regioes_screen.dart';
import '../../features/regiao/presentation/regiao_detalhe_screen.dart';
import '../../features/seguidor/presentation/lista_usuarios_screen.dart';
import '../../features/seguidor/presentation/perfil_screen.dart';

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
      GoRoute(path: '/mapa', builder: (context, state) => const MapaScreen()),
      GoRoute(path: '/amizades', builder: (context, state) => const AmizadesScreen()),
      GoRoute(path: '/regioes', builder: (context, state) => const MinhasRegioesScreen()),
      GoRoute(path: '/explorar', builder: (context, state) => const ExplorarRegioesScreen()),
      GoRoute(
        path: '/regioes/detalhe',
        builder: (context, state) => RegiaoDetalheScreen(regiao: state.extra as Regiao),
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) {
          final usuario = state.extra as UsuarioPublico;
          return PerfilScreen(codigoUsuario: usuario.codigoUsuario, nome: usuario.nome);
        },
      ),
      GoRoute(
        path: '/usuarios',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return ListaUsuariosScreen(
            codigo: args['codigo'] as String,
            tipo: args['tipo'] as String,
            titulo: args['titulo'] as String,
          );
        },
      ),
      GoRoute(
        path: '/aventuras/:id',
        builder: (context, state) => AventuraDetalheScreen(aventuraId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/aventuras/:id/mapa',
        builder: (context, state) => MapaScreen(aventuraId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/caminhos/:caminhoId/rastreio',
        builder: (context, state) => RastreioScreen(caminhoId: state.pathParameters['caminhoId']!),
      ),
    ],
  );
}
