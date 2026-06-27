import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class FeedViewModel extends ChangeNotifier {
  final _service = DenunciaService();
  
  List<Denuncia> _allDenuncias = []; /// Cache completo vindo do Supabase
  List<Denuncia> _denunciasFiltradas = []; /// Lista exibida na tela
  
  bool _isLoading = false;
  String? _erro;
  bool _ordenacaoMaisRecente = true; /// Controle de estado da ordenação
  String _filtroTexto = ""; /// Estado do filtro de busca

  List<Denuncia> get denuncias => _denunciasFiltradas;
  bool get isLoading => _isLoading;
  String? get erro => _erro; 
  bool get ordenacaoMaisRecente => _ordenacaoMaisRecente;

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
  void alternarOrdenacao() {
    _ordenacaoMaisRecente = !_ordenacaoMaisRecente;
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  /// Define o termo de busca para a filtragem 
  void filtrarPorTexto(String texto) {
    _filtroTexto = texto.toLowerCase();
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
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

    /// Aplicar Ordenação Cronológica
    if (_ordenacaoMaisRecente) {
      _denunciasFiltradas.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    } else {
      _denunciasFiltradas.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
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