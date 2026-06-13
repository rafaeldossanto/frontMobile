/// Regiao de trilha (dado de referencia do BFF) usada no seletor de criar
/// aventura. So o id e o nome importam para a UI.
class Regiao {
  const Regiao({required this.id, required this.nome, this.descricao});

  final String id;
  final String nome;
  final String? descricao;

  factory Regiao.fromJson(Map<String, dynamic> json) {
    return Regiao(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
    );
  }
}
