/// Espelha o CaminhoResponse do BFF. Um caminho e uma "perna" da aventura, com
/// numero sequencial; fica em andamento ate ser finalizado (distancia vem do GPS).
class Caminho {
  const Caminho({
    required this.id,
    required this.aventuraId,
    required this.cor,
    this.numero,
    this.iniciadoEm,
    this.finalizadoEm,
    this.distanciaTotalKm,
  });

  final String id;
  final String aventuraId;
  final String cor;
  final int? numero;
  final DateTime? iniciadoEm;
  final DateTime? finalizadoEm;
  final double? distanciaTotalKm;

  bool get finalizado => finalizadoEm != null;

  factory Caminho.fromJson(Map<String, dynamic> json) {
    return Caminho(
      id: json['id'] as String,
      aventuraId: json['aventuraId'] as String,
      cor: (json['cor'] as String?) ?? 'ROXO',
      numero: (json['numero'] as num?)?.toInt(),
      iniciadoEm: _data(json['iniciadoEm']),
      finalizadoEm: _data(json['finalizadoEm']),
      distanciaTotalKm: (json['distanciaTotalKm'] as num?)?.toDouble(),
    );
  }

  static DateTime? _data(dynamic valor) =>
      valor == null ? null : DateTime.tryParse(valor as String);
}
