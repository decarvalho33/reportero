import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/services/denuncia_service.dart';

const _supabaseUrl = 'https://wfxugctznmathcwqsgkt.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndmeHVnY3R6bm1hdGhjd3FzZ2t0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NjEwOTIsImV4cCI6MjA5MjUzNzA5Mn0.CFdzBSEQXcQ-pQnN1J_gum_ynzB1BO4aHO_axg28T14';

Future<void> _limparTabela() async {
  try {
    await Supabase.instance.client
        .from('denuncias')
        .delete()
        .neq('id', '00000000-0000-0000-0000-000000000000');
  } catch (e) {
    // ignore: table may be empty or cleanup failed - tests will still run
    throw Exception("Falha ao limpar a tabela de denúncias: $e");
  }
}

void main() {
  late DenunciaService service;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global =
        null; // allow real HTTP — TestWidgetsFlutterBinding blocks it by default
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    // Verify REST connectivity before running tests
    await Supabase.instance.client.from('denuncias').select();
    service = DenunciaService();
  });

  setUp(() async => _limparTabela());

  tearDown(() async => _limparTabela());

  group('DenunciaService', () {
    test(
      'obtenerDenuncias retorna lista vazia quando banco está limpo',
      () async {
        final resultado = await service.obtenerDenuncias();
        expect(resultado, isEmpty);
      },
    );

    test('enviarDenuncia persiste a denúncia no banco com todos os campos novos', () async {
      final denuncia = Denuncia(
        titulo: 'Buraco na calçada',
        descricao: 'Grande buraco próximo ao IC-3',
        localizacao: 'IC-3',
        autor: 'Testador',
        categoria: Categoria.infraestrutura,
        fotoUrl: 'https://example.com/foto.jpg',
        latitude: -22.8123,
        longitude: -47.0654,
      );

      await service.enviarDenuncia(denuncia);

      final resultado = await service.obtenerDenuncias();
      expect(resultado.length, equals(1));
      expect(resultado.first.titulo, equals('Buraco na calçada'));
      expect(resultado.first.descricao, equals('Grande buraco próximo ao IC-3'));
      expect(resultado.first.localizacao, equals('IC-3'));
      expect(resultado.first.autor, equals('Testador'));
      expect(resultado.first.categoria, equals(Categoria.infraestrutura));
      expect(resultado.first.fotoUrl, equals('https://example.com/foto.jpg'));
      expect(resultado.first.latitude, closeTo(-22.8123, 0.0001));
      expect(resultado.first.longitude, closeTo(-47.0654, 0.0001));
      expect(resultado.first.status, equals(StatusDenuncia.pendente));
    });

    test('enviarDenuncia deixa autor_id nulo quando não há usuário autenticado', () async {
      final denuncia = Denuncia(
        titulo: 'Denúncia anônima',
        descricao: 'Enviada sem sessão ativa',
        localizacao: 'IC-3',
      );

      await service.enviarDenuncia(denuncia);

      final resultado = await service.obtenerDenuncias();
      expect(resultado.first.autorId, isNull);
    });

    test('enviarDenuncia lanca erro quando apenas latitude e fornecida', () async {
      final denuncia = Denuncia(
        titulo: 'Buraco na calçada',
        descricao: 'Grande buraco próximo ao IC-3',
        localizacao: 'IC-3',
        autor: 'Testador',
        latitude: -22.8123,
      );

      expect(
        () => service.enviarDenuncia(denuncia),
        throwsArgumentError,
      );
    });

    test('enviarDenuncia lanca erro quando apenas longitude e fornecida', () async {
      final denuncia = Denuncia(
        titulo: 'Buraco na calçada',
        descricao: 'Grande buraco próximo ao IC-3',
        localizacao: 'IC-3',
        autor: 'Testador',
        longitude: -47.0654,
      );

      expect(
        () => service.enviarDenuncia(denuncia),
        throwsArgumentError,
      );
    });

    test('enviarDenuncia lanca erro com latitude fora do limite', () async {
      final denuncia = Denuncia(
        titulo: 'Buraco na calçada',
        descricao: 'Grande buraco próximo ao IC-3',
        localizacao: 'IC-3',
        autor: 'Testador',
        latitude: 95.0,
        longitude: -47.0654,
      );

      expect(
        () => service.enviarDenuncia(denuncia),
        throwsArgumentError,
      );
    });

    test('enviarDenuncia lanca erro com longitude fora do limite', () async {
      final denuncia = Denuncia(
        titulo: 'Buraco na calçada',
        descricao: 'Grande buraco próximo ao IC-3',
        localizacao: 'IC-3',
        autor: 'Testador',
        latitude: -22.8123,
        longitude: 185.0,
      );

      expect(
        () => service.enviarDenuncia(denuncia),
        throwsArgumentError,
      );
    });

    test('obtenerDenuncias retorna todas as denúncias inseridas', () async {
      await service.enviarDenuncia(
        Denuncia(titulo: 'Denúncia 1', descricao: 'Desc 1', localizacao: 'IC'),
      );
      await service.enviarDenuncia(
        Denuncia(titulo: 'Denúncia 2', descricao: 'Desc 2', localizacao: 'CB'),
      );

      final resultado = await service.obtenerDenuncias();
      expect(resultado.length, equals(2));
    });

    test(
      'obtenerDenuncias retorna ordenado por created_at decrescente',
      () async {
        await service.enviarDenuncia(
          Denuncia(
            titulo: 'Primeira',
            descricao: 'Enviada primeiro',
            localizacao: 'IC',
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
        await service.enviarDenuncia(
          Denuncia(
            titulo: 'Segunda',
            descricao: 'Enviada depois',
            localizacao: 'CB',
          ),
        );

        final resultado = await service.obtenerDenuncias();
        expect(resultado.first.titulo, equals('Segunda'));
        expect(resultado.last.titulo, equals('Primeira'));
      },
    );
  });

  group('DenunciaService — restrição de autoria (US 5.6/5.7)', () {
    // Sem sessão ativa (a suíte usa a anon key, sem login), currentUser é
    // sempre nulo — então qualquer editarDenuncia/excluirDenuncia deve ser
    // recusado pela checagem de autoria antes de qualquer chamada de rede,
    // independentemente de a denúncia ter dono ou não.
    test('editarDenuncia recusa a edição sem usuário autenticado', () async {
      final denuncia = Denuncia(
        id: '00000000-0000-0000-0000-000000000001',
        titulo: 'Título',
        descricao: 'Descrição',
        localizacao: 'Local',
        autorId: 'algum-usuario',
      );

      expect(
        () => service.editarDenuncia(denuncia),
        throwsA(isA<Exception>()),
      );
    });

    test('excluirDenuncia recusa a exclusão sem usuário autenticado', () async {
      final denuncia = Denuncia(
        id: '00000000-0000-0000-0000-000000000001',
        titulo: 'Título',
        descricao: 'Descrição',
        localizacao: 'Local',
        autorId: 'algum-usuario',
      );

      expect(
        () => service.excluirDenuncia(denuncia),
        throwsA(isA<Exception>()),
      );
    });

    test('excluirDenuncia recusa mesmo quando a denúncia não tem autor_id', () async {
      final denunciaOrfa = Denuncia(
        id: '00000000-0000-0000-0000-000000000002',
        titulo: 'Título',
        descricao: 'Descrição',
        localizacao: 'Local',
      );

      expect(
        () => service.excluirDenuncia(denunciaOrfa),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('DenunciaService — apoios', () {
    // Insere uma denúncia e devolve o id gerado pelo banco.
    Future<String> inserirDenuncia(String titulo) async {
      await service.enviarDenuncia(
        Denuncia(titulo: titulo, descricao: 'Desc', localizacao: 'IC'),
      );
      final lista = await service.obtenerDenuncias();
      return lista.firstWhere((d) => d.titulo == titulo).id!;
    }

    test('apoiar registra apoio e reflete em totalApoios/jaApoiei', () async {
      final id = await inserirDenuncia('Com apoio');

      await service.apoiar(id);

      final resultado = await service.obtenerDenuncias();
      expect(resultado.first.totalApoios, equals(1));
      expect(resultado.first.jaApoiei, isTrue);
    });

    test('apoiar é idempotente (não duplica apoio do mesmo dispositivo)',
        () async {
      final id = await inserirDenuncia('Apoio dobrado');

      await service.apoiar(id);
      await service.apoiar(id); // segunda chamada não deve lançar nem somar

      final resultado = await service.obtenerDenuncias();
      expect(resultado.first.totalApoios, equals(1));
    });

    test('removerApoio retira o apoio do dispositivo', () async {
      final id = await inserirDenuncia('Apoio removido');
      await service.apoiar(id);

      await service.removerApoio(id);

      final resultado = await service.obtenerDenuncias();
      expect(resultado.first.totalApoios, equals(0));
      expect(resultado.first.jaApoiei, isFalse);
    });

    test('denúncia sem apoios começa com totalApoios 0 e jaApoiei false',
        () async {
      await inserirDenuncia('Sem apoio');

      final resultado = await service.obtenerDenuncias();
      expect(resultado.first.totalApoios, equals(0));
      expect(resultado.first.jaApoiei, isFalse);
    });
  });
}
