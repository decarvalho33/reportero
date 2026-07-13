import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/denuncia.dart';
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

    test('reseta categoria para Categoria.outros', () {
      viewModel.definirCategoria(Categoria.seguranca);
      expect(viewModel.categoriaSelecionada, equals(Categoria.seguranca));

      viewModel.limpar();

      expect(viewModel.categoriaSelecionada, equals(Categoria.outros));
    });

    test('reseta foto e coordenadas GPS', () {
      viewModel.definirFoto(Uint8List.fromList([1, 2, 3]), 'imagem.png');
      viewModel.alternarLocalizacaoGps(true);

      expect(viewModel.fotoBytes, isNotNull);
      expect(viewModel.latitude, isNotNull);
      expect(viewModel.longitude, isNotNull);

      viewModel.limpar();

      expect(viewModel.fotoBytes, isNull);
      expect(viewModel.latitude, isNull);
      expect(viewModel.longitude, isNull);
    });
  });

  group('categoria', () {
    test('valor padrão é Categoria.outros', () {
      expect(viewModel.categoriaSelecionada, equals(Categoria.outros));
    });

    test('definirCategoria atualiza o estado', () {
      viewModel.definirCategoria(Categoria.infraestrutura);
      expect(viewModel.categoriaSelecionada, equals(Categoria.infraestrutura));
    });

    test('definirCategoria notifica listeners', () {
      var notificou = false;
      viewModel.addListener(() => notificou = true);

      viewModel.definirCategoria(Categoria.servicos);

      expect(notificou, isTrue);
    });
  });

  group('foto', () {
    test('definirFoto atualiza fotoBytes e notifica listeners', () {
      var notificou = false;
      viewModel.addListener(() => notificou = true);

      final bytes = Uint8List.fromList([4, 5, 6]);
      viewModel.definirFoto(bytes, 'teste.jpg');

      expect(viewModel.fotoBytes, equals(bytes));
      expect(notificou, isTrue);
    });
  });

  group('gps', () {
    test('alternarLocalizacaoGps ativa e desativa coordenadas', () {
      var notificou = 0;
      viewModel.addListener(() => notificou++);

      viewModel.alternarLocalizacaoGps(true);
      expect(viewModel.latitude, equals(-22.8184));
      expect(viewModel.longitude, equals(-47.0647));

      viewModel.alternarLocalizacaoGps(false);
      expect(viewModel.latitude, isNull);
      expect(viewModel.longitude, isNull);

      expect(notificou, equals(2));
    });
  });

  group('modo de edição (US 5.6/5.7)', () {
    final denunciaExistente = Denuncia(
      id: 'abc-123',
      titulo: 'Buraco na calçada',
      descricao: 'Descrição original',
      localizacao: 'IC-3',
      autor: 'Maria',
      autorId: 'user-1',
      categoria: Categoria.infraestrutura,
      latitude: -22.8123,
      longitude: -47.0654,
      fotoUrl: 'https://example.com/foto.jpg',
      status: 'Em andamento',
    );

    test('sem denúncia existente, emEdicao é false', () {
      expect(viewModel.emEdicao, isFalse);
    });

    test('com denúncia existente, pré-preenche os campos do formulário', () {
      final editando = DenunciaViewModel(denunciaExistente: denunciaExistente);

      expect(editando.emEdicao, isTrue);
      expect(editando.tituloCtrl.text, equals('Buraco na calçada'));
      expect(editando.localCtrl.text, equals('IC-3'));
      expect(editando.descCtrl.text, equals('Descrição original'));
      expect(editando.autorCtrl.text, equals('Maria'));
      expect(editando.categoriaSelecionada, equals(Categoria.infraestrutura));
      expect(editando.latitude, equals(-22.8123));
      expect(editando.longitude, equals(-47.0654));
      expect(editando.fotoUrlExistente, equals('https://example.com/foto.jpg'));

      editando.limpar();
    });

    test('autor "Anônimo" é pré-preenchido como campo vazio (para reedição)', () {
      final anonima = Denuncia(
        id: 'xyz',
        titulo: 'Título',
        descricao: 'Descrição',
        localizacao: 'Local',
        autor: 'Anônimo',
        autorId: 'user-1',
      );
      final editando = DenunciaViewModel(denunciaExistente: anonima);

      expect(editando.autorCtrl.text, isEmpty);

      editando.limpar();
    });
  });
}
