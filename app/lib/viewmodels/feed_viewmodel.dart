import 'package:flutter/material.dart';
import '../models/denuncia.dart';
import '../services/denuncia_service.dart';

class FeedViewModel extends ChangeNotifier {
  
  final _service = DenunciaService();
  
  List<Denuncia> _denuncias = [];
  bool _isLoading = false;
  String? _erro;

  List<Denuncia> get denuncias => _denuncias;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  // Mock data — João substituirá pela chamada real ao Supabase
  Future<void> carregarDenuncias() async {
    _isLoading = true;
    _erro = null;
    notifyListeners();

    try {
      _denuncias = await _service.obtenerDenuncias();
    } catch (e) {
      _erro = "Erro ao carregar denúncias";
      debugPrint("Erro: $e");
    }

    _isLoading = false;
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
