import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/services/auth_service.dart';
import 'package:app/services/status_visto_service.dart';
import 'package:app/viewmodels/minhas_denuncias_viewmodel.dart';
import 'package:app/views/minhas_denuncias_screen.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService(this._usuario);
  final User? _usuario;

  @override
  User? get usuarioAtual => _usuario;
}

class _FakeStatusVistoService extends StatusVistoService {
  _FakeStatusVistoService([Map<String, String>? vistosIniciais])
      : _vistos = Map.of(vistosIniciais ?? {});
  final Map<String, String> _vistos;

  @override
  Future<Map<String, String>> obterStatusVistos() async => Map.of(_vistos);

  @override
  Future<void> marcarComoVisto(String denunciaId, StatusDenuncia status) async {
    _vistos[denunciaId] = status.label;
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exibe resumo (título, categoria, status e data) das denúncias do usuário', (
    tester,
  ) async {
    final minhaDenuncia = Denuncia(
      id: '1',
      titulo: 'Buraco na calçada',
      descricao: 'Descrição',
      localizacao: 'IC-3',
      categoria: Categoria.infraestrutura,
      status: StatusDenuncia.emAnalise,
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
    // "Infraestrutura" também aparece como chip de filtro de categoria, além
    // do chip no resumo da denúncia — por isso findsWidgets, não findsOneWidget.
    expect(find.text('Infraestrutura'), findsWidgets);
    expect(find.text('Em Análise'), findsOneWidget);
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

  group('busca e filtros', () {
    final infra = Denuncia(
      id: '1',
      titulo: 'Buraco na calçada',
      descricao: 'Calçada danificada',
      localizacao: 'IC-3',
      categoria: Categoria.infraestrutura,
      status: StatusDenuncia.pendente,
    );
    final seguranca = Denuncia(
      id: '2',
      titulo: 'Porta arrombada',
      descricao: 'Porta do banheiro foi arrombada',
      localizacao: 'CB',
      categoria: Categoria.seguranca,
      status: StatusDenuncia.resolvida,
    );

    Future<MinhasDenunciasViewModel> montarTela(WidgetTester tester) async {
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => [infra, seguranca],
        authService: _FakeAuthService(_usuarioLogado),
      );
      await tester.pumpWidget(
        MaterialApp(home: MinhasDenunciasScreen(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();
      return viewModel;
    }

    testWidgets('busca por texto restringe a lista exibida', (tester) async {
      await montarTela(tester);

      await tester.enterText(find.byType(TextField), 'porta');
      await tester.pumpAndSettle();

      expect(find.text('Porta arrombada'), findsOneWidget);
      expect(find.text('Buraco na calçada'), findsNothing);
    });

    testWidgets('filtro por categoria restringe a lista exibida', (tester) async {
      await montarTela(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Segurança'));
      await tester.pumpAndSettle();

      expect(find.text('Porta arrombada'), findsOneWidget);
      expect(find.text('Buraco na calçada'), findsNothing);
    });

    testWidgets('filtro por status restringe a lista exibida', (tester) async {
      await montarTela(tester);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Resolvida'));
      await tester.pumpAndSettle();

      expect(find.text('Porta arrombada'), findsOneWidget);
      expect(find.text('Buraco na calçada'), findsNothing);
    });

    testWidgets(
      'exibe mensagem específica quando os filtros não encontram nada',
      (tester) async {
        await montarTela(tester);

        await tester.enterText(find.byType(TextField), 'inexistente');
        await tester.pumpAndSettle();

        expect(
          find.text('Nenhuma denúncia encontrada com os filtros aplicados.'),
          findsOneWidget,
        );
      },
    );
  });

  group('editar e excluir (US 5.6/5.7)', () {
    final denuncia = Denuncia(
      id: '1',
      titulo: 'Buraco na calçada',
      descricao: 'Descrição',
      localizacao: 'IC-3',
      autorId: 'user-1',
    );

    testWidgets('toque em editar navega para /nova com a denúncia como argumento', (
      tester,
    ) async {
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => [denuncia],
        authService: _FakeAuthService(_usuarioLogado),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MinhasDenunciasScreen(viewModel: viewModel),
          routes: {
            '/nova': (context) {
              final arg = ModalRoute.of(context)?.settings.arguments as Denuncia?;
              return Scaffold(body: Text('Editando: ${arg?.titulo}'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Editar'));
      await tester.pumpAndSettle();

      expect(find.text('Editando: Buraco na calçada'), findsOneWidget);
    });

    testWidgets('cancelar a exclusão mantém a denúncia na lista', (tester) async {
      var excluirChamado = false;
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => [denuncia],
        authService: _FakeAuthService(_usuarioLogado),
        excluirDenuncia: (d) async => excluirChamado = true,
      );

      await tester.pumpWidget(
        MaterialApp(home: MinhasDenunciasScreen(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Excluir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(excluirChamado, isFalse);
      expect(find.text('Buraco na calçada'), findsOneWidget);
    });

    testWidgets('confirmar a exclusão remove a denúncia da lista', (tester) async {
      Denuncia? excluida;
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => [denuncia],
        authService: _FakeAuthService(_usuarioLogado),
        excluirDenuncia: (d) async => excluida = d,
      );

      await tester.pumpWidget(
        MaterialApp(home: MinhasDenunciasScreen(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Excluir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir'));
      await tester.pumpAndSettle();

      expect(excluida, equals(denuncia));
      expect(find.text('Buraco na calçada'), findsNothing);
      expect(find.text('Denúncia excluída.'), findsOneWidget);
    });
  });

  group('notificação de mudança de status (US 5.5)', () {
    final denunciaComMudanca = Denuncia(
      id: '1',
      titulo: 'Buraco na calçada',
      descricao: 'Descrição',
      localizacao: 'IC-3',
      status: StatusDenuncia.resolvida,
    );
    final denunciaSemMudanca = Denuncia(
      id: '2',
      titulo: 'Porta arrombada',
      descricao: 'Descrição',
      localizacao: 'CB',
      status: StatusDenuncia.pendente,
    );

    testWidgets(
      'exibe o indicador só para a denúncia cujo status mudou, com o novo status explícito',
      (tester) async {
        final viewModel = MinhasDenunciasViewModel(
          buscarDenuncias: () async => [denunciaComMudanca, denunciaSemMudanca],
          authService: _FakeAuthService(_usuarioLogado),
          statusVistoService: _FakeStatusVistoService({
            '1': StatusDenuncia.pendente.label, // visto como Pendente; agora é Resolvida.
            '2': StatusDenuncia.pendente.label, // igual ao atual: sem mudança.
          }),
        );

        await tester.pumpWidget(
          MaterialApp(home: MinhasDenunciasScreen(viewModel: viewModel)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Novo status: Resolvida'), findsOneWidget);
        expect(find.text('1 denúncia com status atualizado'), findsOneWidget);

        final tilePortaArrombada = find.ancestor(
          of: find.text('Porta arrombada'),
          matching: find.byType(Card),
        );
        expect(
          find.descendant(
            of: tilePortaArrombada,
            matching: find.textContaining('Novo status:'),
          ),
          findsNothing,
        );
      },
    );

    testWidgets('denúncia nunca vista antes não exibe o indicador', (tester) async {
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => [denunciaComMudanca],
        authService: _FakeAuthService(_usuarioLogado),
        statusVistoService: _FakeStatusVistoService(),
      );

      await tester.pumpWidget(
        MaterialApp(home: MinhasDenunciasScreen(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Novo status:'), findsNothing);
    });

    testWidgets('tocar no indicador marca como visto e remove o destaque', (tester) async {
      final viewModel = MinhasDenunciasViewModel(
        buscarDenuncias: () async => [denunciaComMudanca],
        authService: _FakeAuthService(_usuarioLogado),
        statusVistoService: _FakeStatusVistoService({'1': StatusDenuncia.pendente.label}),
      );

      await tester.pumpWidget(
        MaterialApp(home: MinhasDenunciasScreen(viewModel: viewModel)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Novo status: Resolvida'), findsOneWidget);

      await tester.tap(find.byTooltip('Marcar novo status como visto'));
      await tester.pumpAndSettle();

      expect(find.text('Novo status: Resolvida'), findsNothing);
      expect(find.text('1 denúncia com status atualizado'), findsNothing);
    });
  });
}
