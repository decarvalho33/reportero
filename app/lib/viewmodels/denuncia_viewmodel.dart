import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class DenunciaViewModel {
  final formKey = GlobalKey<FormState>();

  final _service = DenunciaService();

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
      try {
        // chamada real para o serviço de envio
        await _service.enviarDenuncia(novaDenuncia);
        return true;
      } catch (e) {
        debugPrint("Erro ao processar no backend: $e");
        return false;
      }
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