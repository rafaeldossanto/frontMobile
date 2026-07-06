import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../core/env/env.dart';
import '../domain/gps_point.dart';

/// Assinatura da trilha ao vivo: conecta no STOMP/SockJS do loc
/// (`/ws-localizacao`, Bearer no CONNECT) e assina `/topic/sessao/{id}`.
/// O backend autoriza o SUBSCRIBE pela visibilidade da sessao — aqui so
/// conectamos e entregamos cada ponto recebido ao callback.
class LiveLocationSocket {
  LiveLocationSocket(this._token);

  final String _token;
  StompClient? _client;

  void connect({
    required String sessionId,
    required void Function(GpsPoint point) onPoint,
    void Function()? onError,
  }) {
    _client = StompClient(
      config: StompConfig.sockJS(
        url: Env.locWsUrl,
        stompConnectHeaders: {'Authorization': 'Bearer $_token'},
        onConnect: (frame) {
          _client?.subscribe(
            destination: '/topic/sessao/$sessionId',
            callback: (frame) {
              final body = frame.body;
              if (body != null) {
                onPoint(GpsPoint.fromJson(jsonDecode(body) as Map<String, dynamic>));
              }
            },
          );
        },
        onWebSocketError: (_) => onError?.call(),
        onStompError: (_) => onError?.call(),
      ),
    );
    _client!.activate();
  }

  void dispose() {
    _client?.deactivate();
    _client = null;
  }
}
