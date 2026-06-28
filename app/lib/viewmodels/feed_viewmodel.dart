import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class FeedViewModel extends ChangeNotifier {
  final _service = DenunciaService();

  List<Denuncia> _allDenuncias = []; // Cache completo vindo do Supabase
  List<Denuncia> _denunciasFiltradas = []; // Lista exibida na tela

  bool _isLoading = false;
  String? _erro;
  bool _ordenacaoMaisRecente = true; // Controle de estado da ordenação
  String _filtroTexto = "";
  String? _filtroCategoria; // null = todas as categorias

  List<Denuncia> get denuncias => _denunciasFiltradas;
  bool get isLoading => _isLoading;
  String? get erro => _erro;
  bool get ordenacaoMaisRecente => _ordenacaoMaisRecente;
  String? get filtroCategoria => _filtroCategoria;

  Future<void> carregarDenuncias() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      // 1. Busca os dados reais do banco que o João configurou
      _allDenuncias = await _service.obtenerDenuncias();

      // 2. 🔥 INJEÇÃO DE TESTE: Criamos uma denúncia falsa com foto e coordenadas
      // para garantir que seu frontend funciona mesmo se o banco só tiver dados velhos.
      _allDenuncias.insert(0, Denuncia(
        id: "teste_mock_axel",
        titulo: "Lâmpada Quebrada na Unicamp",
        descricao: "A lâmpada perto do bandejão está piscando faz duas semanas. Perigoso andar por aqui à noite.",
        localizacao: "Perto do Restaurante Universitário",
        autor: "Axel (Teste Frontend)",
        latitude: -22.8184,
        longitude: -47.0647,
        fotoUrl: "https://picsum.photos/400/200", // Foto de teste aleatória
        createdAt: DateTime.now(),
      ));

      // 3. Organiza a lista aplicando a busca e ordenação atuais
      _aplicarFiltrosEOrdenacao();
    } catch (e) {
      _erro = "Erro ao carregar denúncias";
      debugPrint("Erro: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Alterna o estado de ordenação (Mais recentes vs Antigas) - História 2.3
  void alternarOrdenacao() {
    _ordenacaoMaisRecente = !_ordenacaoMaisRecente;
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  // Define o termo de busca para a filtragem - História 2.4
  void filtrarPorTexto(String texto) {
    _filtroTexto = texto.toLowerCase();
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  // Define a categoria ativa; null remove o filtro de categoria - História 2.4
  void filtrarPorCategoria(String? categoria) {
    _filtroCategoria = categoria;
    _aplicarFiltrosEOrdenacao();
    notifyListeners();
  }

  // Lógica interna para processar os dados em memória
  void _aplicarFiltrosEOrdenacao() {
    _denunciasFiltradas = _allDenuncias.where((d) {
      final passaTexto = _filtroTexto.isEmpty ||
          d.titulo.toLowerCase().contains(_filtroTexto) ||
          d.descricao.toLowerCase().contains(_filtroTexto) ||
          d.localizacao.toLowerCase().contains(_filtroTexto);
      final passaCategoria =
          _filtroCategoria == null || d.categoria == _filtroCategoria;
      return passaTexto && passaCategoria;
    }).toList();

    // Aplicar Ordenação Cronológica
    if (_ordenacaoMaisRecente) {
      _denunciasFiltradas.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
    } else {
      _denunciasFiltradas.sort((a, b) => (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now()));
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