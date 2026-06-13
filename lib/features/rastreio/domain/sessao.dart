/// Espelha o SessaoResponse do BFF (subconjunto usado no rastreio).
class Sessao {
  const Sessao({
    required this.id,
    required this.caminhoId,
    required this.status,
    this.distanciaTotalKm,
  });

  final String id;
  final String caminhoId;
  final String status;
  final double? distanciaTotalKm;

  factory Sessao.fromJson(Map<String, dynamic> json) {
    return Sessao(
      id: json['id'] as String,
      caminhoId: json['caminhoId'] as String,
      status: json['status'] as String,
      distanciaTotalKm: (json['distanciaTotalKm'] as num?)?.toDouble(),
    );
  }
}
