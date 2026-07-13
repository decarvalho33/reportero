import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/utils/filtro_denuncias.dart';

final _infra = Denuncia(
  id: '1',
  titulo: 'Buraco na calçada',
  descricao: 'Calçada danificada perto do IC-3',
  localizacao: 'IC-3',
  categoria: Categoria.infraestrutura,
  status: 'Aberta',
);
final _seguranca = Denuncia(
  id: '2',
  titulo: 'Porta arrombada',
  descricao: 'Porta do banheiro foi arrombada',
  localizacao: 'CB',
  categoria: Categoria.seguranca,
  status: 'Resolvida',
);

void main() {
  group('FiltroDenuncias.passaTexto', () {
    test('retorna true para texto vazio', () {
      expect(FiltroDenuncias.passaTexto(_infra, ''), isTrue);
    });

    test('busca no título, descrição e localização (case-insensitive)', () {
      expect(FiltroDenuncias.passaTexto(_infra, 'BURACO'), isTrue);
      expect(FiltroDenuncias.passaTexto(_infra, 'danificada'), isTrue);
      expect(FiltroDenuncias.passaTexto(_infra, 'ic-3'), isTrue);
      expect(FiltroDenuncias.passaTexto(_infra, 'inexistente'), isFalse);
    });
  });

  group('FiltroDenuncias.passaCategoria', () {
    test('categoria nula aceita qualquer denúncia', () {
      expect(FiltroDenuncias.passaCategoria(_infra, null), isTrue);
    });

    test('filtra pela categoria exata', () {
      expect(FiltroDenuncias.passaCategoria(_infra, Categoria.infraestrutura), isTrue);
      expect(FiltroDenuncias.passaCategoria(_infra, Categoria.seguranca), isFalse);
    });
  });

  group('FiltroDenuncias.passaStatus', () {
    test('status nulo aceita qualquer denúncia', () {
      expect(FiltroDenuncias.passaStatus(_infra, null), isTrue);
    });

    test('filtra pelo status exato', () {
      expect(FiltroDenuncias.passaStatus(_infra, 'Aberta'), isTrue);
      expect(FiltroDenuncias.passaStatus(_infra, 'Resolvida'), isFalse);
    });
  });

  group('FiltroDenuncias.aplicar', () {
    test('combina texto, categoria e status', () {
      final resultado = FiltroDenuncias.aplicar(
        [_infra, _seguranca],
        texto: 'porta',
        categoria: Categoria.seguranca,
        status: 'Resolvida',
      );

      expect(resultado, equals([_seguranca]));
    });

    test('sem filtros retorna a lista inteira', () {
      final resultado = FiltroDenuncias.aplicar([_infra, _seguranca]);
      expect(resultado, equals([_infra, _seguranca]));
    });
  });
}
