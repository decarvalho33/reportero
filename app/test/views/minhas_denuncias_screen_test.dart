import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/viewmodels/minhas_denuncias_viewmodel.dart';
import 'package:app/views/minhas_denuncias_screen.dart';

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
  testWidgets('exibe resumo (título, categoria, status e data) das denúncias do usuário', (
    tester,
  ) async {
    final minhaDenuncia = Denuncia(
      id: '1',
      titulo: 'Buraco na calçada',
      descricao: 'Descrição',
      localizacao: 'IC-3',
      categoria: Categoria.infraestrutura,
      status: 'Em andamento',
      createdAt: DateTime(2024, 3, 10),
    );
    final viewModel = MinhasDenunciasViewModel(
      buscarDenuncias: () async => [minhaDenuncia],
      authService: _FakeAuthService(_usuarioLogado),
    );

    await tester.pumpWidget(
      MaterialApp(home: MinhasDenunciasScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Buraco na calçada'), findsOneWidget);
    expect(find.text('Infraestrutura'), findsOneWidget);
    expect(find.text('Em andamento'), findsOneWidget);
    expect(find.text('10/03/2024'), findsOneWidget);
  });

  testWidgets('exibe mensagem quando o usuário não tem denúncias', (tester) async {
    final viewModel = MinhasDenunciasViewModel(
      buscarDenuncias: () async => [],
      authService: _FakeAuthService(_usuarioLogado),
    );

    await tester.pumpWidget(
      MaterialApp(home: MinhasDenunciasScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Você ainda não registrou nenhuma denúncia.'),
      findsOneWidget,
    );
  });

  testWidgets('redireciona para /login quando não há usuário autenticado', (
    tester,
  ) async {
    final viewModel = MinhasDenunciasViewModel(
      buscarDenuncias: () async => [],
      authService: _FakeAuthService(null),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: MinhasDenunciasScreen(viewModel: viewModel),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Tela de login')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tela de login'), findsOneWidget);
  });
}
