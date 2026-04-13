import 'package:flutter/material.dart';
import '../models/denuncia.dart';

class DenunciaViewModel {
  final formKey = GlobalKey<FormState>();
  
  // Controllers que a View vai usar
  final tituloCtrl = TextEditingController();
  final localCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final autorCtrl = TextEditingController();

  // F1-02: Validação (Lógica de Negócio)
  String? validarObrigatorio(String? value) {
    if (value == null || value.isEmpty) return "Este campo é obrigatório";
    return null;
  }

  // F1-03 / F1-04: Processamento
  Future<bool> submeterFormulario() async {
    if (formKey.currentState!.validate()) {
      // Aqui o João integrará o DenunciaService futuramente
      final novaDenuncia = Denuncia(
        titulo: tituloCtrl.text,
        localizacao: localCtrl.text,
        descricao: descCtrl.text,
        autor: autorCtrl.text.isEmpty ? "Anônimo" : autorCtrl.text,
      );
      
      debugPrint("Simulando envio ao Service: ${novaDenuncia.titulo}");
      return true; // Sucesso na validação/processamento
    }
    return false;
  }

  void limpar() {
    tituloCtrl.clear();
    localCtrl.clear();
    descCtrl.clear();
    autorCtrl.clear();
  }
}