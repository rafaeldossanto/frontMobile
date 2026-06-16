import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_provider.dart';
import 'amizade_provider.dart';

/// Amizades em abas: amigos, solicitacoes pendentes e busca para adicionar.
class AmizadesScreen extends StatefulWidget {
  const AmizadesScreen({super.key});

  @override
  State<AmizadesScreen> createState() => _AmizadesScreenState();
}

class _AmizadesScreenState extends State<AmizadesScreen> {
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AmizadeProvider>().carregar());
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Amizades'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Amigos'),
              Tab(text: 'Pendentes'),
              Tab(text: 'Buscar'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_abaAmigos(), _abaPendentes(), _abaBuscar()],
        ),
      ),
    );
  }

  Widget _abaAmigos() {
    final provider = context.watch<AmizadeProvider>();
    final meuId = context.read<AuthProvider>().usuarioId;
    if (provider.amigos.isEmpty) {
      return _vazio('Voce ainda nao tem amigos.');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: provider.amigos.map((a) {
        final outro = a.solicitanteId == meuId ? a.receptorId : a.solicitanteId;
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person),
            title: Text(outro),
            subtitle: const Text('Amigo'),
          ),
        );
      }).toList(),
    );
  }

  Widget _abaPendentes() {
    final provider = context.watch<AmizadeProvider>();
    if (provider.pendentes.isEmpty) {
      return _vazio('Nenhuma solicitacao pendente.');
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: provider.pendentes.map((a) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.person_add),
            title: Text(a.solicitanteId),
            subtitle: const Text('Quer ser seu amigo'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Aceitar',
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => context.read<AmizadeProvider>().responder(a.id, 'ACEITA'),
                ),
                IconButton(
                  tooltip: 'Recusar',
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => context.read<AmizadeProvider>().responder(a.id, 'RECUSADA'),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _abaBuscar() {
    final provider = context.watch<AmizadeProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _buscaController,
            decoration: const InputDecoration(
              labelText: 'Buscar por codigo (ex: rafael#1)',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (termo) => context.read<AmizadeProvider>().buscar(termo),
          ),
        ),
        Expanded(
          child: ListView(
            children: provider.resultados.map((u) {
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(u.nome),
                subtitle: Text(u.codigoUsuario),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/perfil', extra: u),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _vazio(String msg) => Center(
        child: Padding(padding: const EdgeInsets.all(24), child: Text(msg, textAlign: TextAlign.center)),
      );
}
