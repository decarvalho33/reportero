import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço de autenticação institucional (Épico 4).
///
/// Encapsula o Supabase Auth (GoTrue) para cadastro, login, logout, recuperação
/// de senha e reenvio de confirmação, restringindo o acesso a emails da UNICAMP.
///
/// A validação de entrada fica em métodos estáticos **puros** (sem rede), o que
/// os torna testáveis isoladamente e permite aplicar técnicas de projeto de
/// teste (classes de equivalência, valor limite, tabela de decisão). Os métodos
/// que conversam com o Supabase são assíncronos e tratados por integração.
class AuthService {
  /// Comprimento mínimo da senha, alinhado ao padrão do Supabase Auth.
  static const int senhaMinima = 6;

  SupabaseClient get _supabase => Supabase.instance.client;

  // ----------------------------------------------------------------------------
  // Validadores puros (entrada -> resultado, sem efeitos colaterais)
  // ----------------------------------------------------------------------------

  /// Verifica se o email pertence ao domínio institucional da UNICAMP, aceitando
  /// qualquer subdomínio de `unicamp.br` (ex.: `dac.unicamp.br`, `ic.unicamp.br`)
  /// e o domínio raiz `unicamp.br`. A comparação ignora maiúsculas e espaços.
  static bool emailInstitucionalValido(String email) {
    final partes = email.trim().toLowerCase().split('@');
    // Precisa ter exatamente um "@" e algo antes dele.
    if (partes.length != 2 || partes[0].isEmpty) return false;

    final dominio = partes[1];
    return dominio == 'unicamp.br' || dominio.endsWith('.unicamp.br');
  }

  /// Verifica se a senha atende ao comprimento mínimo exigido.
  static bool senhaValida(String senha) => senha.length >= senhaMinima;

  /// Valida os dados de cadastro e retorna a mensagem de erro do primeiro
  /// problema encontrado, ou `null` quando tudo está válido.
  ///
  /// A ordem das verificações (email, senha, nome) define a tabela de decisão do
  /// cadastro e mantém as mensagens previsíveis.
  static String? validarCadastro({
    required String nome,
    required String email,
    required String senha,
  }) {
    if (!emailInstitucionalValido(email)) {
      return 'Use um email institucional da UNICAMP (@unicamp.br).';
    }
    if (!senhaValida(senha)) {
      return 'A senha deve ter ao menos $senhaMinima caracteres.';
    }
    if (nome.trim().isEmpty) {
      return 'Informe seu nome.';
    }
    return null;
  }

  // ----------------------------------------------------------------------------
  // Estado da sessão
  // ----------------------------------------------------------------------------

  /// Usuário logado no momento, ou `null` se ninguém estiver autenticado.
  User? get usuarioAtual => _supabase.auth.currentUser;

  /// Indica se há um usuário autenticado agora.
  bool get estaLogado => usuarioAtual != null;

  /// Nome do usuário logado (guardado no user_metadata durante o cadastro).
  String? get nomeUsuario => usuarioAtual?.userMetadata?['nome'] as String?;

  /// Emite um evento a cada mudança de sessão (login, logout, refresh de token),
  /// permitindo que a interface reaja sem ficar consultando o estado.
  Stream<AuthState> get mudancasDeSessao => _supabase.auth.onAuthStateChange;

  // ----------------------------------------------------------------------------
  // Operações de autenticação
  // ----------------------------------------------------------------------------

  /// Cadastra um novo usuário (US 4.1). Valida os dados antes de chamar o
  /// Supabase e envia o nome no metadata, de onde o trigger monta o perfil.
  ///
  /// Com a confirmação de email habilitada (US 4.2), o Supabase envia o email de
  /// verificação automaticamente e a conta só é liberada após a confirmação.
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final erro = validarCadastro(nome: nome, email: email, senha: senha);
    if (erro != null) {
      throw ArgumentError(erro);
    }
    try {
      await _supabase.auth.signUp(
        email: email.trim(),
        password: senha,
        data: {'nome': nome.trim()},
      );
    } on AuthException catch (e) {
      throw Exception(_mensagemErro(e));
    }
  }

  /// Autentica com email e senha (US 4.3).
  Future<void> entrar({required String email, required String senha}) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: senha,
      );
    } on AuthException catch (e) {
      throw Exception(_mensagemErro(e));
    }
  }

  /// Encerra a sessão do usuário atual (US 4.5).
  Future<void> sair() => _supabase.auth.signOut();

  /// Envia o email de recuperação de senha (US 4.4).
  Future<void> recuperarSenha(String email) async {
    if (!emailInstitucionalValido(email)) {
      throw ArgumentError('Use um email institucional da UNICAMP (@unicamp.br).');
    }
    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw Exception(_mensagemErro(e));
    }
  }

  /// Define a nova senha após o usuário clicar no link de recuperação (Deep Link).
  Future<void> atualizarSenha(String novaSenha) async {
    if (!senhaValida(novaSenha)) {
      throw ArgumentError('A senha deve ter ao menos $senhaMinima caracteres.');
    }
    try {
      await _supabase.auth.updateUser(UserAttributes(password: novaSenha));
    } on AuthException catch (e) {
      throw Exception(_mensagemErro(e));
    }
  }

  /// Troca a senha do usuário já autenticado (Épico 4 — trocar senha).
  ///
  /// Diferente de [atualizarSenha] (usada após o link de recuperação, onde o
  /// próprio email já prova a identidade), aqui a sessão já está aberta.
  /// Por isso reautentica com a senha atual via [entrar] antes de aplicar a
  /// nova, evitando que alguém com o dispositivo destravado troque a senha
  /// sem conhecer a atual. A nova senha passa pela mesma validação de
  /// [senhaValida] usada em todo o resto do fluxo de autenticação.
  Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    if (!senhaValida(novaSenha)) {
      throw ArgumentError('A senha deve ter ao menos $senhaMinima caracteres.');
    }
    final email = usuarioAtual?.email;
    if (email == null) {
      throw Exception('Nenhum usuário autenticado.');
    }
    await entrar(email: email, senha: senhaAtual);
    await atualizarSenha(novaSenha);
  }

  /// Reenvia o email de confirmação de cadastro (apoio à US 4.2).
  Future<void> reenviarConfirmacao(String email) async {
    if (!emailInstitucionalValido(email)) {
      throw ArgumentError('Use um email institucional da UNICAMP (@unicamp.br).');
    }
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email.trim());
    } on AuthException catch (e) {
      throw Exception(_mensagemErro(e));
    }
  }

  /// Traduz os erros mais comuns do Supabase Auth para mensagens em português,
  /// caindo para a mensagem original quando o código não é reconhecido.
  String _mensagemErro(AuthException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return 'Email ou senha incorretos.';
      case 'email_not_confirmed':
        return 'Confirme seu email antes de entrar.';
      case 'user_already_exists':
      case 'email_exists':
        return 'Já existe uma conta com esse email.';
      case 'weak_password':
        return 'A senha deve ter ao menos $senhaMinima caracteres.';
      case 'over_email_send_rate_limit':
        return 'Muitas tentativas. Aguarde um pouco antes de tentar de novo.';
      default:
        return e.message;
    }
  }
}
