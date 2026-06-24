import 'dart:typed_data';
import '../models/denuncia.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/* Serviço para gerenciar denúncias */
class DenunciaService {
  SupabaseClient get _supabase => Supabase.instance.client;

  /* Valida as coordenadas geográficas */
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

  /* Envia uma denúncia para o banco de dados */
  /* Subir foto ao Supabase Storage */
  Future<String?> subirFoto(Uint8List fotoBytes, String nomeArquivo) async {
    try { 
      final String caminhoBucket = 'fotos/${DateTime}.now().millisecondsSinceEpoch}_$nomeArquivo';
      await _supabase.storage.from('evidencias').uploadBinary(caminhoBucket, fotoBytes, fileOptions: const FileOptions(upsert: true));
      final String urlPublica = _supabase.storage.from('evidencias').getPublicUrl(caminhoBucket);
      return urlPublica;
    } catch (e) {
      throw Exception('Erro ao subir a foto: $e');
    }
  }

  Future<void> enviarDenuncia(Denuncia denuncia) async {
    _validarCoordenadas(denuncia.latitude, denuncia.longitude);
    await _supabase.from('denuncias').insert(denuncia.toJson());
  }

  /* Obtém todas as denúncias do banco de dados */
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