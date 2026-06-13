import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../caminho/data/caminho_api.dart';
import '../data/rastreio_api.dart';

/// Rastreio GPS ao vivo de um caminho: abre uma sessao, segue o `geolocator`,
/// publica cada ponto e desenha o trajeto. Ao finalizar, fecha a sessao e o
/// caminho (a distancia real e calculada pelo backend a partir dos pontos).
class RastreioScreen extends StatefulWidget {
  const RastreioScreen({super.key, required this.caminhoId});

  final String caminhoId;

  @override
  State<RastreioScreen> createState() => _RastreioScreenState();
}

class _RastreioScreenState extends State<RastreioScreen> {
  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 5,
  );

  final _mapController = MapController();
  late final RastreioApi _api = RastreioApi(context.read<DioClient>().dio);
  late final CaminhoApi _caminhoApi = CaminhoApi(context.read<DioClient>().dio);

  StreamSubscription<Position>? _sub;
  String? _sessaoId;
  final List<LatLng> _trajeto = [];
  String _status = 'Iniciando...';
  bool _finalizando = false;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _iniciar() async {
    final usuarioId = context.read<AuthProvider>().usuarioId;
    if (usuarioId == null) {
      return;
    }

    final permissao = await _garantirPermissao();
    if (!mounted) {
      return;
    }
    if (!permissao) {
      setState(() => _status = 'Permissao de localizacao negada');
      return;
    }

    try {
      final sessao = await _api.iniciarSessao(caminhoId: widget.caminhoId, usuarioId: usuarioId);
      if (!mounted) {
        return;
      }
      setState(() {
        _sessaoId = sessao.id;
        _status = 'Rastreando';
      });
      _sub = Geolocator.getPositionStream(locationSettings: _settings).listen(_aoMover);
    } catch (_) {
      setState(() => _status = 'Nao foi possivel iniciar a sessao');
    }
  }

  Future<bool> _garantirPermissao() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    return permissao != LocationPermission.denied &&
        permissao != LocationPermission.deniedForever;
  }

  void _aoMover(Position pos) {
    final ponto = LatLng(pos.latitude, pos.longitude);
    setState(() => _trajeto.add(ponto));
    _mapController.move(ponto, 16);

    final sessaoId = _sessaoId;
    if (sessaoId != null) {
      _api
          .registrarPonto(
            sessaoId: sessaoId,
            latitude: pos.latitude,
            longitude: pos.longitude,
            altitude: pos.altitude,
            precisao: pos.accuracy,
            velocidade: pos.speed,
          )
          .ignore();
    }
  }

  Future<void> _finalizar() async {
    final sessaoId = _sessaoId;
    if (sessaoId == null) {
      return;
    }
    setState(() => _finalizando = true);
    await _sub?.cancel();
    try {
      await _api.finalizarSessao(sessaoId);
      await _caminhoApi.finalizar(widget.caminhoId);
    } catch (_) {
      // Mesmo com erro de rede, encerra a tela; o usuario reabre se precisar.
    }
    if (!mounted) {
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final centro = _trajeto.isNotEmpty ? _trajeto.last : const LatLng(-20.4350, -41.7920);
    return Scaffold(
      appBar: AppBar(
        title: Text(_status),
        actions: [
          if (_finalizando)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton.icon(
              onPressed: _sessaoId == null ? null : _finalizar,
              icon: const Icon(Icons.flag),
              label: const Text('Finalizar'),
            ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(initialCenter: centro, initialZoom: 16),
        children: [
          TileLayer(
            urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.trilha.trilha_app',
          ),
          if (_trajeto.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(points: _trajeto, strokeWidth: 4, color: Theme.of(context).colorScheme.primary),
              ],
            ),
          if (_trajeto.isNotEmpty)
            MarkerLayer(
              markers: [
                Marker(
                  point: _trajeto.last,
                  width: 36,
                  height: 36,
                  child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
