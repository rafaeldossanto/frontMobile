/// Contadores de seguidores/seguindo de um usuario.
class Contadores {
  const Contadores({required this.seguidores, required this.seguindo});

  final int seguidores;
  final int seguindo;

  factory Contadores.fromJson(Map<String, dynamic> json) {
    return Contadores(
      seguidores: (json['seguidores'] as num).toInt(),
      seguindo: (json['seguindo'] as num).toInt(),
    );
  }
}
