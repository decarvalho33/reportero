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
  servicos(
    'Serviços',
    'Transporte, atendimento, burocracia ou falhas em serviços prestados no campus.',
  ),
  outros(
    'Outros',
    'Qualquer outra ocorrência ou problema que não se encaixe nas opções acima.',
  );

  final String label;
  final String descricao;
  const Categoria(this.label, this.descricao);

  static Categoria fromBanco(String? valor) {
    return Categoria.values.firstWhere(
      (e) => e.name.toLowerCase() == valor?.toLowerCase(),
      orElse: () => Categoria.outros,
    );
  }
}

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
  final int totalApoios;
  final bool jaApoiei;

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
    this.totalApoios = 0,
    this.jaApoiei = false,
  });

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
      totalApoios: _parseTotalApoios(json['apoios']),
    );
  }

  // Com select('*, apoios(count)') o PostgREST retorna apoios: [{count: N}].
  // Também aceita inteiro direto e cai para 0 quando o campo está ausente.
  static int _parseTotalApoios(dynamic apoios) {
    if (apoios is int) return apoios;
    if (apoios is List && apoios.isNotEmpty) {
      final primeiro = apoios.first;
      if (primeiro is Map && primeiro['count'] is int) {
        return primeiro['count'] as int;
      }
    }
    return 0;
  }

  Denuncia copyWith({int? totalApoios, bool? jaApoiei}) {
    return Denuncia(
      id: id,
      titulo: titulo,
      descricao: descricao,
      localizacao: localizacao,
      autor: autor,
      categoria: categoria,
      latitude: latitude,
      longitude: longitude,
      fotoUrl: fotoUrl,
      createdAt: createdAt,
      totalApoios: totalApoios ?? this.totalApoios,
      jaApoiei: jaApoiei ?? this.jaApoiei,
    );
  }

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
