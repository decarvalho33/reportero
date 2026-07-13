import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/views/formulario_denuncia_screen.dart';

void main() {
  testWidgets('modo de criação exibe título e botão padrão', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FormularioDenunciaScreen()),
    );

    expect(find.text('Nova Ocorrência'), findsOneWidget);
    expect(find.text('REGISTRAR DENÚNCIA'), findsOneWidget);
  });

  testWidgets(
    'modo de edição pré-preenche os campos e exibe título/botão de edição',
    (tester) async {
      final denuncia = Denuncia(
        id: 'abc-123',
        titulo: 'Buraco na calçada',
        descricao: 'Descrição original',
        localizacao: 'IC-3',
        autor: 'Maria',
        autorId: 'user-1',
        categoria: Categoria.infraestrutura,
      );

      await tester.pumpWidget(
        MaterialApp(home: FormularioDenunciaScreen(denuncia: denuncia)),
      );

      expect(find.text('Editar Ocorrência'), findsOneWidget);
      expect(find.text('SALVAR ALTERAÇÕES'), findsOneWidget);
      expect(find.text('Buraco na calçada'), findsOneWidget);
      expect(find.text('Descrição original'), findsOneWidget);
      expect(find.text('IC-3'), findsOneWidget);
      expect(find.text('Maria'), findsOneWidget);
    },
  );
}
