import 'cidade.dart';

/// Regiao = pasta de aventuras do usuario. Espelha o RegiaoResponse do BFF
/// (visibilidade como String: PRIVADA/AMIGOS/PUBLICA).
class Regiao {
  const Regiao({
    required this.id,
    required this.nome,
    this.usuarioId,
    this.descricao,
    this.visibilidade = 'PRIVADA',
    this.cidades = const [],
  });

  final String id;
  final String? usuarioId;
  final String nome;
  final String? descricao;
  final String visibilidade;
  final List<Cidade> cidades;

  factory Regiao.fromJson(Map<String, dynamic> json) {
    return Regiao(
      id: json['id'] as String,
      usuarioId: json['usuarioId'] as String?,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String?,
      visibilidade: (json['visibilidade'] as String?) ?? 'PRIVADA',
      cidades: (json['cidades'] as List<dynamic>? ?? const [])
          .map((c) => Cidade.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
