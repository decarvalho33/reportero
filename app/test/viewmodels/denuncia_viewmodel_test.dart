import 'package:flutter_test/flutter_test.dart';
import 'package:app/viewmodels/denuncia_viewmodel.dart';

void main() {
  late DenunciaViewModel viewModel;

  setUp(() {
    viewModel = DenunciaViewModel();
  });

  tearDown(() {
    viewModel.limpar();
  });

  group('validarObrigatorio', () {
    test('retorna erro para string vazia', () {
      expect(viewModel.validarObrigatorio(''), isNotNull);
    });

    test('retorna erro para null', () {
      expect(viewModel.validarObrigatorio(null), isNotNull);
    });

    test('retorna null para valor preenchido', () {
      expect(viewModel.validarObrigatorio('valor válido'), isNull);
    });
  });

  group('limpar', () {
    test('esvazia todos os controllers', () {
      viewModel.tituloCtrl.text = 'Título teste';
      viewModel.localCtrl.text = 'IC-3';
      viewModel.descCtrl.text = 'Descrição teste';
      viewModel.autorCtrl.text = 'João';

      viewModel.limpar();

      expect(viewModel.tituloCtrl.text, isEmpty);
      expect(viewModel.localCtrl.text, isEmpty);
      expect(viewModel.descCtrl.text, isEmpty);
      expect(viewModel.autorCtrl.text, isEmpty);
    });
  });
}
