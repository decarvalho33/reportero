import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/denuncia.dart';

/// Serviço responsável por persistir localmente qual foi o último status
/// visto pelo usuário para cada denúncia (US 5.5).
///
/// Guarda um mapa denunciaId -> label do status numa única chave do
/// SharedPreferences, permitindo detectar no cliente quando o status de uma
/// denúncia mudou desde a última vez que o usuário a visualizou — sem
/// depender de tabela ou trigger no banco.
class StatusVistoService {
  /// Chave usada para guardar o mapa serializado no armazenamento local.
  static const String _chave = 'reportero_status_vistos';

  /// Retorna o mapa denunciaId -> label do último status visto. Vazio caso
  /// nada tenha sido salvo ainda.
  Future<Map<String, String>> obterStatusVistos() async {
    final prefs = await SharedPreferences.getInstance();
    final bruto = prefs.getString(_chave);
    if (bruto == null) return {};

    final decodificado = jsonDecode(bruto) as Map<String, dynamic>;
    return decodificado.map((chave, valor) => MapEntry(chave, valor as String));
  }

  /// Marca [status] como o último status visto da denúncia [denunciaId],
  /// preservando o status visto salvo das demais denúncias.
  Future<void> marcarComoVisto(String denunciaId, StatusDenuncia status) async {
    final prefs = await SharedPreferences.getInstance();
    final atual = await obterStatusVistos();
    atual[denunciaId] = status.label;
    await prefs.setString(_chave, jsonEncode(atual));
  }
}
