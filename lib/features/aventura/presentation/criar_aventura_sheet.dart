import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'aventura_provider.dart';

/// Bottom sheet de criacao de aventura. regiaoId e digitado a mao porque ainda
/// nao ha cadastro/endpoint de regioes — precisa ser um id que exista no APP.
class CriarAventuraSheet extends StatefulWidget {
  const CriarAventuraSheet({super.key, required this.usuarioId});

  final String usuarioId;

  @override
  State<CriarAventuraSheet> createState() => _CriarAventuraSheetState();
}

class _CriarAventuraSheetState extends State<CriarAventuraSheet> {
  final _formKey = GlobalKey<FormState>();
  final _destinoController = TextEditingController();
  final _regiaoController = TextEditingController();
  String _visibilidade = 'PRIVADA';
  bool _salvando = false;

  @override
  void dispose() {
    _destinoController.dispose();
    _regiaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _salvando = true);
    final provider = context.read<AventuraProvider>();
    final ok = await provider.criar(
      usuarioId: widget.usuarioId,
      regiaoId: _regiaoController.text.trim(),
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
            TextFormField(
              controller: _regiaoController,
              decoration: const InputDecoration(
                labelText: 'Regiao (id)',
                helperText: 'Use um id de regiao que exista no APP (seed)',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o id da regiao' : null,
            ),
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
}
