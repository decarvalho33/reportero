import 'package:flutter/material.dart';

import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final DenunciaService _service = DenunciaService();

  List<Denuncia> _denuncias = [];
  List<Denuncia> _todasDenuncias = [];
  String busca = "";
  Categoria? categoriaSelecionada;
  StatusDenuncia? statusSelecionado;
  bool _isLoading = false;
  String? _erro;

  List<Denuncia> get denuncias => _denuncias;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  int get totalDenuncias => _denuncias.length;

  int get totalPendentes =>
      _denuncias.where((d) => d.status == StatusDenuncia.pendente).length;

  int get totalEmAnalise =>
      _denuncias.where((d) => d.status == StatusDenuncia.emAnalise).length;

  int get totalResolvidas =>
      _denuncias.where((d) => d.status == StatusDenuncia.resolvida).length;

  Future<void> carregarDenuncias() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _todasDenuncias = await _service.obtenerDenuncias();

      _denuncias = List.from(_todasDenuncias);
    } catch (e) {
      _erro = "Erro ao carregar denúncias.";
      debugPrint(e.toString());
    }

    _isLoading = false;
    notifyListeners();
  }

  void aplicarFiltros() {
    _denuncias = _todasDenuncias.where((d) {

      final texto =
          d.titulo.toLowerCase().contains(busca.toLowerCase()) ||
          d.descricao.toLowerCase().contains(busca.toLowerCase()) ||
          d.localizacao.toLowerCase().contains(busca.toLowerCase());

      final categoria =
          categoriaSelecionada == null ||
          d.categoria == categoriaSelecionada;

      final status =
          statusSelecionado == null ||
          d.status == statusSelecionado;

      return texto && categoria && status;

    }).toList();

    notifyListeners();
  }

}