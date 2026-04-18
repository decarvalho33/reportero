class Denuncia {
  final String? id;
  final String titulo;
  final String descricao;
  final String localizacao;
  final String autor;
  final DateTime? createdAt;

  Denuncia({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.localizacao,
    this.autor = "Anônimo",
    this.createdAt,
  });

  // Essencial para o João (Service) converter dados do banco
  factory Denuncia.fromJson(Map<String, dynamic> json) {
    return Denuncia(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      localizacao: json['localizacao'],
      autor: json['autor'] ?? "Anônimo",
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  // Usado para enviar dados ao Supabase
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'localizacao': localizacao,
      'autor': autor,
    };
  }
}