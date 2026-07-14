import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';
import '../utils/filtro_denuncias.dart';

enum TipoOrdenacao {
  recente,
  antiga,
  apoios,
}

class FeedViewModel extends ChangeNotifier {
  final _service = DenunciaService();

  DenunciaService get service => _service;

  List<Denuncia> _allDenuncias = [];
  List<Denuncia> _denunciasFiltradas = [];

  bool _isLoading = false;
  String? _erro;
  TipoOrdenacao _tipoOrdenacao = TipoOrdenacao.recente;
  String _filtroTexto = "";
  Categoria? _filtroCategoria;

  List<Denuncia> get denuncias => _denunciasFiltradas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  TipoOrdenacao get tipoOrdenacao => _tipoOrdenacao;
  Categoria? get filtroCategoria => _filtroCategoria;

  Future<void> carregarDenuncias() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _allDenuncias = await _service.obtenerDenuncias();
      _aplicarFiltrosEOrdenacao();
    } catch (e) {
      _erro = "Erro ao carregar denúncias";
      debugPrint("Erro: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void alternarOrdenacao(TipoOrdenacao tipo) {
    _tipoOrdenacao = tipo;
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  void filtrarPorTexto(String texto) {
    _filtroTexto = texto.toLowerCase();
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  void filtrarPorCategoria(Categoria? categoria) {
    _filtroCategoria = categoria;
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  Future<void> alternarApoio(Denuncia denuncia) async {
    try {
      if (denuncia.jaApoiei) {
        await _service.removerApoio(denuncia.id!);
        _substituirDenuncia(denuncia.copyWith(
          jaApoiei: false,
          totalApoios: denuncia.totalApoios - 1,
        ));
      } else {
        await _service.apoiar(denuncia.id!);
        _substituirDenuncia(denuncia.copyWith(
          jaApoiei: true,
          totalApoios: denuncia.totalApoios + 1,
        ));
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao atualizar apoio: $e");
    }
  }

  void _substituirDenuncia(Denuncia atualizada) {
    final index = _allDenuncias.indexWhere((d) => d.id == atualizada.id);
    if (index != -1) {
      _allDenuncias[index] = atualizada;
    }
    _aplicarFiltrosEOrdenacao();
  }

  void _aplicarFiltrosEOrdenacao() {
    _denunciasFiltradas = FiltroDenuncias.aplicar(
      _allDenuncias,
      texto: _filtroTexto,
      categoria: _filtroCategoria,
    );

    switch (_tipoOrdenacao) {
      case TipoOrdenacao.recente:
        _denunciasFiltradas.sort(
          (a, b) => (b.createdAt ?? DateTime.now())
              .compareTo(a.createdAt ?? DateTime.now()),
        );
        break;
      case TipoOrdenacao.antiga:
        _denunciasFiltradas.sort(
          (a, b) => (a.createdAt ?? DateTime.now())
              .compareTo(b.createdAt ?? DateTime.now()),
        );
        break;
      case TipoOrdenacao.apoios:
        _denunciasFiltradas.sort((a, b) {
          final comparacao = b.totalApoios.compareTo(a.totalApoios);
          if (comparacao != 0) return comparacao;
          return (b.createdAt ?? DateTime.now())
              .compareTo(a.createdAt ?? DateTime.now());
        });
        break;
    }
  }

  @visibleForTesting
  void carregarDenunciasLocais(List<Denuncia> denuncias) {
    _allDenuncias = denuncias;
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  String formatarTempo(DateTime? data) {
    if (data == null) return '';
    final diff = DateTime.now().difference(data);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }
}
