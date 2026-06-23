import 'dart:typed_data';
import '../models/denuncia.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DenunciaService {
  SupabaseClient get _supabase => Supabase.instance.client;

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
    await _supabase.from('denuncias').insert(denuncia.toJson());
  }

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