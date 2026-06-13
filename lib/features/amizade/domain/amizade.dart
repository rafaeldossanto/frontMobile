/// Espelha o AmizadeResponse do BFF.
class Amizade {
  const Amizade({
    required this.id,
    required this.solicitanteId,
    required this.receptorId,
    required this.status,
    this.solicitadoEm,
    this.respondidoEm,
  });

  final String id;
  final String solicitanteId;
  final String receptorId;
  final String status;
  final DateTime? solicitadoEm;
  final DateTime? respondidoEm;

  factory Amizade.fromJson(Map<String, dynamic> json) {
    return Amizade(
      id: json['id'] as String,
      solicitanteId: json['solicitanteId'] as String,
      receptorId: json['receptorId'] as String,
      status: json['status'] as String,
      solicitadoEm: _data(json['solicitadoEm']),
      respondidoEm: _data(json['respondidoEm']),
    );
  }

  static DateTime? _data(dynamic v) => v == null ? null : DateTime.tryParse(v as String);
}
