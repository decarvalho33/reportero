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
    print('_limparTabela: $e');
  }
}

void main() {
  late DenunciaService service;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    // Verify REST connectivity before running tests
    await Supabase.instance.client.from('denuncias').select();
    service = DenunciaService();
  });

  setUp(() async => _limparTabela());

  tearDown(() async => _limparTabela());

  group('DenunciaService', () {
    test('obtenerDenuncias retorna lista vazia quando banco está limpo', () async {
      final resultado = await service.obtenerDenuncias();
      expect(resultado, isEmpty);
    });

    test('enviarDenuncia persiste a denúncia no banco', () async {
      final denuncia = Denuncia(
        titulo: 'Buraco na calçada',
        descricao: 'Grande buraco próximo ao IC-3',
        localizacao: 'IC-3',
        autor: 'Testador',
      );

      await service.enviarDenuncia(denuncia);

      final resultado = await service.obtenerDenuncias();
      expect(resultado.length, equals(1));
      expect(resultado.first.titulo, equals('Buraco na calçada'));
      expect(resultado.first.localizacao, equals('IC-3'));
      expect(resultado.first.autor, equals('Testador'));
    });

    test('obtenerDenuncias retorna todas as denúncias inseridas', () async {
      await service.enviarDenuncia(Denuncia(
        titulo: 'Denúncia 1',
        descricao: 'Desc 1',
        localizacao: 'IC',
      ));
      await service.enviarDenuncia(Denuncia(
        titulo: 'Denúncia 2',
        descricao: 'Desc 2',
        localizacao: 'CB',
      ));

      final resultado = await service.obtenerDenuncias();
      expect(resultado.length, equals(2));
    });

    test('obtenerDenuncias retorna ordenado por created_at decrescente', () async {
      await service.enviarDenuncia(Denuncia(
        titulo: 'Primeira',
        descricao: 'Enviada primeiro',
        localizacao: 'IC',
      ));
      await Future.delayed(const Duration(milliseconds: 100));
      await service.enviarDenuncia(Denuncia(
        titulo: 'Segunda',
        descricao: 'Enviada depois',
        localizacao: 'CB',
      ));

      final resultado = await service.obtenerDenuncias();
      expect(resultado.first.titulo, equals('Segunda'));
      expect(resultado.last.titulo, equals('Primeira'));
    });
  });
}
