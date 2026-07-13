import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Tela de perfil (US 5.1). Exibe nome e email do usuário autenticado.
///
/// Aceita um [AuthViewModel] via construtor para permitir testes sem depender
/// do Supabase real, seguindo o mesmo padrão de injeção usado pelas outras
/// telas de autenticação.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, AuthViewModel? viewModel})
      : _viewModelInjetado = viewModel;

  final AuthViewModel? _viewModelInjetado;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthViewModel _viewModel =
      widget._viewModelInjetado ?? AuthViewModel();

  @override
  void initState() {
    super.initState();
    // Guarda a rota: só usuários autenticados podem ver esta tela.
    if (!_viewModel.estaLogado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Meu perfil'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF37474F),
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nome',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              _viewModel.nomeUsuario ?? '—',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            const Text(
              'Email institucional',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              _viewModel.emailUsuario ?? '—',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
