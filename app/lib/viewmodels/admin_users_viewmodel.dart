import 'package:flutter/material.dart';
import '../services/denuncia_service.dart';

class AdminUsersViewModel extends ChangeNotifier {
  final DenunciaService _service = DenunciaService();

  List<Map<String, dynamic>> _usuarios = [];

  bool _isLoading = false;
  String? _erro;

  List<Map<String, dynamic>> get usuarios => _usuarios;

  bool get isLoading => _isLoading;

  String? get erro => _erro;

  Future<void> carregarUsuarios() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _usuarios = await _service.listarPerfis();
    } catch (e) {
      _erro = "Erro ao carregar usuários.";
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> alterarPermissao(
    String id,
    bool tornarAdmin,
  ) async {
    try {
      if (tornarAdmin) {
        await _service.promoverParaAdmin(id);
      } else {
        await _service.removerAdmin(id);
      }

      await carregarUsuarios();

      return true;
    } catch (e) {
      _erro = "Erro ao alterar permissões.";
      notifyListeners();
      return false;
    }
  }
}