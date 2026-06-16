import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../amizade/domain/usuario_publico.dart';
import '../data/seguidor_api.dart';

/// Lista de seguidores ou de quem o usuario segue. tipo = 'seguidores' | 'seguindo'.
class ListaUsuariosScreen extends StatefulWidget {
  const ListaUsuariosScreen({
    super.key,
    required this.codigo,
    required this.tipo,
    required this.titulo,
  });

  final String codigo;
  final String tipo;
  final String titulo;

  @override
  State<ListaUsuariosScreen> createState() => _ListaUsuariosScreenState();
}

class _ListaUsuariosScreenState extends State<ListaUsuariosScreen> {
  late final SeguidorApi _api = SeguidorApi(context.read<DioClient>().dio);

  List<UsuarioPublico> _usuarios = const [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final lista = widget.tipo == 'seguidores'
          ? await _api.seguidores(widget.codigo)
          : await _api.seguindo(widget.codigo);
      if (!mounted) {
        return;
      }
      setState(() {
        _usuarios = lista;
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
      appBar: AppBar(title: Text(widget.titulo)),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _usuarios.isEmpty
              ? const Center(child: Text('Ninguem por aqui ainda.'))
              : ListView(
                  children: _usuarios.map((u) {
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(u.nome),
                      subtitle: Text(u.codigoUsuario),
                      onTap: () => context.push('/perfil', extra: u),
                    );
                  }).toList(),
                ),
    );
  }
}
