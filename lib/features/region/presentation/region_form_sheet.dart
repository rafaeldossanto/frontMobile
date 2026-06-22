import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../map/data/location_service.dart';
import '../domain/city.dart';
import '../domain/region.dart';
import 'region_provider.dart';

/// Form to create/edit a folder (region): name, description, visibility and cities.
/// region == null creates; otherwise edits.
class RegionFormSheet extends StatefulWidget {
  const RegionFormSheet({super.key, this.region});

  final Region? region;

  @override
  State<RegionFormSheet> createState() => _RegionFormSheetState();
}

class _RegionFormSheetState extends State<RegionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _visibility;
  late List<City> _cities;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.region;
    _nameController = TextEditingController(text: r?.name ?? '');
    _descriptionController = TextEditingController(text: r?.description ?? '');
    _visibility = r?.visibility ?? 'PRIVADA';
    _cities = List.of(r?.cities ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addCity() async {
    final city = await showDialog<City>(
      context: context,
      builder: (_) => const _AddCityDialog(),
    );
    if (city != null) {
      setState(() => _cities.add(city));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    final ok = await context.read<RegionProvider>().save(
          id: widget.region?.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          visibility: _visibility,
          cities: _cities,
        );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
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
            Text(widget.region == null ? 'Nova pasta' : 'Editar pasta',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
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
              selected: {_visibility},
              onSelectionChanged: (s) => setState(() => _visibility = s.first),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Cidades', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addCity,
                  icon: const Icon(Icons.add_location_alt),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            ..._cities.asMap().entries.map((e) {
              final c = e.value;
              final hasCoords = c.latitude != null && c.longitude != null;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(hasCoords ? Icons.place : Icons.location_city),
                title: Text(c.name),
                subtitle: hasCoords ? Text('${c.latitude!.toStringAsFixed(4)}, ${c.longitude!.toStringAsFixed(4)}') : null,
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _cities.removeAt(e.key)),
                ),
              );
            }),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog to add a city: name + (optional) current location.
class _AddCityDialog extends StatefulWidget {
  const _AddCityDialog();

  @override
  State<_AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<_AddCityDialog> {
  final _nameController = TextEditingController();
  final _locationService = LocationService();
  double? _lat;
  double? _lng;
  double? _alt;
  bool _fetching = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _attachLocation() async {
    setState(() => _fetching = true);
    final pos = await _locationService.currentPosition();
    if (!mounted) {
      return;
    }
    setState(() {
      if (pos != null) {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _alt = pos.altitude;
      }
      _fetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasCoords = _lat != null && _lng != null;
    return AlertDialog(
      title: const Text('Adicionar cidade'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Nome da cidade'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _fetching ? null : _attachLocation,
            icon: _fetching
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(hasCoords ? Icons.check : Icons.my_location),
            label: Text(hasCoords ? 'Localizacao anexada' : 'Anexar minha localizacao'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              return;
            }
            Navigator.pop(context, City(name: name, latitude: _lat, longitude: _lng, altitude: _alt));
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
