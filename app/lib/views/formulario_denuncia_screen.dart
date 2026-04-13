import 'package:flutter/material.dart';
import '../viewmodels/denuncia_viewmodel.dart';

class FormularioDenunciaScreen extends StatefulWidget {
  const FormularioDenunciaScreen({super.key});

  @override
  State<FormularioDenunciaScreen> createState() => _FormularioDenunciaScreenState();
}

class _FormularioDenunciaScreenState extends State<FormularioDenunciaScreen> {
  // Instância da lógica separada da UI
  final viewModel = DenunciaViewModel();

  void _enviar() async {
    bool sucesso = await viewModel.submeterFormulario();
    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Denúncia enviada com sucesso!'),
          backgroundColor: Colors.teal[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      // F1-04: Limpar campos após sucesso via ViewModel
      viewModel.limpar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // IMAGEM DE FUNDO (Aérea da Unicamp)
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
              // HEADER COM IMAGEM (Entrada da Unicamp)
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF37474F),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    "Reportero Unicamp", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
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
                    key: viewModel.formKey, // Usa a chave que está na ViewModel
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Nova Ocorrência", 
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF37474F))
                        ),
                        const SizedBox(height: 24),
                        
                        // TÍTULO
                        _buildInput(
                          controller: viewModel.tituloCtrl,
                          label: "Título da Ocorrência *",
                          icon: Icons.edit_note,
                          validator: viewModel.validarObrigatorio,
                        ),

                        // LOCALIZAÇÃO (OBRIGATÓRIO)
                        _buildInput(
                          controller: viewModel.localCtrl,
                          label: "Localização / Prédio *",
                          icon: Icons.location_on_outlined,
                          validator: viewModel.validarObrigatorio,
                        ),

                        // AUTOR (OPCIONAL)
                        _buildInput(
                          controller: viewModel.autorCtrl,
                          label: "Seu Nome (Opcional)",
                          icon: Icons.person_outline,
                        ),

                        // DESCRIÇÃO
                        _buildInput(
                          controller: viewModel.descCtrl,
                          label: "Descrição do Incidente *",
                          icon: Icons.chat_bubble_outline,
                          maxLines: 4,
                          validator: viewModel.validarObrigatorio,
                        ),

                        const SizedBox(height: 24),
                        
                        // BOTÃO DE ENVIO
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _enviar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              "REGISTRAR DENÚNCIA", 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para os inputs
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
}