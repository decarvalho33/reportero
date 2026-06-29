import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/viewmodels/feed_viewmodel.dart';

// Denúncias de fixture usadas nos testes de filtro
final _infra1 = Denuncia(
  id: '1',
  titulo: 'Buraco na calçada',
  descricao: 'Calçada danificada',
  localizacao: 'IC-3',
  categoria: 'Infraestrutura',
);
final _infra2 = Denuncia(
  id: '2',
  titulo: 'Lâmpada queimada',
  descricao: 'Sem luz no corredor',
  localizacao: 'CB',
  categoria: 'Infraestrutura',
);
final _seguranca = Denuncia(
  id: '3',
  titulo: 'Porta arrombada',
  descricao: 'Porta do banheiro foi arrombada',
  localizacao: 'IC-3',
  categoria: 'Segurança',
);

void main() {
  late FeedViewModel viewModel;

  setUp(() {
    viewModel = FeedViewModel();
  });

  group('formatarTempo', () {
    test('retorna string vazia para null', () {
      expect(viewModel.formatarTempo(null), equals(''));
    });

    test('retorna minutos para data recente', () {
      final data = DateTime.now().subtract(const Duration(minutes: 30));
      expect(viewModel.formatarTempo(data), equals('há 30min'));
    });

    test('retorna horas para data de horas atrás', () {
      final data = DateTime.now().subtract(const Duration(hours: 2));
      expect(viewModel.formatarTempo(data), equals('há 2h'));
    });

    test('retorna dias para data de dias atrás', () {
      final data = DateTime.now().subtract(const Duration(days: 3));
      expect(viewModel.formatarTempo(data), equals('há 3d'));
    });
  });

  group('filtrarPorCategoria', () {
    test('atualiza filtroCategoria e notifica listeners', () {
      var notificou = false;
      viewModel.addListener(() => notificou = true);

      viewModel.filtrarPorCategoria('Segurança');

      expect(viewModel.filtroCategoria, equals('Segurança'));
      expect(notificou, isTrue);
    });

    test('filtra e retorna apenas denúncias da categoria selecionada', () {
      viewModel.carregarDenunciasLocais([_infra1, _infra2, _seguranca]);

      viewModel.filtrarPorCategoria('Infraestrutura');

      expect(viewModel.denuncias.length, equals(2));
      expect(viewModel.denuncias.every((d) => d.categoria == 'Infraestrutura'), isTrue);
    });

    test('filtro nulo retorna todas as denúncias', () {
      viewModel.carregarDenunciasLocais([_infra1, _infra2, _seguranca]);
      viewModel.filtrarPorCategoria('Segurança');

      viewModel.filtrarPorCategoria(null);

      expect(viewModel.denuncias.length, equals(3));
      expect(viewModel.filtroCategoria, isNull);
    });

    test('filtro de categoria e texto combinados funcionam juntos', () {
      viewModel.carregarDenunciasLocais([_infra1, _infra2, _seguranca]);

      // Texto filtra dentro de Infraestrutura: só _infra1 tem "calçada"
      viewModel.filtrarPorCategoria('Infraestrutura');
      viewModel.filtrarPorTexto('calçada');

      expect(viewModel.denuncias.length, equals(1));
      expect(viewModel.denuncias.first.id, equals('1'));
    });
  });
}
