import '../models/denuncia.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DenunciaService {
  final _supabase = Supabase.instance.client;

 
  Future<void> enviarDenuncia(Denuncia denuncia) async {
    try {
      await _supabase.from('denuncias').insert(denuncia.toJson());

      print("BACKEND LOG");
      print("Denúncia enviada com sucesso!");
    } catch (e) {
      print("Erro ao enviar denúncia: $e");
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