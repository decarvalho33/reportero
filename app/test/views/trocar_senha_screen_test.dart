import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/viewmodels/auth_viewmodel.dart';
import 'package:app/views/trocar_senha_screen.dart';

/// Substitui o acesso real ao Supabase Auth. Registra os argumentos
/// recebidos para permitir verificar se o service chegou a ser chamado, e
/// simula a validação de senha atual feita pelo Supabase via [senhaAtualCorreta].
class _FakeAuthService extends AuthService {
  _FakeAuthService({this.senhaAtualCorreta});
  final String? senhaAtualCorreta;
  String? senhaAtualRecebida;
  String? novaSenhaRecebida;

  @override
  Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    if (!AuthService.senhaValida(novaSenha)) {
      throw ArgumentError(
        'A senha deve ter ao menos ${AuthService.senhaMinima} caracteres.',
      );
    }
    if (senhaAtualCorreta != null && senhaAtual != senhaAtualCorreta) {
      throw Exception('Email ou senha incorretos.');
    }
    senhaAtualRecebida = senhaAtual;
    novaSenhaRecebida = novaSenha;
  }
}

void main() {
  Future<void> preencherCampos(
    WidgetTester tester, {
    required String senhaAtual,
    required String novaSenha,
    required String confirmarSenha,
  }) async {
    await tester.enterText(
      find.byKey(const ValueKey('campo_senha_atual')),
      senhaAtual,
    );
    await tester.enterText(
      find.byKey(const ValueKey('campo_nova_senha')),
      novaSenha,
    );
    await tester.enterText(
      find.byKey(const ValueKey('campo_confirmar_senha')),
      confirmarSenha,
    );
  }

  testWidgets('exibe os três campos de senha', (tester) async {
    final viewModel = AuthViewModel(_FakeAuthService());

    await tester.pumpWidget(
      MaterialApp(home: TrocarSenhaScreen(viewModel: viewModel)),
    );

    expect(find.byKey(const ValueKey('campo_senha_atual')), findsOneWidget);
    expect(find.byKey(const ValueKey('campo_nova_senha')), findsOneWidget);
    expect(find.byKey(const ValueKey('campo_confirmar_senha')), findsOneWidget);
  });

  testWidgets(
    'barra localmente quando a confirmação não bate com a nova senha, sem chamar o service',
    (tester) async {
      final authService = _FakeAuthService();
      final viewModel = AuthViewModel(authService);

      await tester.pumpWidget(
        MaterialApp(home: TrocarSenhaScreen(viewModel: viewModel)),
      );

      await preencherCampos(
        tester,
        senhaAtual: 'senhaAntiga123',
        novaSenha: '123456',
        confirmarSenha: '654321',
      );
      await tester.tap(find.text('SALVAR SENHA'));
      await tester.pumpAndSettle();

      expect(find.text('As senhas não coincidem.'), findsOneWidget);
      expect(authService.novaSenhaRecebida, isNull);
    },
  );

  testWidgets('troca a senha com sucesso quando os campos são válidos e coincidem',
      (tester) async {
    final authService = _FakeAuthService();
    final viewModel = AuthViewModel(authService);

    await tester.pumpWidget(
      MaterialApp(home: TrocarSenhaScreen(viewModel: viewModel)),
    );

    await preencherCampos(
      tester,
      senhaAtual: 'senhaAntiga123',
      novaSenha: '123456',
      confirmarSenha: '123456',
    );
    await tester.tap(find.text('SALVAR SENHA'));
    await tester.pumpAndSettle();

    expect(authService.senhaAtualRecebida, equals('senhaAntiga123'));
    expect(authService.novaSenhaRecebida, equals('123456'));
    expect(find.text('Senha alterada com sucesso.'), findsOneWidget);
  });

  testWidgets('exibe a mensagem de erro do service quando a senha atual está incorreta',
      (tester) async {
    final authService = _FakeAuthService(senhaAtualCorreta: 'senhaCerta123');
    final viewModel = AuthViewModel(authService);

    await tester.pumpWidget(
      MaterialApp(home: TrocarSenhaScreen(viewModel: viewModel)),
    );

    await preencherCampos(
      tester,
      senhaAtual: 'senhaErrada',
      novaSenha: '123456',
      confirmarSenha: '123456',
    );
    await tester.tap(find.text('SALVAR SENHA'));
    await tester.pumpAndSettle();

    expect(find.text('Email ou senha incorretos.'), findsOneWidget);
    expect(authService.novaSenhaRecebida, isNull);
  });

  testWidgets('exibe a mensagem de erro do service quando a nova senha é curta',
      (tester) async {
    final authService = _FakeAuthService();
    final viewModel = AuthViewModel(authService);

    await tester.pumpWidget(
      MaterialApp(home: TrocarSenhaScreen(viewModel: viewModel)),
    );

    await preencherCampos(
      tester,
      senhaAtual: 'senhaAntiga123',
      novaSenha: '123',
      confirmarSenha: '123',
    );
    await tester.tap(find.text('SALVAR SENHA'));
    await tester.pumpAndSettle();

    expect(
      find.text('A senha deve ter ao menos ${AuthService.senhaMinima} caracteres.'),
      findsOneWidget,
    );
    expect(authService.novaSenhaRecebida, isNull);
  });
}
