import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/services/denuncia_service.dart';

const _supabaseUrl = 'http://localhost:54321';
String get _supabaseAnonKey => Platform.environment['SUPABASE_ANON_KEY'] ?? '';

// Limpa a tabela via conexão direta ao PostgreSQL (sem depender de PostgREST ou JWT)
Future<void> _truncarTabela() async {
  final conn = await Connection.open(
    Endpoint(
      host: '127.0.0.1',
      port: 54322,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );
  await conn.execute('TRUNCATE TABLE public.denuncias');
  await conn.close();
}

void main() {
  late DenunciaService service;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    service = DenunciaService();
  });

  setUp(() async => _truncarTabela());

  tearDown(() async => _truncarTabela());

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
