import 'package:flutter/material.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../services/auth_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _viewModel = AuthViewModel();
  final _formKey = GlobalKey<FormState>();
  
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
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
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _fazerCadastro() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      final sucesso = await _viewModel.cadastrar(_nomeCtrl.text, _emailCtrl.text, _senhaCtrl.text);
      if (sucesso && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Cadastro realizado"),
            content: const Text("Um link de confirmação foi enviado para o seu email. Por favor, verifique sua caixa de entrada antes de fazer login."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // fecha dialog
                  Navigator.pop(context); // volta para login
                },
                child: const Text("OK"),
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
        title: const Text('Nova Conta', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Junte-se à comunidade",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF37474F),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Crie sua conta utilizando o email institucional para validar seu vínculo com a UNICAMP.",
                style: TextStyle(color: Colors.black54, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nomeCtrl,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe seu nome.' : null,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Nome ou Apelido',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) => AuthService.emailInstitucionalValido(v ?? '') 
                    ? null 
                    : 'Use um email institucional da UNICAMP.',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Email institucional',
                  hintText: 'ex: a123456@dac.unicamp.br',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _senhaCtrl,
                obscureText: _ocultarSenha,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _fazerCadastro(),
                validator: (v) => AuthService.senhaValida(v ?? '') 
                    ? null 
                    : 'A senha deve ter ao menos ${AuthService.senhaMinima} caracteres.',
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  helperText: 'No mínimo 6 caracteres',
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _viewModel.isLoading ? null : _fazerCadastro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _viewModel.isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("CRIAR CONTA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
