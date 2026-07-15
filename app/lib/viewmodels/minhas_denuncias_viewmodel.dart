import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/auth_service.dart';
import '../services/denuncia_service.dart';
import '../services/status_visto_service.dart';
import '../utils/filtro_denuncias.dart';

class MinhasDenunciasViewModel extends ChangeNotifier {
  MinhasDenunciasViewModel({
    Future<List<Denuncia>> Function()? buscarDenuncias,
    Future<void> Function(Denuncia)? excluirDenuncia,
    AuthService? authService,
    StatusVistoService? statusVistoService,
  })  : _buscarDenuncias = buscarDenuncias ?? DenunciaService().obterMinhasDenuncias,
        _excluirDenuncia = excluirDenuncia ?? DenunciaService().excluirDenuncia,
        _auth = authService ?? AuthService(),
        _statusVisto = statusVistoService ?? StatusVistoService();

  final Future<List<Denuncia>> Function() _buscarDenuncias;
  final Future<void> Function(Denuncia) _excluirDenuncia;
  final AuthService _auth;
  final StatusVistoService _statusVisto;

  List<Denuncia> _todasDenuncias = [];
  List<Denuncia> _denunciasFiltradas = [];
  bool _isLoading = false;
  String? _erro;
  String _filtroTexto = '';
  Categoria? _filtroCategoria;
  StatusDenuncia? _filtroStatus;
  Set<String> _denunciasComMudancaDeStatus = {};

  List<Denuncia> get denuncias => _denunciasFiltradas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get estaLogado => _auth.estaLogado;
  Categoria? get filtroCategoria => _filtroCategoria;
  StatusDenuncia? get filtroStatus => _filtroStatus;
  bool get temDenunciasCadastradas => _todasDenuncias.isNotEmpty;

  /// Ids das denúncias cujo status mudou desde a última vez que o usuário as
  /// visualizou (US 5.5). Denúncias nunca vistas antes não entram aqui.
  Set<String> get denunciasComMudancaDeStatus => _denunciasComMudancaDeStatus;

  /// Indica se [denuncia] teve seu status alterado desde a última visualização.
  bool temMudancaDeStatus(Denuncia denuncia) {
    final id = denuncia.id;
    return id != null && _denunciasComMudancaDeStatus.contains(id);
  }

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
      await _detectarMudancasDeStatus();
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

  /// Compara o status atual de cada denúncia com o último status visto
  /// (US 5.5). Uma denúncia sem entrada no mapa de vistos ainda não foi
  /// vista nenhuma vez, então não conta como mudança — só entra na lista
  /// quando havia um status registrado e ele é diferente do atual.
  Future<void> _detectarMudancasDeStatus() async {
    final vistos = await _statusVisto.obterStatusVistos();
    final mudancas = <String>{};

    for (final denuncia in _todasDenuncias) {
      final id = denuncia.id;
      if (id == null) continue;

      final ultimoVisto = vistos[id];
      if (ultimoVisto != null && ultimoVisto != denuncia.status.label) {
        mudancas.add(id);
      }
    }

    _denunciasComMudancaDeStatus = mudancas;
  }

  /// Marca [denuncia] como vista (US 5.5): grava seu status atual como o
  /// último visto e some com o indicador de mudança pendente.
  Future<void> marcarComoVisto(Denuncia denuncia) async {
    final id = denuncia.id;
    if (id == null) return;

    await _statusVisto.marcarComoVisto(id, denuncia.status);
    _denunciasComMudancaDeStatus.remove(id);
    notifyListeners();
  }

  @visibleForTesting
  void carregarDenunciasLocais(List<Denuncia> denuncias) {
    _todasDenuncias = denuncias;
    _aplicarFiltros();
    notifyListeners();
  }
}
