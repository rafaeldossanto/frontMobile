import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../auth/presentation/auth_provider.dart';

/// Home pos-login: saudacao, atalho para as aventuras e logout. A navegacao
/// para /aventuras chega no #16.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final nome = auth.usuario?.nome ?? 'trilheiro';

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
              Text('Ola, $nome', style: theme.textTheme.titleLarge),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => context.go('/aventuras'),
                icon: const Icon(Icons.hiking),
                label: const Text('Minhas aventuras'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
