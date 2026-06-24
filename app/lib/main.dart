import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/formulario_denuncia_screen.dart';
import 'views/feed_screen.dart';

/*Ponto de entrada do aplicativo. Inicializa o Supabase e configura as rotas da aplicação.*/
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fxkelgxlfddybvtmpzye.supabase.co',
    anonKey: 'sb_publishable_0trdTilYVLii8p2kmnGSrA_MgwJY5ki',
  );

  runApp(const ReporteroApp());
}

/*Classe principal do aplicativo, define o tema e as rotas da aplicação.*/
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
      initialRoute: '/feed',
      routes: {
        '/feed': (context) => const FeedScreen(),
        '/nova': (context) => const FormularioDenunciaScreen(),
      },
    );
  }
}
