import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/auth_service.dart';

class NovaSenhaScreen extends StatefulWidget {
  const NovaSenhaScreen({super.key});

  @override
  State<NovaSenhaScreen> createState() => _NovaSenhaScreenState();
}

class _NovaSenhaScreenState extends State<NovaSenhaScreen> {
  final _viewModel = AuthViewModel();
  final _formKey = GlobalKey<FormState>();
  final _senhaCtrl = TextEditingController();

  bool _ocultarSenha = true;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _senhaCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _salvarNovaSenha() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final sucesso = await _viewModel.atualizarSenha(_senhaCtrl.text);
      if (sucesso && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Senha redefinida"),
            content: const Text(
              "Sua senha foi alterada com sucesso! Você já pode navegar pelo app.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Limpa a pilha de rotas e joga para o feed
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/feed',
                    (route) => false,
                  );
                },
                child: const Text("IR PARA O FEED"),
              ),
            ],
          ),
        );
      } else if (_viewModel.erro != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.erro!),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Nova Senha',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.password, size: 80, color: Color(0xFF37474F)),
              const SizedBox(height: 24),
              const Text(
                "Crie sua nova senha",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Você foi autenticado via link seguro. Defina a nova senha.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: _senhaCtrl,
                obscureText: _ocultarSenha,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _salvarNovaSenha,
                validator: (v) => AuthService.senhaValida(v ?? '')
                    ? null
                    : 'A senha deve ter ao menos ${AuthService.senhaMinima} caracteres.',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nova senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _ocultarSenha
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _ocultarSenha = !_ocultarSenha),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  helperText: 'No mínimo 6 caracteres',
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _salvarNovaSenha,
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
                          "SALVAR SENHA",
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
