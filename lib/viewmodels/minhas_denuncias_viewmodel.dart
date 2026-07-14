import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/auth_service.dart';
import '../services/denuncia_service.dart';
import '../utils/filtro_denuncias.dart';

class MinhasDenunciasViewModel extends ChangeNotifier {
  MinhasDenunciasViewModel({
    Future<List<Denuncia>> Function()? buscarDenuncias,
    Future<void> Function(Denuncia)? excluirDenuncia,
    AuthService? authService,
  })  : _buscarDenuncias = buscarDenuncias ?? DenunciaService().obterMinhasDenuncias,
        _excluirDenuncia = excluirDenuncia ?? DenunciaService().excluirDenuncia,
        _auth = authService ?? AuthService();

  final Future<List<Denuncia>> Function() _buscarDenuncias;
  final Future<void> Function(Denuncia) _excluirDenuncia;
  final AuthService _auth;

  List<Denuncia> _todasDenuncias = [];
  List<Denuncia> _denunciasFiltradas = [];
  bool _isLoading = false;
  String? _erro;
  String _filtroTexto = '';
  Categoria? _filtroCategoria;
  StatusDenuncia? _filtroStatus;

  List<Denuncia> get denuncias => _denunciasFiltradas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get estaLogado => _auth.estaLogado;
  Categoria? get filtroCategoria => _filtroCategoria;
  StatusDenuncia? get filtroStatus => _filtroStatus;
  bool get temDenunciasCadastradas => _todasDenuncias.isNotEmpty;

  /// Status distintos entre as denúncias do usuário, na ordem do enum
  /// (pendente, em análise, resolvida), para montar os filtros.
  List<StatusDenuncia> get statusDisponiveis {
    final presentes = _todasDenuncias.map((d) => d.status).toSet().toList();
    presentes.sort((a, b) => a.index.compareTo(b.index));
    return presentes;
  }

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

  void filtrarPorStatus(StatusDenuncia? status) {
    _filtroStatus = status;
    _aplicarFiltros();
    notifyListeners();
  }

  /// Exclui a denúncia (US 5.6/5.7) e a remove da lista local em caso de
  /// sucesso. A restrição de autoria é garantida pelo service/RLS; aqui só
  /// tratamos o resultado.
  Future<bool> excluir(Denuncia denuncia) async {
    try {
      await _excluirDenuncia(denuncia);
      _todasDenuncias.removeWhere((d) => d.id == denuncia.id);
      _aplicarFiltros();
      notifyListeners();
      return true;
    } catch (e) {
      _erro = 'Não foi possível excluir a denúncia.';
      notifyListeners();
      return false;
    }
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
