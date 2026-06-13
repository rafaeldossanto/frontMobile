/// Espelha o UsuarioResponse do BFF (subconjunto que o app usa).
class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.codigoUsuario,
  });

  final String id;
  final String nome;
  final String email;
  final String codigoUsuario;

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as String,
      nome: json['nome'] as String,
      email: json['email'] as String,
      codigoUsuario: (json['codigoUsuario'] as String?) ?? '',
    );
  }
}
