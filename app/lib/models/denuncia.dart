/// Enumeração que representa as categorias de denúncias, cada uma com um rótulo e uma descrição detalhada.
enum Categoria {
  infraestrutura(
    'Infraestrutura',
    'Buracos, postes apagados, vazamentos, calçadas danificadas ou problemas em prédios.',
  ),
  seguranca(
    'Segurança',
    'Atividades suspeitas, iluminação precária com sensação de risco ou ocorrências de perigo.',
  ),
  limpeza(
    'Limpeza',
    'Acúmulo de lixo, entulho, banheiros sem manutenção ou descarte irregular de resíduos.',
  ),
  acessibilidade(
    'Acessibilidade',
    'Rampas bloqueadas, pisos táteis danificados, elevadores quebrados ou falta de acesso.',
  ),
  outros(
    'Outros',
    'Qualquer outra ocorrência ou problema que não se encaixe nas opções acima.',
  );

  final String label;
  final String descricao;
  const Categoria(this.label, this.descricao);

  /// Converte uma string do banco de dados em um valor da enumeração Categoria. Se o valor não corresponder a nenhuma categoria, retorna Categoria.outros.
  static Categoria fromBanco(String? valor) {
    return Categoria.values.firstWhere(
      (e) => e.name.toLowerCase() == valor?.toLowerCase(),
      orElse: () => Categoria.outros,
    );
  }
}

/// Modelo de dados para representar uma denúncia, incluindo informações como título, descrição, localização, autor, coordenadas geográficas, URL da foto e data de criação.
class Denuncia {
  final String? id;
  final String titulo;
  final String descricao;
  final String localizacao;
  final String autor;
  final Categoria categoria;
  final double? latitude;
  final double? longitude;
  final String? fotoUrl;
  final DateTime? createdAt;

  /// Construtor da classe Denuncia, que inicializa os campos obrigatórios e opcionais.
  Denuncia({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.localizacao,
    this.autor = "Anônimo",
    this.categoria = Categoria.outros,
    this.latitude,
    this.longitude,
    this.fotoUrl,
    this.createdAt,
  });

  /// Cria uma instância de Denuncia a partir de um mapa JSON.
  factory Denuncia.fromJson(Map<String, dynamic> json) {
    return Denuncia(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      localizacao: json['localizacao'],
      autor: json['autor'] ?? "Anônimo",
      categoria: Categoria.fromBanco(json['categoria']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      fotoUrl: json['foto_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  /// Converte a instância em um mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'localizacao': localizacao,
      'autor': autor,
      'categoria': categoria.name,
      'latitude': latitude,
      'longitude': longitude,
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
  }
}
