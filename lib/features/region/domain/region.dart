import 'city.dart';

/// Region = adventure folder for the user. Mirrors the RegiaoResponse from the BFF
/// (visibility as String: PRIVADA/AMIGOS/PUBLICA).
class Region {
  const Region({
    required this.id,
    required this.name,
    this.userId,
    this.description,
    this.visibility = 'PRIVADA',
    this.cities = const [],
  });

  final String id;
  final String? userId;
  final String name;
  final String? description;
  final String visibility;
  final List<City> cities;

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      userId: json['usuarioId'] as String?,
      name: json['nome'] as String,
      description: json['descricao'] as String?,
      visibility: (json['visibilidade'] as String?) ?? 'PRIVADA',
      cities: (json['cidades'] as List<dynamic>? ?? const [])
          .map((c) => City.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
