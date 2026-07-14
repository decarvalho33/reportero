import 'package:flutter/material.dart';
import '../services/denuncia_service.dart';

class AdminUsersViewModel extends ChangeNotifier {
  final DenunciaService _service = DenunciaService();

  List<Map<String, dynamic>> usuarios = [];

  bool isLoading = false;
  String? erro;

  Future<void> carregarUsuarios() async {
    isLoading = true;
    erro = null;
    notifyListeners();

    try {
      usuarios = await _service.listarPerfis();
    } catch (e) {
      erro = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> alterarPermissao(
    Map<String, dynamic> usuario,
  ) async {
    final bool admin = usuario["is_admin"] == true;

    if (admin) {
      await _service.removerAdmin(usuario["id"]);
    } else {
      await _service.promoverParaAdmin(usuario["id"]);
    }

    await carregarUsuarios();
  }
}