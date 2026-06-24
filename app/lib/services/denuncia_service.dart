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