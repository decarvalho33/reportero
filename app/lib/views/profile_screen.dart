import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/perfil_service.dart';
import '../viewmodels/perfil_viewmodel.dart';

/// Tela de perfil. Exibe nome e email do usuário autenticado (US 5.1) e
/// permite editar o nome (US 5.2) — o email institucional é somente leitura,
/// já que a troca de email exige um fluxo de verificação próprio.
///
/// Aceita um [PerfilViewModel] via construtor para permitir testes sem
/// depender do Supabase real.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, PerfilViewModel? viewModel})
      : _viewModelInjetado = viewModel;

  final PerfilViewModel? _viewModelInjetado;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final PerfilViewModel _viewModel =
      widget._viewModelInjetado ?? PerfilViewModel();
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _picker = ImagePicker();
  bool _editando = false;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    if (!_viewModel.estaLogado) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
      return;
    }
    _viewModel.carregar();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _nomeCtrl.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  void _iniciarEdicao() {
    _nomeCtrl.text = _viewModel.nome ?? '';
    setState(() => _editando = true);
  }

  void _cancelarEdicao() {
    setState(() => _editando = false);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final sucesso = await _viewModel.salvarNome(_nomeCtrl.text);
    if (!mounted) return;

    if (sucesso) {
      setState(() => _editando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso.')),
      );
    } else if (_viewModel.erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.erro!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _selecionarFotoPerfil() async {
    try {
      final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (imagem == null) return;

      final bytes = await imagem.readAsBytes();
      final sucesso = await _viewModel.atualizarFotoPerfil(bytes, imagem.name);
      if (!mounted) return;

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil atualizada com sucesso.')),
        );
      } else if (_viewModel.erro != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_viewModel.erro!),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível selecionar a foto: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
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
        actions: [
          if (!_editando)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar',
              onPressed: _iniciarEdicao,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF37474F),
                    backgroundImage: _viewModel.fotoUrl != null
                        ? NetworkImage(_viewModel.fotoUrl!)
                        : null,
                    child: _viewModel.fotoUrl == null
                        ? const Icon(Icons.person, color: Colors.white, size: 40)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _viewModel.isLoading ? null : _selecionarFotoPerfil,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Nome',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 4),
              if (_editando)
                TextFormField(
                  controller: _nomeCtrl,
                  autofocus: true,
                  validator: (v) => PerfilService.nomeValido(v ?? '')
                      ? null
                      : 'O nome deve ter ao menos ${PerfilService.nomeMinimo} caracteres.',
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              else
                Text(
                  _viewModel.nome ?? '—',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'Email institucional',
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                _viewModel.email ?? '—',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_editando) ...[
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _viewModel.isLoading ? null : _cancelarEdicao,
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _viewModel.isLoading ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                        ),
                        child: _viewModel.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Salvar'),
                      ),
                    ),
                  ],
                ),
              ],
              if (!_editando) ...[
                const SizedBox(height: 32),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.list_alt, color: Color(0xFF37474F)),
                  title: const Text('Minhas denúncias'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.pushNamed(context, '/minhas-denuncias'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
