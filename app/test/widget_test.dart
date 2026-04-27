import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/views/widgets/denuncia_card.dart';

void main() {
  final denunciaBase = Denuncia(
    id: '1',
    titulo: 'Buraco na calçada',
    descricao: 'Grande buraco próximo à entrada do IC-3',
    localizacao: 'IC-3',
    autor: 'Maria',
  );

  Widget buildCard(Denuncia denuncia, {String tempo = 'há 5min'}) {
    return MaterialApp(
      home: Scaffold(
        body: DenunciaCard(denuncia: denuncia, tempoRelativo: tempo),
      ),
    );
  }

  testWidgets('exibe o título da denúncia', (tester) async {
    await tester.pumpWidget(buildCard(denunciaBase));
    expect(find.text('Buraco na calçada'), findsOneWidget);
  });

  testWidgets('exibe o autor', (tester) async {
    await tester.pumpWidget(buildCard(denunciaBase));
    expect(find.text('Maria'), findsOneWidget);
  });

  testWidgets('exibe a localização', (tester) async {
    await tester.pumpWidget(buildCard(denunciaBase));
    expect(find.text('IC-3'), findsOneWidget);
  });

  testWidgets('exibe o tempo relativo', (tester) async {
    await tester.pumpWidget(buildCard(denunciaBase, tempo: 'há 2h'));
    expect(find.text('há 2h'), findsOneWidget);
  });

  testWidgets('exibe "Anônimo" quando autor está vazio', (tester) async {
    final denunciaAnonima = Denuncia(
      titulo: 'Lâmpada queimada',
      descricao: 'Corredor sem luz',
      localizacao: 'CB',
      autor: '',
    );
    await tester.pumpWidget(buildCard(denunciaAnonima));
    expect(find.text('Anônimo'), findsOneWidget);
  });
}
