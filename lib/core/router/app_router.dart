import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_provider.dart';
import '../../features/friendship/domain/public_user.dart';
import '../../features/friendship/presentation/friendships_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/adventure/presentation/adventure_detail_screen.dart';
import '../../features/adventure/presentation/adventures_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/map/presentation/map_screen.dart';
import '../../features/tracking/presentation/tracking_screen.dart';
import '../../features/region/domain/region.dart';
import '../../features/region/presentation/explore_regions_screen.dart';
import '../../features/region/presentation/my_regions_screen.dart';
import '../../features/region/presentation/region_detail_screen.dart';
import '../../features/follower/presentation/user_list_screen.dart';
import '../../features/follower/presentation/profile_screen.dart';

/// Builds the GoRouter with authentication guard. `refreshListenable` re-evaluates the
/// redirect when the session changes; without a token goes to /login, logged in at /login
/// goes back to /home. Created once (outside build) and passed to MaterialApp.
GoRouter buildRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/home',
    refreshListenable: auth,
    redirect: (context, state) {
      final goingToLogin = state.matchedLocation == '/login';

      if (!auth.isLoggedIn) {
        return goingToLogin ? null : '/login';
      }
      if (goingToLogin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/aventuras', builder: (context, state) => const AdventuresScreen()),
      GoRoute(path: '/mapa', builder: (context, state) => const MapScreen()),
      GoRoute(path: '/amizades', builder: (context, state) => const FriendshipsScreen()),
      GoRoute(path: '/regioes', builder: (context, state) => const MyRegionsScreen()),
      GoRoute(path: '/explorar', builder: (context, state) => const ExploreRegionsScreen()),
      GoRoute(
        path: '/regioes/detalhe',
        builder: (context, state) => RegionDetailScreen(region: state.extra as Region),
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) {
          final user = state.extra as PublicUser;
          return ProfileScreen(userCode: user.userCode, name: user.name);
        },
      ),
      GoRoute(
        path: '/usuarios',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return UserListScreen(
            code: args['codigo'] as String,
            type: args['tipo'] as String,
            title: args['titulo'] as String,
          );
        },
      ),
      GoRoute(
        path: '/aventuras/:id',
        builder: (context, state) => AdventureDetailScreen(adventureId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/aventuras/:id/mapa',
        builder: (context, state) => MapScreen(adventureId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/caminhos/:caminhoId/rastreio',
        builder: (context, state) => TrackingScreen(pathId: state.pathParameters['caminhoId']!),
      ),
    ],
  );
}
