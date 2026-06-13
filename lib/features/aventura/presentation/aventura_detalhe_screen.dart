import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../caminho/presentation/caminho_provider.dart';

/// Tela de detalhe da aventura: lista os caminhos (pernas), permite iniciar um
/// novo, finalizar e abrir o rastreio GPS ou o mapa com os pontos.
class AventuraDetalheScreen extends StatefulWidget {
  const AventuraDetalheScreen({super.key, required this.aventuraId});

  final String aventuraId;

  @override
  State<AventuraDetalheScreen> createState() => _AventuraDetalheScreenState();
}

class _AventuraDetalheScreenState extends State<AventuraDetalheScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CaminhoProvider>().carregar(widget.aventuraId),
    );
  }

  Future<void> _iniciarCaminho() async {
    final caminho = await context.read<CaminhoProvider>().iniciar(widget.aventuraId);
    if (!mounted) {
      return;
    }
    if (caminho == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel iniciar o caminho')),
      );
    }
  }

  Future<void> _finalizar(String caminhoId) async {
    await context.read<CaminhoProvider>().finalizar(widget.aventuraId, caminhoId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaminhoProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aventura'),
        actions: [
          IconButton(
            tooltip: 'Mapa da aventura',
            icon: const Icon(Icons.map),
            onPressed: () => context.go('/aventuras/${widget.aventuraId}/mapa'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.loading ? null : _iniciarCaminho,
        icon: const Icon(Icons.add_road),
        label: const Text('Iniciar caminho'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<CaminhoProvider>().carregar(widget.aventuraId),
        child: _conteudo(provider),
      ),
    );
  }

  Widget _conteudo(CaminhoProvider provider) {
    if (provider.loading && provider.caminhos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.caminhos.isEmpty) {
      final msg = provider.error ?? 'Nenhum caminho ainda.\nInicie um para rastrear a trilha.';
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
      itemCount: provider.caminhos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final caminho = provider.caminhos[index];
        final subtitulo = caminho.finalizado
            ? 'Finalizado • ${caminho.distanciaTotalKm?.toStringAsFixed(2) ?? '0'} km'
            : 'Em andamento';
        return Card(
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(child: Text('${caminho.numero ?? '-'}')),
                title: Text('Caminho ${caminho.numero ?? ''}'),
                subtitle: Text(subtitulo),
              ),
              if (!caminho.finalizado)
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => context.go('/caminhos/${caminho.id}/rastreio'),
                      icon: const Icon(Icons.gps_fixed),
                      label: const Text('Rastrear'),
                    ),
                    TextButton.icon(
                      onPressed: () => _finalizar(caminho.id),
                      icon: const Icon(Icons.flag),
                      label: const Text('Finalizar'),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
