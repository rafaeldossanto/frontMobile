import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/network/dio_client.dart';
import '../data/region_api.dart';
import '../domain/region.dart';

/// Explore public and friends' folders (GET /bff/regioes/descobrir).
class ExploreRegionsScreen extends StatefulWidget {
  const ExploreRegionsScreen({super.key});

  @override
  State<ExploreRegionsScreen> createState() => _ExploreRegionsScreenState();
}

class _ExploreRegionsScreenState extends State<ExploreRegionsScreen> {
  late final RegionApi _api = RegionApi(context.read<DioClient>().dio);

  List<Region> _regions = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final regions = await _api.discover();
      if (!mounted) {
        return;
      }
      setState(() {
        _regions = regions;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _regions.isEmpty
              ? const Center(child: Text('Nenhuma pasta publica ou de amigos por aqui.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _regions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final r = _regions[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.public),
                        title: Text(r.name),
                        subtitle: Text([
                          r.visibility,
                          '${r.cities.length} cidade(s)',
                          if (r.description != null && r.description!.isNotEmpty) r.description!,
                        ].join(' • ')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/regioes/detalhe', extra: r),
                      ),
                    );
                  },
                ),
    );
  }
}
