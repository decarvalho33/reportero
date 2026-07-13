import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/auth_service.dart';
import '../services/denuncia_service.dart';
import '../utils/filtro_denuncias.dart';

class MinhasDenunciasViewModel extends ChangeNotifier {
  MinhasDenunciasViewModel({
    Future<List<Denuncia>> Function()? buscarDenuncias,
    AuthService? authService,
  })  : _buscarDenuncias = buscarDenuncias ?? DenunciaService().obterMinhasDenuncias,
        _auth = authService ?? AuthService();

  final Future<List<Denuncia>> Function() _buscarDenuncias;
  final AuthService _auth;

  List<Denuncia> _todasDenuncias = [];
  List<Denuncia> _denunciasFiltradas = [];
  bool _isLoading = false;
  String? _erro;
  String _filtroTexto = '';
  Categoria? _filtroCategoria;
  String? _filtroStatus;

  List<Denuncia> get denuncias => _denunciasFiltradas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get estaLogado => _auth.estaLogado;
  Categoria? get filtroCategoria => _filtroCategoria;
  String? get filtroStatus => _filtroStatus;
  bool get temDenunciasCadastradas => _todasDenuncias.isNotEmpty;

  /// Status distintos entre as denúncias do usuário, para montar os filtros
  /// (não há um enum fixo de status — a coluna é texto livre, hoje só
  /// populada por 'Aberta').
  List<String> get statusDisponiveis =>
      _todasDenuncias.map((d) => d.status).toSet().toList()..sort();

  Future<void> carregar() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _todasDenuncias = await _buscarDenuncias();
      _aplicarFiltros();
    } catch (e) {
      _erro = 'Não foi possível carregar suas denúncias.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void filtrarPorTexto(String texto) {
    _filtroTexto = texto;
    _aplicarFiltros();
    notifyListeners();
  }

  void filtrarPorCategoria(Categoria? categoria) {
    _filtroCategoria = categoria;
    _aplicarFiltros();
    notifyListeners();
  }

  void filtrarPorStatus(String? status) {
    _filtroStatus = status;
    _aplicarFiltros();
    notifyListeners();
  }

  void _aplicarFiltros() {
    _denunciasFiltradas = FiltroDenuncias.aplicar(
      _todasDenuncias,
      texto: _filtroTexto,
      categoria: _filtroCategoria,
      status: _filtroStatus,
    );
  }

  @visibleForTesting
  void carregarDenunciasLocais(List<Denuncia> denuncias) {
    _todasDenuncias = denuncias;
    _aplicarFiltros();
    notifyListeners();
  }
}
