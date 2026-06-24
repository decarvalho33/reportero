/* Modelo de dados para representar uma denúncia */
class Denuncia {
  final String? id;
  final String titulo;
  final String descricao;
  final String localizacao;
  final String autor;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  /* Construtor*/
  Denuncia({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.localizacao,
    this.autor = "Anônimo",
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  /*Fábrica para criar instâncias a partir de dados JSON*/
  factory Denuncia.fromJson(Map<String, dynamic> json) {
    return Denuncia(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      localizacao: json['localizacao'],
      autor: json['autor'] ?? "Anônimo",
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(), 
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  /*Método para converter a instância em um mapa JSON*/
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'localizacao': localizacao,
      'autor': autor,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}