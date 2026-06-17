import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../mapa/data/location_service.dart';
import '../domain/cidade.dart';
import '../domain/regiao.dart';
import 'regiao_provider.dart';

/// Form de criar/editar pasta (regiao): nome, descricao, visibilidade e cidades.
/// regiao == null cria; senao edita.
class RegiaoFormSheet extends StatefulWidget {
  const RegiaoFormSheet({super.key, this.regiao});

  final Regiao? regiao;

  @override
  State<RegiaoFormSheet> createState() => _RegiaoFormSheetState();
}

class _RegiaoFormSheetState extends State<RegiaoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  late String _visibilidade;
  late List<Cidade> _cidades;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final r = widget.regiao;
    _nomeController = TextEditingController(text: r?.nome ?? '');
    _descricaoController = TextEditingController(text: r?.descricao ?? '');
    _visibilidade = r?.visibilidade ?? 'PRIVADA';
    _cidades = List.of(r?.cidades ?? const []);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _adicionarCidade() async {
    final cidade = await showDialog<Cidade>(
      context: context,
      builder: (_) => const _AdicionarCidadeDialog(),
    );
    if (cidade != null) {
      setState(() => _cidades.add(cidade));
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _salvando = true);
    final ok = await context.read<RegiaoProvider>().salvar(
          id: widget.regiao?.id,
          nome: _nomeController.text.trim(),
          descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
          visibilidade: _visibilidade,
          cidades: _cidades,
        );
    if (!mounted) {
      return;
    }
    setState(() => _salvando = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nao foi possivel salvar a pasta')),
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
            Text(widget.regiao == null ? 'Nova pasta' : 'Editar pasta',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration: const InputDecoration(labelText: 'Descricao (opcional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'PRIVADA', label: Text('Privada')),
                ButtonSegment(value: 'AMIGOS', label: Text('Amigos')),
                ButtonSegment(value: 'PUBLICA', label: Text('Publica')),
              ],
              selected: {_visibilidade},
              onSelectionChanged: (s) => setState(() => _visibilidade = s.first),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Cidades', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: _adicionarCidade,
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            ..._cidades.asMap().entries.map((e) {
              final c = e.value;
              final temCoord = c.latitude != null && c.longitude != null;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(temCoord ? Icons.place : Icons.location_city),
                title: Text(c.nome),
                subtitle: temCoord ? Text('${c.latitude!.toStringAsFixed(4)}, ${c.longitude!.toStringAsFixed(4)}') : null,
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _cidades.removeAt(e.key)),
                ),
              );
            }),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: _salvando
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog para adicionar uma cidade: nome + (opcional) localizacao atual.
class _AdicionarCidadeDialog extends StatefulWidget {
  const _AdicionarCidadeDialog();

  @override
  State<_AdicionarCidadeDialog> createState() => _AdicionarCidadeDialogState();
}

class _AdicionarCidadeDialogState extends State<_AdicionarCidadeDialog> {
  final _nomeController = TextEditingController();
  final _locationService = LocationService();
  double? _lat;
  double? _lng;
  double? _alt;
  bool _buscando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _anexarLocalizacao() async {
    setState(() => _buscando = true);
    final pos = await _locationService.posicaoAtual();
    if (!mounted) {
      return;
    }
    setState(() {
      if (pos != null) {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _alt = pos.altitude;
      }
      _buscando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final temCoord = _lat != null && _lng != null;
    return AlertDialog(
      title: const Text('Adicionar cidade'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome da cidade'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _buscando ? null : _anexarLocalizacao,
            icon: _buscando
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(temCoord ? Icons.check : Icons.my_location),
            label: Text(temCoord ? 'Localizacao anexada' : 'Anexar minha localizacao'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            final nome = _nomeController.text.trim();
            if (nome.isEmpty) {
              return;
            }
            Navigator.pop(context, Cidade(nome: nome, latitude: _lat, longitude: _lng, altitude: _alt));
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
