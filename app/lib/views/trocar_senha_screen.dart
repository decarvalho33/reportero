import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Tela de troca de senha do usuário autenticado, acessível a partir do
/// perfil. Diferente da tela de nova senha (fluxo de recuperação via link de
/// email), aqui é exigida a senha atual antes de aplicar a nova — ver
/// [AuthService.trocarSenha].
///
/// Aceita um [AuthViewModel] via construtor para permitir testes sem
/// depender do Supabase real.
class TrocarSenhaScreen extends StatefulWidget {
  const TrocarSenhaScreen({super.key, AuthViewModel? viewModel})
      : _viewModelInjetado = viewModel;

  final AuthViewModel? _viewModelInjetado;

  @override
  State<TrocarSenhaScreen> createState() => _TrocarSenhaScreenState();
}

class _TrocarSenhaScreenState extends State<TrocarSenhaScreen> {
  late final AuthViewModel _viewModel =
      widget._viewModelInjetado ?? AuthViewModel();
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  final _confirmarSenhaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    _confirmarSenhaCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _trocarSenha() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    final sucesso = await _viewModel.trocarSenha(
      senhaAtual: _senhaAtualCtrl.text,
      novaSenha: _novaSenhaCtrl.text,
    );
    if (!mounted) return;

    if (sucesso) {
      _senhaAtualCtrl.clear();
      _novaSenhaCtrl.clear();
      _confirmarSenhaCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso.')),
      );
    } else if (_viewModel.erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.erro!),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Trocar senha'),
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                key: const ValueKey('campo_senha_atual'),
                controller: _senhaAtualCtrl,
                obscureText: true,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a senha atual.' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Senha atual',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('campo_nova_senha'),
                controller: _novaSenhaCtrl,
                obscureText: true,
                validator: (v) => AuthService.senhaValida(v ?? '')
                    ? null
                    : 'A senha deve ter ao menos ${AuthService.senhaMinima} caracteres.',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nova senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'No mínimo ${AuthService.senhaMinima} caracteres',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('campo_confirmar_senha'),
                controller: _confirmarSenhaCtrl,
                obscureText: true,
                validator: (v) => v != _novaSenhaCtrl.text
                    ? 'As senhas não coincidem.'
                    : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Confirmar nova senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _trocarSenha,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _viewModel.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'SALVAR SENHA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
