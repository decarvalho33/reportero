import '../models/denuncia.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Este serviço será responsável por toda a comunicação com o backend (Supabase) relacionada às denúncias.
class DenunciaService {
  final _supabase = Supabase.instance.client;
  Future<void> enviarDenuncia(Denuncia denuncia) async {
    // Enviar a denúncia para o Supabase
    try {
      await _supabase.from('denuncias').insert(denuncia.toJson());
      print("Denúncia enviada com sucesso!"); // Log de sucesso (teste)
    } catch (e) {
      print("Erro ao enviar denúncia: $e"); // Log de erro (teste)
      rethrow;
    }
  }

  Future<List<Denuncia>> obtenerDenuncias() async {
    try {
      final response = await _supabase
          .from('denuncias')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Denuncia.fromJson(json))
          .toList();
    } catch (e) {
      print("Erro ao buscar denúncias: $e");
      rethrow;
    }
  }
}