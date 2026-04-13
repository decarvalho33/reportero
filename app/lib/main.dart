import 'package:flutter/material.dart';

void main() => runApp(const ReporteroApp());

class ReporteroApp extends StatelessWidget {
  const ReporteroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Unicamp Safety',
      theme: ThemeData(
        // Cinza azulado para um ar mais moderno e menos "pesado" que o vermelho puro
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF455A64), 
          primary: const Color(0xFF37474F),
        ),
        useMaterial3: true,
      ),
      home: const FormularioDenunciaScreen(),
    );
  }
}

class FormularioDenunciaScreen extends StatefulWidget {
  const FormularioDenunciaScreen({super.key});

  @override
  State<FormularioDenunciaScreen> createState() => _FormularioDenunciaScreenState();
}

class _FormularioDenunciaScreenState extends State<FormularioDenunciaScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _autorCtrl = TextEditingController();
  final _localCtrl = TextEditingController();

  void _enviarDenuncia() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Denúncia enviada com sucesso!'),
          backgroundColor: Colors.teal[700], // Verde para indicar sucesso
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      _tituloCtrl.clear();
      _descCtrl.clear();
      _autorCtrl.clear();
      _localCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Cinza bem clarinho de fundo
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), 
                fit: BoxFit.cover,
                opacity: 0.08, // Ainda mais sutil
              ),
            ),
          ),
          
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF37474F), // Grafite elegante
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    "Reportero Unicamp", 
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    )
                  ),
                  background: Image.asset(
                    'assets/header.jpg', 
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.3), // Escurece um pouco a foto para ler o texto
                    colorBlendMode: BlendMode.darken,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: const Color(0xFF455A64));
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nova Ocorrência", 
                          style: TextStyle(
                            fontSize: 22, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.blueGrey[900]
                          )
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Preencha os detalhes abaixo para reportar.",
                          style: TextStyle(color: Colors.blueGrey[600]),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildInput(
                          controller: _tituloCtrl,
                          label: "Título da Ocorrência *",
                          icon: Icons.edit_note,
                          validator: (v) => v!.isEmpty ? "O título é obrigatório" : null,
                        ),

                        _buildInput(
                          controller: _localCtrl,
                          label: "Localização / Prédio *",
                          icon: Icons.location_on_outlined,
                          validator: (v) => v!.isEmpty ? "O local é obrigatório" : null,
                        ),

                        _buildInput(
                          controller: _autorCtrl,
                          label: "Seu Nome (Opcional)",
                          icon: Icons.person_outline,
                        ),

                        _buildInput(
                          controller: _descCtrl,
                          label: "Descrição do Incidente *",
                          icon: Icons.chat_bubble_outline,
                          maxLines: 4,
                          validator: (v) => v!.isEmpty ? "A descrição é obrigatória" : null,
                        ),

                        const SizedBox(height: 24),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _enviarDenuncia,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32), // Verde Unicamp/Segurança
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)
                              ),
                            ),
                            child: const Text(
                              "REGISTRAR DENÚNCIA", 
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)
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
          labelStyle: TextStyle(color: Colors.blueGrey[700], fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
      ),
    );
  }
}