import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/viewmodels/auth_viewmodel.dart';
import 'package:app/views/profile_screen.dart';

/// Substitui o acesso real ao Supabase, permitindo simular usuário
/// autenticado ou não sem inicializar uma conexão de verdade.
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
  testWidgets('exibe nome e email do usuário autenticado', (tester) async {
    final viewModel = AuthViewModel(_FakeAuthService(_usuarioLogado));

    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(viewModel: viewModel)),
    );

    expect(find.text('Maria Teste'), findsOneWidget);
    expect(find.text('maria@dac.unicamp.br'), findsOneWidget);
  });

  testWidgets('redireciona para /login quando não há usuário autenticado', (
    tester,
  ) async {
    final viewModel = AuthViewModel(_FakeAuthService(null));

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileScreen(viewModel: viewModel),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Tela de login')),
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tela de login'), findsOneWidget);
  });
}
