/// Pagina generica do BFF. O BFF serializa com as chaves do Spring Data
/// (`content`, `number`, `size`, `totalElements`, `totalPages`). O `fromItem`
/// converte cada elemento do `content` no tipo de dominio.
class PaginaResponse<T> {
  const PaginaResponse({
    required this.conteudo,
    required this.pagina,
    required this.tamanho,
    required this.total,
    required this.totalPaginas,
  });

  final List<T> conteudo;
  final int pagina;
  final int tamanho;
  final int total;
  final int totalPaginas;

  factory PaginaResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    final itens = (json['content'] as List<dynamic>? ?? const [])
        .map((e) => fromItem(e as Map<String, dynamic>))
        .toList();
    return PaginaResponse(
      conteudo: itens,
      pagina: (json['number'] as num?)?.toInt() ?? 0,
      tamanho: (json['size'] as num?)?.toInt() ?? itens.length,
      total: (json['totalElements'] as num?)?.toInt() ?? itens.length,
      totalPaginas: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
