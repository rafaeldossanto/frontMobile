import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_provider.dart';

/// Post-login home: greeting, shortcut to adventures and logout. Navigation
/// to /aventuras reaches screen #16.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final name = auth.user?.name ?? 'trilheiro';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trilha'),
        actions: [
          IconButton(
            tooltip: 'Sair',
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.terrain, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Ola, $name', style: theme.textTheme.titleLarge),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/aventuras'),
                icon: const Icon(Icons.hiking),
                label: const Text('Minhas aventuras'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/amizades'),
                icon: const Icon(Icons.people),
                label: const Text('Amizades'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/regioes'),
                icon: const Icon(Icons.folder),
                label: const Text('Minhas pastas'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/explorar'),
                icon: const Icon(Icons.public),
                label: const Text('Explorar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/mapa'),
                icon: const Icon(Icons.map),
                label: const Text('Mapa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
