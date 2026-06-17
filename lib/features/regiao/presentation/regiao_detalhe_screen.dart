import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../aventura/domain/aventura.dart';
import '../data/regiao_api.dart';
import '../domain/regiao.dart';

/// Detalhe de uma pasta de outro usuario: cidades como pins no mapa e as
/// aventuras visiveis (o backend ja filtra pela regra de composicao).
class RegiaoDetalheScreen extends StatefulWidget {
  const RegiaoDetalheScreen({super.key, required this.regiao});

  final Regiao regiao;

  @override
  State<RegiaoDetalheScreen> createState() => _RegiaoDetalheScreenState();
}

class _RegiaoDetalheScreenState extends State<RegiaoDetalheScreen> {
  late final RegiaoApi _api = RegiaoApi(context.read<DioClient>().dio);

  List<Aventura> _aventuras = const [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final aventuras = await _api.aventurasDaRegiao(widget.regiao.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _aventuras = aventuras;
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
    final comCoord = widget.regiao.cidades
        .where((c) => c.latitude != null && c.longitude != null)
        .toList();
    final centro = comCoord.isNotEmpty
        ? LatLng(comCoord.first.latitude!, comCoord.first.longitude!)
        : const LatLng(-20.4350, -41.7920);

    return Scaffold(
      appBar: AppBar(title: Text(widget.regiao.nome)),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: FlutterMap(
              options: MapOptions(initialCenter: centro, initialZoom: comCoord.isNotEmpty ? 9 : 6),
              children: [
                TileLayer(
                  urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.trilha.trilha_app',
                ),
                MarkerLayer(
                  markers: [
                    for (final c in comCoord)
                      Marker(
                        point: LatLng(c.latitude!, c.longitude!),
                        width: 40,
                        height: 40,
                        child: Tooltip(
                          message: c.nome,
                          child: Icon(Icons.location_city, color: Theme.of(context).colorScheme.primary, size: 30),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: _listaAventuras()),
        ],
      ),
    );
  }

  Widget _listaAventuras() {
    if (_carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_aventuras.isEmpty) {
      return const Center(child: Text('Nenhuma aventura visivel nesta pasta.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _aventuras.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final a = _aventuras[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.terrain),
            title: Text(a.destino),
            subtitle: Text(a.status),
            trailing: const Icon(Icons.map),
            onTap: () => context.push('/aventuras/${a.id}/mapa'),
          ),
        );
      },
    );
  }
}
