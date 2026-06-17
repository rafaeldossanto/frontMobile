import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/regiao.dart';
import 'regiao_form_sheet.dart';
import 'regiao_provider.dart';

/// Minhas pastas (regioes): listar, criar, editar e excluir.
class MinhasRegioesScreen extends StatefulWidget {
  const MinhasRegioesScreen({super.key});

  @override
  State<MinhasRegioesScreen> createState() => _MinhasRegioesScreenState();
}

class _MinhasRegioesScreenState extends State<MinhasRegioesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<RegiaoProvider>().carregar());
  }

  Future<void> _abrirForm({Regiao? regiao}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RegiaoFormSheet(regiao: regiao),
    );
  }

  Future<void> _excluir(Regiao regiao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir pasta'),
        content: Text('Excluir "${regiao.nome}"? As aventuras nao sao apagadas, so saem da pasta.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirmar == true && mounted) {
      await context.read<RegiaoProvider>().excluir(regiao.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RegiaoProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas pastas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirForm(),
        child: const Icon(Icons.create_new_folder),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<RegiaoProvider>().carregar(),
        child: _conteudo(provider),
      ),
    );
  }

  Widget _conteudo(RegiaoProvider provider) {
    if (provider.loading && provider.regioes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.regioes.isEmpty) {
      return ListView(children: [
        Padding(
          padding: const EdgeInsets.only(top: 120, left: 24, right: 24),
          child: Text(provider.error ?? 'Nenhuma pasta ainda.\nToque no + para criar.', textAlign: TextAlign.center),
        ),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.regioes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = provider.regioes[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.folder),
            title: Text(r.nome),
            subtitle: Text('${r.visibilidade} • ${r.cidades.length} cidade(s)'),
            onTap: () => _abrirForm(regiao: r),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _excluir(r),
            ),
          ),
        );
      },
    );
  }
}
