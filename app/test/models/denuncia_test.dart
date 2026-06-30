import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/denuncia.dart';

void main() {
  group('Denuncia.fromJson', () {
    test('mapeia todos os campos corretamente', () {
      final json = {
        'id': 'abc-123',
        'titulo': 'Buraco na calçada',
        'descricao': 'Grande buraco próximo ao IC-3',
        'localizacao': 'IC-3',
        'autor': 'Maria',
        'created_at': '2024-01-15T10:00:00.000Z',
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.id, equals('abc-123'));
      expect(denuncia.titulo, equals('Buraco na calçada'));
      expect(denuncia.descricao, equals('Grande buraco próximo ao IC-3'));
      expect(denuncia.localizacao, equals('IC-3'));
      expect(denuncia.autor, equals('Maria'));
      expect(denuncia.createdAt, equals(DateTime.parse('2024-01-15T10:00:00.000Z')));
    });

    test('usa "Anônimo" quando autor é nulo', () {
      final json = {
        'id': 'abc-123',
        'titulo': 'Título',
        'descricao': 'Descrição',
        'localizacao': 'Local',
        'autor': null,
        'created_at': null,
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.autor, equals('Anônimo'));
    });

    test('aceita created_at nulo', () {
      final json = {
        'id': 'abc-123',
        'titulo': 'Título',
        'descricao': 'Descrição',
        'localizacao': 'Local',
        'autor': 'João',
        'created_at': null,
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.createdAt, isNull);
    });
  });

  group('Denuncia.toJson', () {
    test('retorna os campos corretos', () {
      final denuncia = Denuncia(
        titulo: 'Iluminação quebrada',
        descricao: 'Lâmpada queimada no corredor',
        localizacao: 'CB',
        autor: 'Ana',
      );

      final json = denuncia.toJson();

      expect(json['titulo'], equals('Iluminação quebrada'));
      expect(json['descricao'], equals('Lâmpada queimada no corredor'));
      expect(json['localizacao'], equals('CB'));
      expect(json['autor'], equals('Ana'));
    });

    test('não inclui id nem created_at', () {
      final denuncia = Denuncia(
        titulo: 'Título',
        descricao: 'Descrição',
        localizacao: 'Local',
      );

      final json = denuncia.toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('created_at'), isFalse);
    });
  });

  group('Denuncia.totalApoios', () {
    test('extrai a contagem do agregado do Supabase (apoios: [{count: N}])', () {
      final json = {
        'id': 'abc-123',
        'titulo': 'Título',
        'descricao': 'Descrição',
        'localizacao': 'Local',
        'apoios': [
          {'count': 7},
        ],
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.totalApoios, equals(7));
    });

    test('usa 0 quando o campo apoios está ausente', () {
      final json = {
        'id': 'abc-123',
        'titulo': 'Título',
        'descricao': 'Descrição',
        'localizacao': 'Local',
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.totalApoios, equals(0));
      expect(denuncia.jaApoiei, isFalse);
    });

    test('usa 0 quando a lista de apoios vem vazia', () {
      final json = {
        'id': 'abc-123',
        'titulo': 'Título',
        'descricao': 'Descrição',
        'localizacao': 'Local',
        'apoios': <Map<String, dynamic>>[],
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.totalApoios, equals(0));
    });
  });

  group('Denuncia.copyWith', () {
    test('altera jaApoiei preservando os demais campos', () {
      final original = Denuncia(
        id: 'abc-123',
        titulo: 'Título',
        descricao: 'Descrição',
        localizacao: 'Local',
        totalApoios: 3,
      );

      final copia = original.copyWith(jaApoiei: true);

      expect(copia.jaApoiei, isTrue);
      expect(copia.totalApoios, equals(3));
      expect(copia.id, equals('abc-123'));
      expect(copia.titulo, equals('Título'));
    });
  });
}
