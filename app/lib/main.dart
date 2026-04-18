import 'package:flutter/material.dart';
import 'views/formulario_denuncia_screen.dart';
import 'views/feed_screen.dart';

void main() => runApp(const ReporteroApp());

class ReporteroApp extends StatelessWidget {
  const ReporteroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reportero Unicamp',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF37474F)),
      initialRoute: '/feed',
      routes: {
        '/feed': (context) => const FeedScreen(),
        '/nova': (context) => const FormularioDenunciaScreen(),
      },
    );
  }
}