import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/denuncia.dart';
import '../viewmodels/denuncia_viewmodel.dart';

class FormularioDenunciaScreen extends StatefulWidget {
  const FormularioDenunciaScreen({super.key, this.denuncia});

  /// Quando informada, o formulário abre em modo de edição (US 5.6/5.7).
  final Denuncia? denuncia;

  @override
  State<FormularioDenunciaScreen> createState() => _FormularioDenunciaScreenState();
}

class _FormularioDenunciaScreenState extends State<FormularioDenunciaScreen> {
  late final viewModel = DenunciaViewModel(denunciaExistente: widget.denuncia);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _selecionarFoto() async {
    try {
      final XFile? imagem = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (imagem != null) {
        final bytes = await imagem.readAsBytes();
        viewModel.definirFoto(bytes, imagem.name);
      }
    } catch (e) {
      debugPrint("Erro ao selecionar foto: $e");
    }
  }

  void _enviar() async {
    if (viewModel.isLoading) return;

    bool sucesso = await viewModel.submeterFormulario();
    if (sucesso) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.emEdicao
                  ? 'Denúncia atualizada com sucesso!'
                  : 'Denúncia enviada com sucesso!',
            ),
            backgroundColor: Colors.teal[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      if (!viewModel.emEdicao) viewModel.limpar();
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              viewModel.emEdicao
                  ? 'Falha ao salvar alterações. Verifique a conexão.'
                  : 'Falha ao enviar denúncia. Verifique a conexão.',
            ),
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'),
                fit: BoxFit.cover,
                opacity: 0.08,
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF37474F),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    "Reportero Unicamp",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  background: Image.asset(
                    'assets/header.jpg',
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3),
                    colorBlendMode: BlendMode.darken,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFF455A64)),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: viewModel.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.emEdicao ? "Editar Ocorrência" : "Nova Ocorrência",
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF37474F)),
                        ),
                        const SizedBox(height: 24),

                        _buildInput(
                          controller: viewModel.tituloCtrl,
                          label: "Título da Ocorrência *",
                          icon: Icons.edit_note,
                          validator: viewModel.validarObrigatorio,
                        ),

                        _buildInput(
                          controller: viewModel.localCtrl,
                          label: "Localização / Prédio *",
                          icon: Icons.location_on_outlined,
                          validator: viewModel.validarObrigatorio,
                        ),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<Categoria>(
                            value: viewModel.categoriaSelecionada,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.category_outlined, color: Colors.blueGrey[400]),
                              labelText: "Categoria do Incidente *",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            isExpanded: true,
                            selectedItemBuilder: (BuildContext context) {
                              return Categoria.values.map<Widget>((Categoria cat) {
                                return Text(cat.label, style: const TextStyle(fontSize: 15));
                              }).toList();
                            },
                            items: Categoria.values.map((Categoria cat) {
                              return DropdownMenuItem<Categoria>(
                                value: cat,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(cat.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  subtitle: Text(cat.descricao, style: const TextStyle(fontSize: 11, height: 1.2)),
                                ),
                              );
                            }).toList(),
                            onChanged: (Categoria? nova) {
                              if (nova != null) viewModel.definirCategoria(nova);
                            },
                          ),
                        ),

                        _buildGpsCard(),

                        Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Evidência Visual', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 8),
                                if (viewModel.fotoBytes != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.memory(viewModel.fotoBytes!, height: 150, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 8),
                                ] else if (viewModel.fotoUrlExistente != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(viewModel.fotoUrlExistente!, height: 150, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                OutlinedButton.icon(
                                  onPressed: _selecionarFoto,
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: Text(viewModel.fotoBytes != null ? 'Alterar Foto' : 'Selecionar Foto da Evidência'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF37474F),
                                    side: BorderSide(color: Colors.blueGrey[200]!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        _buildInput(
                          controller: viewModel.autorCtrl,
                          label: "Seu Nome (Opcional)",
                          icon: Icons.person_outline,
                        ),

                        _buildInput(
                          controller: viewModel.descCtrl,
                          label: "Descrição do Incidente *",
                          icon: Icons.chat_bubble_outline,
                          maxLines: 4,
                          validator: viewModel.validarObrigatorio,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: viewModel.isLoading ? null : _enviar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: viewModel.isLoading
                                ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                                : Text(
                                    viewModel.emEdicao ? "SALVAR ALTERAÇÕES" : "REGISTRAR DENÚNCIA",
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.blueGrey[400]),
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }

  Widget _buildGpsCard() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SwitchListTile(
        title: const Text('Anexar Coordenadas GPS', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(
          viewModel.coordenadasFormatadas,
          style: TextStyle(
            color: viewModel.latitude != null ? Colors.green[700] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        value: viewModel.latitude != null,
        activeColor: const Color(0xFF2E7D32),
        onChanged: viewModel.alternarLocalizacaoGps,
      ),
    );
  }
}
