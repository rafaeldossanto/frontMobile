/// Espelha o PontoInteresseResponse do BFF. `nivelConfianca` (1..5) e calculado
/// pelo APP a partir das evidencias; o app so o exibe (cor do marcador).
class PontoInteresse {
  const PontoInteresse({
    required this.id,
    required this.caminhoId,
    required this.tipo,
    this.nome,
    this.descricao,
    required this.latitude,
    required this.longitude,
    required this.nivelConfianca,
  });

  final String id;
  final String caminhoId;
  final String tipo;
  final String? nome;
  final String? descricao;
  final double latitude;
  final double longitude;
  final int nivelConfianca;

  factory PontoInteresse.fromJson(Map<String, dynamic> json) {
    return PontoInteresse(
      id: json['id'] as String,
      caminhoId: json['caminhoId'] as String,
      tipo: json['tipo'] as String,
      nome: json['nome'] as String?,
      descricao: json['descricao'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      nivelConfianca: (json['nivelConfianca'] as num?)?.toInt() ?? 1,
    );
  }
}
