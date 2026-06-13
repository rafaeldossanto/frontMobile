/// Espelha o AventuraResponse do BFF. `regiaoId` pode vir nulo (aventura sem
/// regiao resolvida); `visibilidade` e opcional.
class Aventura {
  const Aventura({
    required this.id,
    required this.usuarioId,
    required this.regiaoId,
    required this.destino,
    required this.status,
    this.visibilidade,
  });

  final String id;
  final String usuarioId;
  final String regiaoId;
  final String destino;
  final String status;
  final String? visibilidade;

  factory Aventura.fromJson(Map<String, dynamic> json) {
    return Aventura(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String,
      regiaoId: (json['regiaoId'] as String?) ?? '',
      destino: json['destino'] as String,
      status: json['status'] as String,
      visibilidade: json['visibilidade'] as String?,
    );
  }
}
