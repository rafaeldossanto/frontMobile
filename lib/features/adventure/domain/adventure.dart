/// Mirrors the AventuraResponse from the BFF. `regionId` can be null (adventure
/// without a resolved region); `visibility` is optional.
class Adventure {
  const Adventure({
    required this.id,
    required this.userId,
    required this.regionId,
    required this.destination,
    required this.status,
    this.visibility,
  });

  final String id;
  final String userId;
  final String regionId;
  final String destination;
  final String status;
  final String? visibility;

  factory Adventure.fromJson(Map<String, dynamic> json) {
    return Adventure(
      id: json['id'] as String,
      userId: json['usuarioId'] as String,
      regionId: (json['regiaoId'] as String?) ?? '',
      destination: json['destino'] as String,
      status: json['status'] as String,
      visibility: json['visibilidade'] as String?,
    );
  }
}
