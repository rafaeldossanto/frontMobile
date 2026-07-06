/// Mirrors the FeedAdventureResponse from the BFF: an adventure in the feed
/// with the author's name/code already resolved (a post).
class FeedAdventure {
  const FeedAdventure({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userCode,
    required this.destination,
    required this.status,
  });

  final String id;
  final String userId;
  final String userName;
  final String userCode;
  final String destination;
  final String status;

  factory FeedAdventure.fromJson(Map<String, dynamic> json) {
    return FeedAdventure(
      id: json['id'] as String,
      userId: json['usuarioId'] as String,
      userName: (json['usuarioNome'] as String?) ?? 'Trilheiro',
      userCode: (json['usuarioCodigo'] as String?) ?? '',
      destination: json['destino'] as String,
      status: json['status'] as String,
    );
  }
}
