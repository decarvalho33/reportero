import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';


class AdminDetailViewModel extends ChangeNotifier {
  final DenunciaService _service = DenunciaService();

  bool _isLoading = false;
  String? _erro;

  bool get isLoading => _isLoading;
  String? get erro => _erro;

  Future<bool> atualizarStatus(
    String denunciaId,
    StatusDenuncia novoStatus,
  ) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _service.atualizarStatus(
        denunciaId,
        novoStatus,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _erro = "Erro ao atualizar status.";

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> responderAutor(
    String denunciaId,
    String resposta,
  ) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _service.responderDenuncia(
        denunciaId,
        resposta,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _erro = "Erro ao responder ao autor.";

      _isLoading = false;
      notifyListeners();

      return false;
    
    }
  }

  Future<bool> atribuirSetor(
    String denunciaId,
    String setor,
  ) async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      await _service.atribuirSetor(
        denunciaId,
        setor,
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _erro = "Erro ao atribuir setor.";

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

}
