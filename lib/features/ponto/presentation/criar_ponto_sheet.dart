import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../caminho/data/caminho_api.dart';
import '../../caminho/domain/caminho.dart';
import '../data/ponto_api.dart';

const _tiposPonto = ['CACHOEIRA', 'MIRANTE', 'ESCALADA', 'ACAMPAMENTO', 'OUTRO'];

/// Form de criação de ponto de interesse no local tocado no mapa. Nasce com
/// nível de confiança 1; ganha nível ao receber evidências.
class CriarPontoSheet extends StatefulWidget {
  const CriarPontoSheet({
    super.key,
    required this.aventuraId,
    required this.latitude,
    required this.longitude,
  });

  final String aventuraId;
  final double latitude;
  final double longitude;

  @override
  State<CriarPontoSheet> createState() => _CriarPontoSheetState();
}

class _CriarPontoSheetState extends State<CriarPontoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  late final CaminhoApi _caminhoApi = CaminhoApi(context.read<DioClient>().dio);
  late final PontoApi _pontoApi = PontoApi(context.read<DioClient>().dio);

  List<Caminho> _caminhos = const [];
  Caminho? _caminho;
  String _tipo = _tiposPonto.first;
  bool _carregando = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarCaminhos();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _carregarCaminhos() async {
    try {
      final pagina = await _caminhoApi.listarPorAventura(widget.aventuraId);
      if (!mounted) {
        return;
      }
      setState(() {
        _caminhos = pagina.conteudo;
        _caminho = _caminhos.isNotEmpty ? _caminhos.first : null;
        _carregando = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate() || _caminho == null) {
      return;
    }
    setState(() => _salvando = true);
    try {
      await _pontoApi.criar(
        caminhoId: _caminho!.id,
        tipo: _tipo,
        nome: _nomeController.text.trim().isEmpty ? null : _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty ? null : _descricaoController.text.trim(),
        latitude: widget.latitude,
        longitude: widget.longitude,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _salvando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nao foi possivel criar o ponto')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: _conteudo(),
    );
  }

  Widget _conteudo() {
    if (_carregando) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_caminhos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Inicie um caminho na aventura antes de marcar pontos.'),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Novo ponto', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<Caminho>(
            initialValue: _caminho,
            decoration: const InputDecoration(labelText: 'Caminho'),
            items: _caminhos
                .map((c) => DropdownMenuItem(value: c, child: Text('Caminho ${c.numero ?? ''}')))
                .toList(),
            onChanged: (c) => setState(() => _caminho = c),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _tipo,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: _tiposPonto
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (t) => setState(() => _tipo = t ?? _tipo),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nomeController,
            decoration: const InputDecoration(labelText: 'Nome (opcional)'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descricaoController,
            decoration: const InputDecoration(labelText: 'Descricao (opcional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _salvando ? null : _salvar,
            child: _salvando
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Criar ponto'),
          ),
        ],
      ),
    );
  }
}
