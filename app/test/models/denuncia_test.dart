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
        'categoria': 'Infraestrutura',
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.id, equals('abc-123'));
      expect(denuncia.titulo, equals('Buraco na calçada'));
      expect(denuncia.descricao, equals('Grande buraco próximo ao IC-3'));
      expect(denuncia.localizacao, equals('IC-3'));
      expect(denuncia.autor, equals('Maria'));
      expect(denuncia.createdAt, equals(DateTime.parse('2024-01-15T10:00:00.000Z')));
      expect(denuncia.categoria, equals('Infraestrutura'));
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

    test('usa "Outros" quando categoria é nula', () {
      final json = {
        'id': 'abc-123',
        'titulo': 'Título',
        'descricao': 'Descrição',
        'localizacao': 'Local',
        'autor': 'João',
        'created_at': null,
        'categoria': null,
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.categoria, equals('Outros'));
    });

    test('usa "Outros" quando categoria está ausente do json', () {
      final json = {
        'id': 'abc-123',
        'titulo': 'Título',
        'descricao': 'Descrição',
        'localizacao': 'Local',
        'autor': 'João',
        'created_at': null,
      };

      final denuncia = Denuncia.fromJson(json);

      expect(denuncia.categoria, equals('Outros'));
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

    test('inclui categoria no json', () {
      final denuncia = Denuncia(
        titulo: 'Título',
        descricao: 'Descrição',
        localizacao: 'Local',
        categoria: 'Segurança',
      );

      final json = denuncia.toJson();

      expect(json['categoria'], equals('Segurança'));
    });

    test('usa "Outros" como categoria padrão no toJson', () {
      final denuncia = Denuncia(
        titulo: 'Título',
        descricao: 'Descrição',
        localizacao: 'Local',
      );

      final json = denuncia.toJson();

      expect(json['categoria'], equals('Outros'));
    });
  });
}
