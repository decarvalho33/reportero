import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/viewmodels/minhas_denuncias_viewmodel.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService(this._usuario);
  final User? _usuario;

  @override
  User? get usuarioAtual => _usuario;
}

const _usuarioLogado = User(
  id: 'user-1',
  appMetadata: {},
  userMetadata: {'nome': 'Maria Teste'},
  aud: 'authenticated',
  createdAt: '2024-01-01T00:00:00.000Z',
  email: 'maria@dac.unicamp.br',
);

void main() {
  group('carregar', () {
    test('popula a lista de denúncias com o resultado da busca', () async {
      final denuncias = [
        Denuncia(id: '1', titulo: 'Buraco', descricao: 'Desc', localizacao: 'IC-3'),
        Denuncia(id: '2', titulo: 'Vazamento', descricao: 'Desc', localizacao: 'CB'),
      ];
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => denuncias,
        authService: _FakeAuthService(_usuarioLogado),
      );

      await viewModel.carregar();

      expect(viewModel.denuncias, equals(denuncias));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.erro, isNull);
    });

    test('define uma mensagem de erro quando a busca falha', () async {
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => throw Exception('falha de rede'),
        authService: _FakeAuthService(_usuarioLogado),
      );

      await viewModel.carregar();

      expect(viewModel.erro, isNotNull);
      expect(viewModel.denuncias, isEmpty);
      expect(viewModel.isLoading, isFalse);
    });

    test('alterna isLoading e notifica listeners durante o carregamento', () async {
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => [],
        authService: _FakeAuthService(_usuarioLogado),
      );

      final estadosLoading = <bool>[];
      viewModel.addListener(() => estadosLoading.add(viewModel.isLoading));

      await viewModel.carregar();

      expect(estadosLoading.first, isTrue);
      expect(estadosLoading.last, isFalse);
    });
  });

  group('estaLogado', () {
    test('reflete o estado de autenticação do AuthService', () {
      final logado = MinhasDenunciasViewModel(
        authService: _FakeAuthService(_usuarioLogado),
      );
      final deslogado = MinhasDenunciasViewModel(
        authService: _FakeAuthService(null),
      );

      expect(logado.estaLogado, isTrue);
      expect(deslogado.estaLogado, isFalse);
    });
  });
}
