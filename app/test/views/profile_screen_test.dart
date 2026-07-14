import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/perfil_service.dart';
import 'package:app/viewmodels/perfil_viewmodel.dart';
import 'package:app/views/profile_screen.dart';

/// Substitui o acesso real ao Supabase Auth, permitindo simular usuário
/// autenticado ou não sem inicializar uma conexão de verdade.
class _FakeAuthService extends AuthService {
  _FakeAuthService(this._usuario);
  final User? _usuario;

  @override
  User? get usuarioAtual => _usuario;
}

/// Substitui o acesso à tabela `profiles`, guardando o nome e a foto em
/// memória.
class _FakePerfilService extends PerfilService {
  _FakePerfilService({String? nomeInicial, String? fotoUrlInicial})
      : _nome = nomeInicial,
        _fotoUrl = fotoUrlInicial;
  String? _nome;
  String? _fotoUrl;
  String? ultimoNomeSalvo;
  String? ultimaFotoSalva;

  @override
  Future<String?> obterNome(String userId) async => _nome;

  @override
  Future<void> atualizarNome({
    required String userId,
    required String nome,
  }) async {
    if (!PerfilService.nomeValido(nome)) {
      throw ArgumentError(
        'O nome deve ter ao menos ${PerfilService.nomeMinimo} caracteres.',
      );
    }
    _nome = nome.trim();
    ultimoNomeSalvo = _nome;
  }

  @override
  Future<String?> obterFotoPerfil(String userId) async => _fotoUrl;

  @override
  Future<String?> subirFotoPerfil(Uint8List fotoBytes, String nomeArquivo) async {
    if (!PerfilService.fotoValida(nomeArquivo)) {
      throw ArgumentError('Formato de imagem não suportado. Use JPG, PNG ou WEBP.');
    }
    return 'https://example.com/perfil/$nomeArquivo';
  }

  @override
  Future<void> atualizarFotoPerfil({
    required String userId,
    required String fotoUrl,
  }) async {
    _fotoUrl = fotoUrl;
    ultimaFotoSalva = fotoUrl;
  }
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
    final viewModel = PerfilViewModel(
      authService: _FakeAuthService(_usuarioLogado),
      perfilService: _FakePerfilService(nomeInicial: 'Maria Teste'),
    );

    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maria Teste'), findsOneWidget);
    expect(find.text('maria@dac.unicamp.br'), findsOneWidget);
  });

  testWidgets('redireciona para /login quando não há usuário autenticado', (
    tester,
  ) async {
    final viewModel = PerfilViewModel(
      authService: _FakeAuthService(null),
      perfilService: _FakePerfilService(),
    );

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

  testWidgets('permite editar e salvar um novo nome', (tester) async {
    final perfilService = _FakePerfilService(nomeInicial: 'Maria Teste');
    final viewModel = PerfilViewModel(
      authService: _FakeAuthService(_usuarioLogado),
      perfilService: perfilService,
    );

    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Maria Nova');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(perfilService.ultimoNomeSalvo, equals('Maria Nova'));
    expect(find.text('Maria Nova'), findsOneWidget);
    expect(find.text('Perfil atualizado com sucesso.'), findsOneWidget);
  });

  testWidgets('exibe erro de validação e não salva quando o nome é muito curto', (
    tester,
  ) async {
    final perfilService = _FakePerfilService(nomeInicial: 'Maria Teste');
    final viewModel = PerfilViewModel(
      authService: _FakeAuthService(_usuarioLogado),
      perfilService: perfilService,
    );

    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'A');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(
      find.text('O nome deve ter ao menos ${PerfilService.nomeMinimo} caracteres.'),
      findsOneWidget,
    );
    expect(perfilService.ultimoNomeSalvo, isNull);
  });

  testWidgets('exibe o ícone de placeholder quando não há foto de perfil', (
    tester,
  ) async {
    final viewModel = PerfilViewModel(
      authService: _FakeAuthService(_usuarioLogado),
      perfilService: _FakePerfilService(nomeInicial: 'Maria Teste'),
    );

    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(viewModel: viewModel)),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.person), findsOneWidget);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isNull);
  });

  testWidgets('exibe a foto de perfil quando há URL salva', (tester) async {
    final viewModel = PerfilViewModel(
      authService: _FakeAuthService(_usuarioLogado),
      perfilService: _FakePerfilService(
        nomeInicial: 'Maria Teste',
        fotoUrlInicial: 'https://example.com/perfil/foto.jpg',
      ),
    );

    // Evita pumpAndSettle: a foto real via NetworkImage tentaria uma
    // requisição de rede, que não resolve no ambiente de teste.
    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen(viewModel: viewModel)),
    );
    await tester.pump();

    expect(find.byIcon(Icons.person), findsNothing);
    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(avatar.backgroundImage, isA<NetworkImage>());
    expect(
      (avatar.backgroundImage as NetworkImage).url,
      equals('https://example.com/perfil/foto.jpg'),
    );
  });
}
