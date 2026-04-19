import '../models/denuncia.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DenunciaService {
  final _supabase = Supabase.instance.client;

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