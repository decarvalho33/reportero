import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/formulario_denuncia_screen.dart';

// F1-01: Configuração do Supabase e estrutura básica do app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configuração do Supabase
  await Supabase.initialize(
    url: 'https://fxkelgxlfddybvtmpzye.supabase.co',
    anonKey: 'sb_publishable_0trdTilYVLii8p2kmnGSrA_MgwJY5ki',
  );
  // Inicia o app
  runApp(const ReporteroApp());
}

class ReporteroApp extends StatelessWidget {
  const ReporteroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reportero Unicamp',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF37474F),
      ),
      // Rotas nomeadas facilitam o trabalho do Gabriel (Feed) e Gilberth (Navegação)
      initialRoute: '/nova',
      routes: {
        '/nova': (context) => const FormularioDenunciaScreen(),
        // '/feed': (context) => const FeedScreen(), // Gabriel adicionará depois
      },
    );
  }
}
