import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço responsável pelos dados de perfil do usuário (tabela `profiles`) — Épico 5.
///
/// Complementa o [AuthService]: enquanto aquele cuida da sessão (login,
/// cadastro, senha), este cuida dos dados de aplicação do usuário
/// autenticado (hoje, o nome e a foto de perfil).
class PerfilService {
  /// Comprimento mínimo exigido para o nome (US 5.2).
  static const int nomeMinimo = 2;

  static bool nomeValido(String nome) => nome.trim().length >= nomeMinimo;

  /// Extensões de imagem aceitas para a foto de perfil (US 5.1).
  static const List<String> extensoesFotoValidas = ['.jpg', '.jpeg', '.png', '.webp'];

  static bool fotoValida(String nomeArquivo) {
    final nomeLower = nomeArquivo.toLowerCase();
    return extensoesFotoValidas.any((ext) => nomeLower.endsWith(ext));
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  /// Busca o nome salvo no perfil do usuário. Retorna `null` se não houver
  /// linha (não deve acontecer, já que o trigger `handle_new_user` cria o
  /// perfil no cadastro).
  Future<String?> obterNome(String userId) async {
    final resposta = await _supabase
        .from('profiles')
        .select('nome')
        .eq('id', userId)
        .maybeSingle();
    return resposta?['nome'] as String?;
  }

  /// Atualiza o nome do usuário autenticado (US 5.2). A RLS de `profiles`
  /// garante que só o próprio usuário (auth.uid() = id) pode gravar aqui.
  Future<void> atualizarNome({required String userId, required String nome}) async {
    if (!nomeValido(nome)) {
      throw ArgumentError('O nome deve ter ao menos $nomeMinimo caracteres.');
    }
    await _supabase
        .from('profiles')
        .update({'nome': nome.trim()})
        .eq('id', userId);
  }

  /// Busca a URL da foto de perfil salva. Retorna `null` se não houver.
  Future<String?> obterFotoPerfil(String userId) async {
    final resposta = await _supabase
        .from('profiles')
        .select('foto_perfil_url')
        .eq('id', userId)
        .maybeSingle();
    return resposta?['foto_perfil_url'] as String?;
  }

  /// Faz o upload da foto de perfil para o Supabase Storage e retorna a URL
  /// pública da foto (US 5.1).
  ///
  /// Reaproveita o bucket `evidencias` (mesmo do Épico 1), sob o prefixo
  /// `perfil/`, para não depender da criação manual de um bucket novo.
  Future<String?> subirFotoPerfil(Uint8List fotoBytes, String nomeArquivo) async {
    if (!fotoValida(nomeArquivo)) {
      throw ArgumentError('Formato de imagem não suportado. Use JPG, PNG ou WEBP.');
    }
    try {
      final String caminhoBucket = 'perfil/${DateTime.now().millisecondsSinceEpoch}_$nomeArquivo';
      await _supabase.storage.from('evidencias').uploadBinary(
            caminhoBucket,
            fotoBytes,
            fileOptions: const FileOptions(upsert: true),
          );
      return _supabase.storage.from('evidencias').getPublicUrl(caminhoBucket);
    } catch (e) {
      throw Exception('Erro ao subir a foto de perfil: $e');
    }
  }

  /// Persiste a URL da foto de perfil do usuário autenticado (US 5.1).
  Future<void> atualizarFotoPerfil({required String userId, required String fotoUrl}) async {
    await _supabase
        .from('profiles')
        .update({'foto_perfil_url': fotoUrl})
        .eq('id', userId);
  }
}
