/// Visao publica de usuario (busca para adicionar amigos). So o codigoUsuario
/// (handle publico) e o nome — sem id interno.
class UsuarioPublico {
  const UsuarioPublico({required this.codigoUsuario, required this.nome});

  final String codigoUsuario;
  final String nome;

  factory UsuarioPublico.fromJson(Map<String, dynamic> json) {
    return UsuarioPublico(
      codigoUsuario: json['codigoUsuario'] as String,
      nome: json['nome'] as String,
    );
  }
}
