import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/formulario_denuncia_screen.dart';
import 'views/feed_screen.dart';
import 'views/login_screen.dart';
import 'views/cadastro_screen.dart';
import 'views/recuperar_senha_screen.dart';
import 'views/nova_senha_screen.dart';
import 'views/admin/admin_dashboard_screen.dart';




/// Ponto de entrada principal do aplicativo, responsável por inicializar o Supabase e configurar a aplicação Flutter.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fxkelgxlfddybvtmpzye.supabase.co',
    anonKey: 'sb_publishable_0trdTilYVLii8p2kmnGSrA_MgwJY5ki',
  );

  runApp(const ReporteroApp());
}


class ReporteroApp extends StatefulWidget {
  const ReporteroApp({super.key});

  @override
  State<ReporteroApp> createState() => _ReporteroAppState();
}

class _ReporteroAppState extends State<ReporteroApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Escuta eventos de autenticação, como cliques em links profundos
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        // Redireciona o usuário para a tela de redefinição de senha
        _navigatorKey.currentState?.pushNamed('/nova-senha');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
        '/login': (context) => const LoginScreen(),
        '/cadastro': (context) => const CadastroScreen(),
        '/recuperar-senha': (context) => const RecuperarSenhaScreen(),
        '/nova-senha': (context) => const NovaSenhaScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
