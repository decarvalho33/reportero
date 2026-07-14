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
        // No feed real o card vive dentro de uma lista rolável; espelhamos isso
        // aqui para evitar overflow no viewport fixo do teste.
        body: SingleChildScrollView(
          child: DenunciaCard(denuncia: denuncia, tempoRelativo: tempo, onApoiar: () {}),
        ),
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

  testWidgets('exibe o label da categoria padrão', (tester) async {
    await tester.pumpWidget(buildCard(denunciaBase));
    expect(find.text('Outros'), findsOneWidget);
  });

  testWidgets('exibe o label de categoria não-padrão corretamente', (tester) async {
    final denunciaComCategoria = Denuncia(
      titulo: 'Porta arrombada',
      descricao: 'Porta do banheiro feminino foi arrombada',
      localizacao: 'IC-3',
      autor: 'João',
      categoria: Categoria.seguranca,
    );
    await tester.pumpWidget(buildCard(denunciaComCategoria));
    expect(find.text('Segurança'), findsOneWidget);
  });

  testWidgets('localização é tocável e abre o menu de mapas', (tester) async {
    await tester.pumpWidget(buildCard(denunciaBase));

    // Dica indicando que a localização é tocável
    expect(find.text('Toque para abrir no mapa'), findsOneWidget);

    // Ao tocar na localização, abre o menu com Google Maps e Apple Maps
    await tester.tap(find.text('IC-3'));
    await tester.pumpAndSettle();
    expect(find.text('Google Maps'), findsOneWidget);
    expect(find.text('Apple Maps'), findsOneWidget);
  });

  testWidgets('exibe a imagem quando fotoUrl é fornecida', (tester) async {
    final denunciaComFoto = Denuncia(
      titulo: 'Buraco',
      descricao: 'Descrição',
      localizacao: 'IC-3',
      fotoUrl: 'https://example.com/foto.jpg',
    );
    await tester.pumpWidget(buildCard(denunciaComFoto));
    
    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);
    
    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.image, isA<NetworkImage>());
    expect((imageWidget.image as NetworkImage).url, equals('https://example.com/foto.jpg'));
  });
}
