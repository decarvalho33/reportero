import 'dart:typed_data';
import '../models/denuncia.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

///Serviço responsável por gerenciar as operações relacionadas às denúncias, incluindo validação de coordenadas, envio de denúncias e upload de fotos para o Supabase Storage.
class DenunciaService {
  // 1. Instancia estática privada
  static final DenunciaService _instance = DenunciaService._internal();

  // 2. Construtor privado (evita instanciar de fora)
  DenunciaService._internal();

  // 3. Factory constructor que retorna sempre a mesma instância
  factory DenunciaService() {
    return _instance;
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Valida as coordenadas de latitude e longitude fornecidas. Lança um erro se as coordenadas forem inválidas.
  void _validarCoordenadas(double? latitude, double? longitude) {
    if (latitude == null && longitude == null) return;

    if (latitude == null || longitude == null) {
      throw ArgumentError('Para registrar uma denúncia com coordenadas, ambos latitude e longitude devem ser fornecidos.');
    }

    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitude fora do limite permitido. Deve estar entre -90 e 90.');
    }

    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitude fora do limite permitido. Deve estar entre -180 e 180.');
    }
  }

  /// Faz o upload de uma foto para o Supabase Storage e retorna a URL pública da foto.
  Future<String?> subirFoto(Uint8List fotoBytes, String nomeArquivo) async {
    try { 
      final String caminhoBucket = 'fotos/${DateTime.now().millisecondsSinceEpoch}_$nomeArquivo';
      await _supabase.storage.from('evidencias').uploadBinary(caminhoBucket, fotoBytes, fileOptions: const FileOptions(upsert: true));
      final String urlPublica = _supabase.storage.from('evidencias').getPublicUrl(caminhoBucket);
      return urlPublica;
    } catch (e) {
      throw Exception('Erro ao subir a foto: $e');
    }
  }

  /// Envia uma denúncia para o banco de dados, após validar as coordenadas.
  Future<void> enviarDenuncia(Denuncia denuncia) async {
    _validarCoordenadas(denuncia.latitude, denuncia.longitude);
    await _supabase.from('denuncias').insert(denuncia.toJson());
  }

  /// Obtém todas as denúncias do banco de dados, ordenadas pela data de criação em ordem decrescente.
  Future<List<Denuncia>> obtenerDenuncias() async {
    final response = await _supabase
        .from('denuncias')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Denuncia.fromJson(json))
        .toList();
  }
}