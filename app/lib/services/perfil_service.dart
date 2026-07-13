import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço responsável pelos dados de perfil do usuário (tabela `profiles`) — Épico 5.
///
/// Complementa o [AuthService]: enquanto aquele cuida da sessão (login,
/// cadastro, senha), este cuida dos dados de aplicação do usuário
/// autenticado (hoje, o nome).
class PerfilService {
  /// Comprimento mínimo exigido para o nome (US 5.2).
  static const int nomeMinimo = 2;

  static bool nomeValido(String nome) => nome.trim().length >= nomeMinimo;

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
}
