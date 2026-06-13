import 'package:geolocator/geolocator.dart';

/// Obtem a localizacao atual lidando com permissao e servico desligado.
/// Retorna null quando nao da pra localizar (permissao negada / GPS off) —
/// a tela cai no centro de fallback.
class LocationService {
  Future<Position?> posicaoAtual() async {
    final servicoAtivo = await Geolocator.isLocationServiceEnabled();
    if (!servicoAtivo) {
      return null;
    }

    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }
}
