import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../ponto/data/midia_api.dart';
import '../../ponto/data/ponto_api.dart';
import '../../ponto/domain/ponto_interesse.dart';
import '../../ponto/presentation/criar_ponto_sheet.dart';
import '../../ponto/presentation/nivel_cores.dart';
import '../data/location_service.dart';

/// Mapa escuro centralizado na localizacao atual. Com [aventuraId], plota os
/// pontos da aventura (coloridos por nivel de confianca), permite criar ponto
/// (toque longo) e adicionar evidencia por foto (tap no ponto).
class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key, this.aventuraId});

  final String? aventuraId;

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  static const _centroFallback = LatLng(-20.4350, -41.7920);

  final _mapController = MapController();
  final _locationService = LocationService();
  final _picker = ImagePicker();

  LatLng? _posicao;
  bool _localizando = true;
  List<PontoInteresse> _pontos = const [];

  PontoApi get _pontoApi => PontoApi(context.read<DioClient>().dio);

  @override
  void initState() {
    super.initState();
    _localizar();
    if (widget.aventuraId != null) {
      _carregarPontos(widget.aventuraId!);
    }
  }

  Future<void> _localizar() async {
    setState(() => _localizando = true);
    final pos = await _locationService.posicaoAtual();
    if (!mounted) {
      return;
    }
    setState(() {
      _posicao = pos == null ? null : LatLng(pos.latitude, pos.longitude);
      _localizando = false;
    });
    if (_posicao != null) {
      _mapController.move(_posicao!, 15);
    }
  }

  Future<void> _carregarPontos(String aventuraId) async {
    try {
      final pontos = await _pontoApi.pontosDaAventura(aventuraId);
      if (!mounted) {
        return;
      }
      setState(() => _pontos = pontos);
      if (_posicao == null && pontos.isNotEmpty) {
        _mapController.move(LatLng(pontos.first.latitude, pontos.first.longitude), 14);
      }
    } catch (_) {
      // Sem pontos no mapa — aventura pode nao ter caminho/ponto ainda.
    }
  }

  Future<void> _criarPonto(LatLng local) async {
    final aventuraId = widget.aventuraId;
    if (aventuraId == null) {
      return;
    }
    final criado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CriarPontoSheet(
        aventuraId: aventuraId,
        latitude: local.latitude,
        longitude: local.longitude,
      ),
    );
    if (criado == true) {
      await _carregarPontos(aventuraId);
    }
  }

  Future<void> _adicionarEvidencia(PontoInteresse ponto) async {
    final foto = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (foto == null) {
      return;
    }
    final pos = await _locationService.posicaoAtual();
    if (!mounted) {
      return;
    }
    if (pos == null) {
      _aviso('Ative a localizacao para registrar a evidencia');
      return;
    }
    _aviso('Enviando evidencia...');
    try {
      final dio = context.read<DioClient>().dio;
      final url = await MidiaApi(dio).uploadFoto(foto.path);
      await PontoApi(dio).adicionarEvidencia(
        pontoId: ponto.id,
        fotoUrl: url,
        tipoEvidencia: 'VISTA',
        latCaptura: pos.latitude,
        lngCaptura: pos.longitude,
      );
      if (widget.aventuraId != null) {
        await _carregarPontos(widget.aventuraId!);
      }
      _aviso('Evidencia adicionada');
    } catch (_) {
      _aviso('Nao foi possivel adicionar a evidencia (precisa estar a <50m)');
    }
  }

  void _aviso(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _mostrarPonto(PontoInteresse ponto) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.place, color: corPorNivel(ponto.nivelConfianca)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(ponto.nome ?? ponto.tipo, style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Tipo: ${ponto.tipo}'),
            if (ponto.descricao != null && ponto.descricao!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(ponto.descricao!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Confianca: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: corPorNivel(ponto.nivelConfianca),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Nivel ${ponto.nivelConfianca}/5',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _adicionarEvidencia(ponto);
              },
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Adicionar evidencia'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final temAventura = widget.aventuraId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(temAventura ? 'Pontos da aventura' : 'Mapa'),
        actions: [
          IconButton(
            tooltip: 'Minha localizacao',
            onPressed: _localizando ? null : _localizar,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _posicao ?? _centroFallback,
              initialZoom: _posicao != null ? 15 : 11,
              onLongPress: temAventura ? (_, local) => _criarPonto(local) : null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trilha.trilha_app',
              ),
              if (_pontos.isNotEmpty)
                MarkerLayer(
                  markers: [
                    for (final ponto in _pontos)
                      Marker(
                        point: LatLng(ponto.latitude, ponto.longitude),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _mostrarPonto(ponto),
                          child: Icon(Icons.place, color: corPorNivel(ponto.nivelConfianca), size: 32),
                        ),
                      ),
                  ],
                ),
              if (_posicao != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _posicao!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary, size: 32),
                    ),
                  ],
                ),
            ],
          ),
          if (temAventura)
            const Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text('Toque e segure no mapa para marcar um ponto'),
                  ),
                ),
              ),
            ),
          if (_localizando)
            const Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text('Localizando...'),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
