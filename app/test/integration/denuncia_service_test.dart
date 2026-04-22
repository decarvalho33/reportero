import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/services/denuncia_service.dart';

// Lidas do ambiente (exportadas pelo CI via `supabase status`)
// com fallback para os defaults do Supabase local
String get _supabaseUrl =>
    Platform.environment['SUPABASE_URL'] ?? 'http://localhost:54321';
String get _supabaseAnonKey =>
    Platform.environment['SUPABASE_ANON_KEY'] ??
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRFA0NiK7urOL79dnpaqQ9eTuM59cLEH4m9IuJLBLc';
// Service role bypassa RLS — usado apenas no setup/teardown dos testes
String get _serviceRoleKey =>
    Platform.environment['SUPABASE_SERVICE_ROLE_KEY'] ??
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hj04zWl196z2-SB68';

void main() {
  late DenunciaService service;
  late SupabaseClient adminClient;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    // Cliente admin separado para operações de limpeza que precisam bypassar RLS
    adminClient = SupabaseClient(_supabaseUrl, _serviceRoleKey);
    service = DenunciaService();
  });

  setUp(() async {
    await adminClient.from('denuncias').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  });

  tearDown(() async {
    await adminClient.from('denuncias').delete().neq('id', '00000000-0000-0000-0000-000000000000');
  });

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
