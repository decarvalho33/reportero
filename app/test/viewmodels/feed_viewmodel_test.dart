import 'package:flutter_test/flutter_test.dart';
import 'package:app/viewmodels/feed_viewmodel.dart';

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
}
