import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../data/regiao_api.dart';
import '../domain/regiao.dart';

/// Explorar pastas publicas e de amigos (GET /bff/regioes/descobrir).
class ExplorarRegioesScreen extends StatefulWidget {
  const ExplorarRegioesScreen({super.key});

  @override
  State<ExplorarRegioesScreen> createState() => _ExplorarRegioesScreenState();
}

class _ExplorarRegioesScreenState extends State<ExplorarRegioesScreen> {
  late final RegiaoApi _api = RegiaoApi(context.read<DioClient>().dio);

  List<Regiao> _regioes = const [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final regioes = await _api.descobrir();
      if (!mounted) {
        return;
      }
      setState(() {
        _regioes = regioes;
        _carregando = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar')),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _regioes.isEmpty
              ? const Center(child: Text('Nenhuma pasta publica ou de amigos por aqui.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _regioes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = _regioes[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.public),
                        title: Text(r.nome),
                        subtitle: Text([
                          r.visibilidade,
                          '${r.cidades.length} cidade(s)',
                          if (r.descricao != null && r.descricao!.isNotEmpty) r.descricao!,
                        ].join(' • ')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/regioes/detalhe', extra: r),
                      ),
                    );
                  },
                ),
    );
  }
}
