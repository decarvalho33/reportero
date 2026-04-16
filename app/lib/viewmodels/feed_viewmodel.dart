import 'package:flutter/material.dart';
import '../models/denuncia.dart';

class FeedViewModel extends ChangeNotifier {
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

    await Future.delayed(const Duration(milliseconds: 600)); // simula latência

    _denuncias = [
      Denuncia(
        id: '1',
        titulo: 'Poste caído no IC-3',
        descricao: 'Fio exposto na calçada próximo à entrada do instituto. Risco para pedestres.',
        localizacao: 'Instituto de Computação',
        autor: 'Anônimo',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Denuncia(
        id: '2',
        titulo: 'Banco quebrado no CB',
        descricao: 'Banco da área de convivência com estrutura comprometida, pode machucar alguém.',
        localizacao: 'Centro de Biologia',
        autor: 'Maria S.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Denuncia(
        id: '3',
        titulo: 'Lâmpada queimada no banheiro',
        descricao: 'Banheiro masculino do 2º andar completamente sem luz há três dias.',
        localizacao: 'Biblioteca Central',
        autor: 'Anônimo',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

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
