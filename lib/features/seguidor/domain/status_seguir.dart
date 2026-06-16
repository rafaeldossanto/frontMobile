/// Relacao de seguir entre o usuario logado e outro (mutuo libera adicionar amigo).
class StatusSeguir {
  const StatusSeguir({required this.sigo, required this.meSegue, required this.mutuo});

  final bool sigo;
  final bool meSegue;
  final bool mutuo;

  factory StatusSeguir.fromJson(Map<String, dynamic> json) {
    return StatusSeguir(
      sigo: json['sigo'] as bool,
      meSegue: json['meSegue'] as bool,
      mutuo: json['mutuo'] as bool,
    );
  }
}
