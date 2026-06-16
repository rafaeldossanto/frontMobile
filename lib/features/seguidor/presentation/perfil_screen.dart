import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../amizade/presentation/amizade_provider.dart';
import '../data/seguidor_api.dart';
import '../domain/contadores.dart';
import '../domain/status_seguir.dart';

/// Perfil de outro usuario: seguir/seguindo, contadores e o botao de adicionar
/// amigo (so habilita quando o seguir e mutuo).
class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key, required this.codigoUsuario, required this.nome});

  final String codigoUsuario;
  final String nome;

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late final SeguidorApi _api = SeguidorApi(context.read<DioClient>().dio);

  StatusSeguir? _status;
  Contadores? _contadores;
  bool _carregando = true;
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final status = await _api.status(widget.codigoUsuario);
      final contadores = await _api.contadores(widget.codigoUsuario);
      if (!mounted) {
        return;
      }
      setState(() {
        _status = status;
        _contadores = contadores;
        _carregando = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  Future<void> _alternarSeguir() async {
    final status = _status;
    if (status == null) {
      return;
    }
    setState(() => _processando = true);
    try {
      if (status.sigo) {
        await _api.deixarDeSeguir(widget.codigoUsuario);
      } else {
        await _api.seguir(widget.codigoUsuario);
      }
      await _carregar();
    } catch (_) {
      _aviso('Nao foi possivel atualizar');
    } finally {
      if (mounted) {
        setState(() => _processando = false);
      }
    }
  }

  Future<void> _adicionarAmigo() async {
    final erro = await context.read<AmizadeProvider>().solicitar(widget.codigoUsuario);
    if (!mounted) {
      return;
    }
    _aviso(erro ?? 'Solicitacao de amizade enviada');
  }

  void _aviso(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _abrirLista(String tipo, String titulo) {
    context.push('/usuarios', extra: {
      'codigo': widget.codigoUsuario,
      'tipo': tipo,
      'titulo': titulo,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.nome)),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      widget.nome.isNotEmpty ? widget.nome[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 32, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text(widget.nome, style: theme.textTheme.titleLarge)),
                Center(child: Text(widget.codigoUsuario, style: theme.textTheme.bodySmall)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _contador('Seguidores', _contadores?.seguidores ?? 0,
                        () => _abrirLista('seguidores', 'Seguidores')),
                    _contador('Seguindo', _contadores?.seguindo ?? 0,
                        () => _abrirLista('seguindo', 'Seguindo')),
                  ],
                ),
                const SizedBox(height: 24),
                _botaoSeguir(),
                const SizedBox(height: 12),
                _botaoAdicionarAmigo(),
              ],
            ),
    );
  }

  Widget _contador(String rotulo, int valor, VoidCallback onTap) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text('$valor', style: theme.textTheme.titleLarge),
          Text(rotulo, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _botaoSeguir() {
    final sigo = _status?.sigo ?? false;
    final filho = _processando
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Text(sigo ? 'Seguindo' : 'Seguir');
    return sigo
        ? OutlinedButton(onPressed: _processando ? null : _alternarSeguir, child: filho)
        : FilledButton(onPressed: _processando ? null : _alternarSeguir, child: filho);
  }

  Widget _botaoAdicionarAmigo() {
    final mutuo = _status?.mutuo ?? false;
    return OutlinedButton.icon(
      onPressed: mutuo ? _adicionarAmigo : null,
      icon: const Icon(Icons.person_add),
      label: Text(mutuo ? 'Adicionar amigo' : 'Adicionar amigo (precisa ser mutuo)'),
    );
  }
}
