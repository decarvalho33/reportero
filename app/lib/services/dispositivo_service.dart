import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável por fornecer um identificador anônimo e estável do
/// dispositivo (device id), persistido localmente via SharedPreferences.
///
/// Esse id vincula os apoios (upvotes) a um "usuário" sem exigir login,
/// preservando o anonimato — o feed nunca expõe quem apoiou. Por ser por
/// dispositivo, não identifica a pessoa e não sobrevive à reinstalação do app.
class DispositivoService {
  /// Chave usada para guardar o id no armazenamento local.
  static const String _chave = 'reportero_device_id';

  // 1. Instância estática privada (mesmo padrão Singleton de DenunciaService)
  static final DispositivoService _instance = DispositivoService._internal();

  // 2. Construtor privado (evita instanciar de fora)
  DispositivoService._internal();

  // 3. Factory constructor que retorna sempre a mesma instância
  factory DispositivoService() {
    return _instance;
  }

  /// Cache em memória para evitar ler o disco a cada chamada.
  String? _cacheId;

  /// Retorna o id do dispositivo, gerando e persistindo um novo caso ainda não exista.
  Future<String> obterId() async {
    if (_cacheId != null) return _cacheId!;

    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_chave);

    if (id == null) {
      id = _gerarUuidV4();
      await prefs.setString(_chave, id);
    }

    _cacheId = id;
    return id;
  }

  /// Gera um UUID v4 a partir de uma fonte aleatória segura, sem dependências externas.
  String _gerarUuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // versão 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // variante 10xx
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
