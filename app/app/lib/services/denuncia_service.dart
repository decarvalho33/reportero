import 'dart:typed_data';
import '../models/denuncia.dart';
import 'dispositivo_service.dart';
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

  final DispositivoService _dispositivo = DispositivoService();

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
  ///
  /// O autor_id é preenchido com o id do usuário autenticado no momento do
  /// envio (Épico 5). Sem sessão ativa, a denúncia é enviada sem dono (nulo).
  Future<void> enviarDenuncia(Denuncia denuncia) async {
    _validarCoordenadas(denuncia.latitude, denuncia.longitude);
    final dados = denuncia.toJson();
    final autorId = _supabase.auth.currentUser?.id;
    if (autorId != null) {
      dados['autor_id'] = autorId;
    }
    await _supabase.from('denuncias').insert(dados);
  }

  /// Obtém todas as denúncias do banco de dados, ordenadas pela data de criação em ordem decrescente.
  ///
  /// Cada denúncia já vem com a contagem de apoios (`totalApoios`) e a marcação
  /// se o dispositivo atual a apoiou (`jaApoiei`). São usadas apenas duas
  /// consultas no total (contagens agregadas + apoios do usuário), evitando N+1.
  Future<List<Denuncia>> obtenerDenuncias() async {
    final response = await _supabase
        .from('denuncias')
        .select('*, apoios(count)')
        .order('created_at', ascending: false);

    final idsApoiados = await _obterIdsApoiadosPeloUsuario();

    return (response as List).map((json) {
      final denuncia = Denuncia.fromJson(json);
      return denuncia.copyWith(jaApoiei: idsApoiados.contains(denuncia.id));
    }).toList();
  }

  /// Atualiza uma denúncia existente (US 5.6/5.7). Só o autor pode editar —
  /// esta checagem é só uma barreira rápida de UX; quem garante de verdade é
  /// a RLS (`auth.uid() = autor_id`) da tabela `denuncias`.
  Future<void> editarDenuncia(Denuncia denuncia) async {
    _garantirAutoria(denuncia);
    _validarCoordenadas(denuncia.latitude, denuncia.longitude);
    await _supabase.from('denuncias').update(denuncia.toJson()).eq('id', denuncia.id!);
  }

  /// Exclui uma denúncia existente (US 5.6/5.7). Mesma checagem de autoria
  /// de [editarDenuncia], reforçada pela RLS no banco.
  Future<void> excluirDenuncia(Denuncia denuncia) async {
    _garantirAutoria(denuncia);
    await _supabase.from('denuncias').delete().eq('id', denuncia.id!);
  }

  /// Garante que a denúncia pertence ao usuário autenticado antes de editar
  /// ou excluir.
  void _garantirAutoria(Denuncia denuncia) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || denuncia.autorId == null || denuncia.autorId != userId) {
      throw Exception('Você só pode editar ou excluir suas próprias denúncias.');
    }
  }

  /// Obtém apenas as denúncias registradas pelo usuário autenticado (US 5.3),
  /// ordenadas pela data de criação em ordem decrescente. Sem sessão ativa,
  /// retorna lista vazia.
  Future<List<Denuncia>> obterMinhasDenuncias() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('denuncias')
        .select()
        .eq('autor_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Denuncia.fromJson(json)).toList();
  }

  /// Registra o apoio (upvote) do dispositivo atual em uma denúncia.
  ///
  /// É idempotente: se o apoio já existir, a violação de unicidade é ignorada,
  /// garantindo no máximo um apoio por dispositivo por denúncia.
  Future<void> apoiar(String denunciaId) async {
    final usuarioId = await _dispositivo.obterId();
    try {
      await _supabase.from('apoios').insert({
        'denuncia_id': denunciaId,
        'usuario_id': usuarioId,
      });
    } on PostgrestException catch (e) {
      // 23505 = unique_violation: apoio já registrado, tratado como sucesso.
      if (e.code != '23505') rethrow;
    }
  }

  /// Remove o apoio do dispositivo atual de uma denúncia.
  Future<void> removerApoio(String denunciaId) async {
    final usuarioId = await _dispositivo.obterId();
    await _supabase
        .from('apoios')
        .delete()
        .eq('denuncia_id', denunciaId)
        .eq('usuario_id', usuarioId);
  }

  /// Retorna o conjunto de ids de denúncias já apoiadas pelo dispositivo atual.
  Future<Set<String>> _obterIdsApoiadosPeloUsuario() async {
    final usuarioId = await _dispositivo.obterId();
    final apoios = await _supabase
        .from('apoios')
        .select('denuncia_id')
        .eq('usuario_id', usuarioId);

    return (apoios as List)
        .map((linha) => linha['denuncia_id'] as String)
        .toSet();
  }

  // ==========================================
  // FUNÇÕES ADMINISTRATIVAS (ÉPICO 6)
  // Protegidas por RLS no Supabase. Lançarão erro se o usuário não for admin.
  // ==========================================

  /// (US 6.1) Verifica se o usuário autenticado atualmente é um administrador.
  Future<bool> verificarPrivilegioAdmin() async {
    final user = _supabase.auth.currentUser;

    print("Usuario: ${user?.id}");

    if (user == null) return false;

    try {
      final response = await _supabase
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .single();

      print("Respuesta: $response");   

      return response['is_admin'] == true;
    } catch (e) {
      print("ERROR: $e");
      // Se houver erro ou o perfil não existir,
      // considera que o usuário não é administrador.
      return false;
    }
  }

  /// (US 6.4) Atualiza o status de uma denúncia.
  Future<void> atualizarStatus(String denunciaId, StatusDenuncia novoStatus) async {
    await _supabase
        .from('denuncias')
        .update({'status': novoStatus.label})
        .eq('id', denunciaId);
  }

  /// (US 6.6) Atribui um setor responsável à denúncia.
  Future<void> atribuirSetor(String denunciaId, String setor) async {
    await _supabase
        .from('denuncias')
        .update({'setor_responsavel': setor})
        .eq('id', denunciaId);
  }

  /// (US 6.5) Salva uma resposta oficial para o usuário.
  Future<void> responderDenuncia(String denunciaId, String resposta) async {
    await _supabase
        .from('denuncias')
        .update({'resposta_admin': resposta})
        .eq('id', denunciaId);
  }

  /// (US 6.9) Concede privilégios de administrador a outro usuário.
  Future<void> promoverParaAdmin(String perfilId) async {
    await _supabase
        .from('profiles')
        .update({'is_admin': true})
        .eq('id', perfilId);
  }

  /// (US 6.9) Lista todos los usuários cadastrados.
  Future<List<Map<String, dynamic>>> listarPerfis() async {
    final response = await _supabase
        .from('profiles')
        .select('id, nome, is_admin')
        .order('nome');

    return List<Map<String, dynamic>>.from(response);
  }

  /// (US 6.9) Revoga privilégios de administrador.
  Future<void> removerAdmin(String perfilId) async {
    await _supabase
        .from('profiles')
        .update({'is_admin': false})
        .eq('id', perfilId);
  }
}