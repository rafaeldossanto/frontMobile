import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_provider.dart';
import 'aventura_provider.dart';
import 'criar_aventura_sheet.dart';

/// Lista as aventuras do usuario logado, com pull-to-refresh e FAB para criar.
class AventurasScreen extends StatefulWidget {
  const AventurasScreen({super.key});

  @override
  State<AventurasScreen> createState() => _AventurasScreenState();
}

class _AventurasScreenState extends State<AventurasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _carregar());
  }

  Future<void> _carregar() async {
    final usuarioId = context.read<AuthProvider>().usuarioId;
    if (usuarioId != null) {
      await context.read<AventuraProvider>().carregar(usuarioId);
    }
  }

  Future<void> _abrirCriar() async {
    final usuarioId = context.read<AuthProvider>().usuarioId;
    if (usuarioId == null) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CriarAventuraSheet(usuarioId: usuarioId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AventuraProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas aventuras')),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCriar,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _carregar,
        child: _conteudo(provider),
      ),
    );
  }

  Widget _conteudo(AventuraProvider provider) {
    if (provider.loading && provider.aventuras.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.aventuras.isEmpty) {
      final msg = provider.error ?? 'Nenhuma aventura ainda.\nToque no + para criar.';
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 120, left: 24, right: 24),
            child: Text(msg, textAlign: TextAlign.center),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.aventuras.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final aventura = provider.aventuras[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.terrain),
            title: Text(aventura.destino),
            subtitle: Text(
              [aventura.status, if (aventura.visibilidade != null) aventura.visibilidade!]
                  .join(' • '),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/aventuras/${aventura.id}/mapa'),
          ),
        );
      },
    );
  }
}
