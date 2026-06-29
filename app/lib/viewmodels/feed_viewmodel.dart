import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

enum TipoOrdenacao {
  recente,
  antiga,
  apoios,
}

class FeedViewModel extends ChangeNotifier {
  final _service = DenunciaService();
  
  List<Denuncia> _allDenuncias = []; /// Cache completo vindo do Supabase
  List<Denuncia> _denunciasFiltradas = []; /// Lista exibida na tela
  
  bool _isLoading = false;
  String? _erro;
  TipoOrdenacao _tipoOrdenacao = TipoOrdenacao.recente; /// Controle de estado da ordenação
  String _filtroTexto = ""; /// Estado do filtro de busca

  List<Denuncia> get denuncias => _denunciasFiltradas;
  bool get isLoading => _isLoading;
  String? get erro => _erro; 
  TipoOrdenacao get tipoOrdenacao => _tipoOrdenacao;

  /// Carrega as denúncias do Supabase, aplicando filtros e ordenação conforme o estado atual.
  Future<void> carregarDenuncias() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    /// Busca todas as denúncias do Supabase
    try {
      _allDenuncias = await _service.obtenerDenuncias();
      _allDenuncias.insert(0, Denuncia(
        id: "teste_mock_axel",
        titulo: "Lâmpada Quebrada na Unicamp",
        descricao: "A lâmpada perto do bandejão está piscando faz duas semanas. Perigoso andar por aqui à noite.",
        localizacao: "Perto do Restaurante Universitário",
        autor: "Axel (Teste Frontend)",
        latitude: -22.8184,
        longitude: -47.0647,
        fotoUrl: "https://picsum.photos/400/200",
        createdAt: DateTime.now(),
      ));

      /// Aplica filtros e ordenação na lista carregada
      _aplicarFiltrosEOrdenacao();
    } catch (e) {
      _erro = "Erro ao carregar denúncias";
      debugPrint("Erro: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Alterna o estado de ordenação (Mais recentes vs Antigas) 
  void alternarOrdenacao(TipoOrdenacao tipo) {
    _tipoOrdenacao = tipo;
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  /// Define o termo de busca para a filtragem 
  void filtrarPorTexto(String texto) {
    _filtroTexto = texto.toLowerCase();
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  Future<void> alternarApoio(Denuncia denuncia) async {
    try {
      if (denuncia.jaApoiei) {
        await _service.removerApoio(denuncia.id!);

        final atualizada = denuncia.copyWith(
          jaApoiei: false,
          totalApoios: denuncia.totalApoios - 1,
        );

        _substituirDenuncia(atualizada);
      } else {
        await _service.apoiar(denuncia.id!);

        final atualizada = denuncia.copyWith(
          jaApoiei: true,
          totalApoios: denuncia.totalApoios + 1,
        );

        _substituirDenuncia(atualizada);
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

  /// Lógica interna para processar os dados em memória
  void _aplicarFiltrosEOrdenacao() {
    /// Aplicar Filtro por Texto
    if (_filtroTexto.isEmpty) {
      _denunciasFiltradas = List.from(_allDenuncias);
    } else {
      _denunciasFiltradas = _allDenuncias.where((d) {
        return d.titulo.toLowerCase().contains(_filtroTexto) ||
               d.descricao.toLowerCase().contains(_filtroTexto) ||
               d.localizacao.toLowerCase().contains(_filtroTexto);
      }).toList();
    }

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

          if (comparacao != 0) {
            return comparacao;
          }

          return (b.createdAt ?? DateTime.now())
              .compareTo(a.createdAt ?? DateTime.now());
        });

        break;
    }
  }

  /// Formata a data de criação da denúncia para exibição amigável 
  String formatarTempo(DateTime? data) {
    if (data == null) return '';
    final diff = DateTime.now().difference(data);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    return 'há ${diff.inDays}d';
  }
}