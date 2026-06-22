import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../../point/data/media_api.dart';
import '../../point/data/point_api.dart';
import '../../point/domain/point_of_interest.dart';
import '../../point/presentation/create_point_sheet.dart';
import '../../point/presentation/color_level.dart';
import '../data/location_service.dart';

/// Dark map centered on the current location. With [adventureId], plots the
/// points of the adventure (colored by confidence level), allows creating a point
/// (long press) and adding evidence by photo (tap on point).
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.adventureId});

  final String? adventureId;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const _fallbackCenter = LatLng(-20.4350, -41.7920);

  final _mapController = MapController();
  final _locationService = LocationService();
  final _picker = ImagePicker();

  LatLng? _position;
  bool _locating = true;
  List<PointOfInterest> _points = const [];

  PointApi get _pointApi => PointApi(context.read<DioClient>().dio);

  @override
  void initState() {
    super.initState();
    _locate();
    if (widget.adventureId != null) {
      _loadPoints(widget.adventureId!);
    }
  }

  Future<void> _locate() async {
    setState(() => _locating = true);
    final pos = await _locationService.currentPosition();
    if (!mounted) {
      return;
    }
    setState(() {
      _position = pos == null ? null : LatLng(pos.latitude, pos.longitude);
      _locating = false;
    });
    if (_position != null) {
      _mapController.move(_position!, 15);
    }
  }

  Future<void> _loadPoints(String adventureId) async {
    try {
      final points = await _pointApi.pointsByAdventure(adventureId);
      if (!mounted) {
        return;
      }
      setState(() => _points = points);
      if (_position == null && points.isNotEmpty) {
        _mapController.move(LatLng(points.first.latitude, points.first.longitude), 14);
      }
    } catch (_) {
      // No points on the map — adventure may not have a path/point yet.
    }
  }

  Future<void> _createPoint(LatLng location) async {
    final adventureId = widget.adventureId;
    if (adventureId == null) {
      return;
    }
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CreatePointSheet(
        adventureId: adventureId,
        latitude: location.latitude,
        longitude: location.longitude,
      ),
    );
    if (created == true) {
      await _loadPoints(adventureId);
    }
  }

  Future<void> _addEvidence(PointOfInterest point) async {
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (photo == null) {
      return;
    }
    final pos = await _locationService.currentPosition();
    if (!mounted) {
      return;
    }
    if (pos == null) {
      _showMessage('Ative a localizacao para registrar a evidencia');
      return;
    }
    _showMessage('Enviando evidencia...');
    try {
      final dio = context.read<DioClient>().dio;
      final url = await MediaApi(dio).uploadMedia(photo.path);
      await PointApi(dio).addEvidence(
        pointId: point.id,
        photoUrl: url,
        evidenceType: 'VISTA',
        captureLatitude: pos.latitude,
        captureLongitude: pos.longitude,
      );
      if (widget.adventureId != null) {
        await _loadPoints(widget.adventureId!);
      }
      _showMessage('Evidencia adicionada');
    } catch (_) {
      _showMessage('Nao foi possivel adicionar a evidencia (precisa estar a <50m)');
    }
  }

  void _showMessage(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _showPoint(PointOfInterest point) {
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
                Icon(Icons.place, color: colorByLevel(point.confidenceLevel)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(point.name ?? point.type, style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Tipo: ${point.type}'),
            if (point.description != null && point.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(point.description!),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Confianca: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorByLevel(point.confidenceLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Nivel ${point.confidenceLevel}/5',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _addEvidence(point);
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
    final hasAdventure = widget.adventureId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(hasAdventure ? 'Pontos da aventura' : 'Mapa'),
        actions: [
          IconButton(
            tooltip: 'Minha localizacao',
            onPressed: _locating ? null : _locate,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _position ?? _fallbackCenter,
              initialZoom: _position != null ? 15 : 11,
              onLongPress: hasAdventure ? (_, location) => _createPoint(location) : null,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trilha.trilha_app',
              ),
              if (_points.isNotEmpty)
                MarkerLayer(
                  markers: [
                    for (final point in _points)
                      Marker(
                        point: LatLng(point.latitude, point.longitude),
                        width: 36,
                        height: 36,
                        child: GestureDetector(
                          onTap: () => _showPoint(point),
                          child: Icon(Icons.place, color: colorByLevel(point.confidenceLevel), size: 32),
                        ),
                      ),
                  ],
                ),
              if (_position != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _position!,
                      width: 40,
                      height: 40,
                      child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary, size: 32),
                    ),
                  ],
                ),
            ],
          ),
          if (hasAdventure)
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
          if (_locating)
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
