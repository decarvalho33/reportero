import 'package:flutter/material.dart';
import 'views/formulario_denuncia_screen.dart';

void main() => runApp(const ReporteroApp());

class ReporteroApp extends StatelessWidget {
  const ReporteroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reportero Unicamp',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF37474F)),
      // Rotas nomeadas facilitam o trabalho do Gabriel (Feed) e Gilberth (Navegação)
      initialRoute: '/nova', 
      routes: {
        '/nova': (context) => const FormularioDenunciaScreen(),
        // '/feed': (context) => const FeedScreen(), // Gabriel adicionará depois
      },
    );
  }
}