/// Cidade que compoe uma regiao. Coordenadas opcionais (podem ficar vazias).
class Cidade {
  const Cidade({required this.nome, this.latitude, this.longitude, this.altitude});

  final String nome;
  final double? latitude;
  final double? longitude;
  final double? altitude;

  factory Cidade.fromJson(Map<String, dynamic> json) {
    return Cidade(
      nome: json['nome'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
      };
}
