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

  group('filtros', () {
    final infra = Denuncia(
      id: '1',
      titulo: 'Buraco na calçada',
      descricao: 'Calçada danificada',
      localizacao: 'IC-3',
      categoria: Categoria.infraestrutura,
      status: 'Aberta',
    );
    final seguranca = Denuncia(
      id: '2',
      titulo: 'Porta arrombada',
      descricao: 'Porta do banheiro foi arrombada',
      localizacao: 'CB',
      categoria: Categoria.seguranca,
      status: 'Resolvida',
    );

    late MinhasDenunciasViewModel viewModel;

    setUp(() {
      viewModel = MinhasDenunciasViewModel(
        authService: _FakeAuthService(_usuarioLogado),
      );
      viewModel.carregarDenunciasLocais([infra, seguranca]);
    });

    test('filtrarPorTexto restringe às denúncias que combinam', () {
      viewModel.filtrarPorTexto('porta');

      expect(viewModel.denuncias, equals([seguranca]));
    });

    test('filtrarPorCategoria restringe à categoria selecionada', () {
      viewModel.filtrarPorCategoria(Categoria.infraestrutura);

      expect(viewModel.denuncias, equals([infra]));
    });

    test('filtrarPorStatus restringe ao status selecionado', () {
      viewModel.filtrarPorStatus('Resolvida');

      expect(viewModel.denuncias, equals([seguranca]));
    });

    test('filtros combinados (texto + categoria + status) funcionam juntos', () {
      viewModel.filtrarPorCategoria(Categoria.infraestrutura);
      viewModel.filtrarPorStatus('Aberta');
      viewModel.filtrarPorTexto('buraco');

      expect(viewModel.denuncias, equals([infra]));
    });

    test('filtro nulo (categoria ou status) volta a exibir todas', () {
      viewModel.filtrarPorCategoria(Categoria.seguranca);
      viewModel.filtrarPorCategoria(null);

      expect(viewModel.denuncias.length, equals(2));
    });

    test('statusDisponiveis reflete os status distintos presentes na lista', () {
      expect(viewModel.statusDisponiveis, equals(['Aberta', 'Resolvida']));
    });

    test('temDenunciasCadastradas é true quando há denúncias carregadas', () {
      expect(viewModel.temDenunciasCadastradas, isTrue);
    });

    test('temDenunciasCadastradas é false antes de qualquer carregamento', () {
      final vazio = MinhasDenunciasViewModel(
        authService: _FakeAuthService(_usuarioLogado),
      );
      expect(vazio.temDenunciasCadastradas, isFalse);
    });
  });

  group('excluir', () {
    final denuncia = Denuncia(
      id: '1',
      titulo: 'Buraco na calçada',
      descricao: 'Desc',
      localizacao: 'IC-3',
      autorId: 'user-1',
    );

    test('remove a denúncia da lista quando a exclusão é bem-sucedida', () async {
      Denuncia? excluidaRecebida;
      final viewModel = MinhasDenunciasViewModel(
        authService: _FakeAuthService(_usuarioLogado),
        excluirDenuncia: (d) async => excluidaRecebida = d,
      );
      viewModel.carregarDenunciasLocais([denuncia]);

      final sucesso = await viewModel.excluir(denuncia);

      expect(sucesso, isTrue);
      expect(excluidaRecebida, equals(denuncia));
      expect(viewModel.denuncias, isEmpty);
    });

    test('mantém a lista e define erro quando a exclusão falha', () async {
      final viewModel = MinhasDenunciasViewModel(
        authService: _FakeAuthService(_usuarioLogado),
        excluirDenuncia: (d) async =>
            throw Exception('Você só pode editar ou excluir suas próprias denúncias.'),
      );
      viewModel.carregarDenunciasLocais([denuncia]);

      final sucesso = await viewModel.excluir(denuncia);

      expect(sucesso, isFalse);
      expect(viewModel.erro, isNotNull);
      expect(viewModel.denuncias, equals([denuncia]));
    });
  });
}
