import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../regiao/data/regiao_api.dart';
import '../../regiao/domain/regiao.dart';
import 'aventura_provider.dart';

/// Bottom sheet de criacao de aventura. A regiao vem de um seletor carregado de
/// GET /bff/regioes; envia o id selecionado no POST.
class CriarAventuraSheet extends StatefulWidget {
  const CriarAventuraSheet({super.key, required this.usuarioId});

  final String usuarioId;

  @override
  State<CriarAventuraSheet> createState() => _CriarAventuraSheetState();
}

class _CriarAventuraSheetState extends State<CriarAventuraSheet> {
  final _formKey = GlobalKey<FormState>();
  final _destinoController = TextEditingController();

  List<Regiao> _regioes = const [];
  Regiao? _regiaoSelecionada;
  bool _carregandoRegioes = true;

  String _visibilidade = 'PRIVADA';
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarRegioes();
  }

  @override
  void dispose() {
    _destinoController.dispose();
    super.dispose();
  }

  Future<void> _carregarRegioes() async {
    try {
      final regioes = await RegiaoApi(context.read<DioClient>().dio).listar();
      if (!mounted) {
        return;
      }
      setState(() {
        _regioes = regioes;
        _carregandoRegioes = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _carregandoRegioes = false);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _salvando = true);
    final provider = context.read<AventuraProvider>();
    final ok = await provider.criar(
      usuarioId: widget.usuarioId,
      regiaoId: _regiaoSelecionada?.id,
      destino: _destinoController.text.trim(),
      visibilidade: _visibilidade,
    );
    if (!mounted) {
      return;
    }
    setState(() => _salvando = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Erro ao criar aventura')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nova aventura', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destinoController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Destino'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o destino' : null,
            ),
            const SizedBox(height: 16),
            _campoRegiao(),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'PRIVADA', label: Text('Privada')),
                ButtonSegment(value: 'SO_GRUPO', label: Text('Grupo')),
                ButtonSegment(value: 'PUBLICA', label: Text('Publica')),
              ],
              selected: {_visibilidade},
              onSelectionChanged: (s) => setState(() => _visibilidade = s.first),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campoRegiao() {
    if (_carregandoRegioes) {
      return const InputDecorator(
        decoration: InputDecoration(labelText: 'Regiao'),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_regioes.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(labelText: 'Pasta (opcional)'),
        child: Text('Nenhuma pasta — a aventura ficara solta'),
      );
    }

    return DropdownButtonFormField<Regiao>(
      initialValue: _regiaoSelecionada,
      decoration: const InputDecoration(labelText: 'Pasta (opcional)'),
      items: _regioes
          .map((r) => DropdownMenuItem(value: r, child: Text(r.nome)))
          .toList(),
      onChanged: (r) => setState(() => _regiaoSelecionada = r),
    );
  }
}
