import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/auth_service.dart';

void main() {
  // Particionamento em classes de equivalência. Condições de entrada:
  // ter um único "@", parte local não vazia e domínio institucional
  // (unicamp.br ou subdomínio). Um caso por classe, e cada caso inválido
  // viola uma única condição para deixar claro qual critério rejeitou.
  group('emailInstitucionalValido', () {
    // Classes válidas
    test('aceita email do domínio raiz unicamp.br', () {
      expect(AuthService.emailInstitucionalValido('a195033@unicamp.br'), isTrue);
    });

    test('aceita email de subdomínio (dac.unicamp.br)', () {
      expect(
        AuthService.emailInstitucionalValido('a195033@dac.unicamp.br'),
        isTrue,
      );
    });

    test('aceita email de subdomínio aninhado (alunos.ic.unicamp.br)', () {
      expect(
        AuthService.emailInstitucionalValido('maria@alunos.ic.unicamp.br'),
        isTrue,
      );
    });

    test('ignora maiúsculas e espaços nas bordas', () {
      expect(
        AuthService.emailInstitucionalValido('  A195033@DAC.UNICAMP.BR  '),
        isTrue,
      );
    });

    // Classe inválida: estrutura do email
    test('rejeita email sem "@"', () {
      expect(
        AuthService.emailInstitucionalValido('a195033unicamp.br'),
        isFalse,
      );
    });

    test('rejeita email com mais de um "@"', () {
      expect(
        AuthService.emailInstitucionalValido('ana@dac@unicamp.br'),
        isFalse,
      );
    });

    test('rejeita string vazia', () {
      expect(AuthService.emailInstitucionalValido(''), isFalse);
    });

    test('rejeita email sem nada antes do "@"', () {
      expect(AuthService.emailInstitucionalValido('@unicamp.br'), isFalse);
    });

    // Classe inválida: domínio não institucional. "fakeunicamp.br" e
    // "unicamp.br.evil.com" pegam implementações com endsWith sem o ponto
    // ou com contains.
    test('rejeita domínio externo (gmail.com)', () {
      expect(AuthService.emailInstitucionalValido('ana@gmail.com'), isFalse);
    });

    test('rejeita domínio que apenas termina com "unicamp.br"', () {
      expect(
        AuthService.emailInstitucionalValido('ana@fakeunicamp.br'),
        isFalse,
      );
    });

    test('rejeita unicamp.br embutido em outro domínio', () {
      expect(
        AuthService.emailInstitucionalValido('ana@unicamp.br.evil.com'),
        isFalse,
      );
    });

    // O validador é aplicado antes de qualquer chamada de rede, então os
    // métodos assíncronos falham com ArgumentError sem Supabase inicializado.
    test('recuperarSenha rejeita email fora do domínio institucional', () async {
      await expectLater(
        AuthService().recuperarSenha('ana@gmail.com'),
        throwsArgumentError,
      );
    });

    test('reenviarConfirmacao rejeita email fora do domínio institucional',
        () async {
      await expectLater(
        AuthService().reenviarConfirmacao('ana@gmail.com'),
        throwsArgumentError,
      );
    });
  });

  // Análise de valor limite sobre senhaMinima (6): testa o limite e os
  // vizinhos imediatos (5 e 7), que separam >= 6 de > 6 e de == 6,
  // além do extremo vazio.
  group('senhaValida', () {
    test('rejeita senha com 5 caracteres (logo abaixo do limite)', () {
      expect(AuthService.senhaValida('12345'), isFalse);
    });

    test('aceita senha com exatamente 6 caracteres (limite)', () {
      expect(AuthService.senhaValida('123456'), isTrue);
    });

    test('aceita senha com 7 caracteres (logo acima do limite)', () {
      expect(AuthService.senhaValida('1234567'), isTrue);
    });

    test('rejeita senha vazia', () {
      expect(AuthService.senhaValida(''), isFalse);
    });

    test('atualizarSenha rejeita senha abaixo do limite', () async {
      await expectLater(
        AuthService().atualizarSenha('12345'),
        throwsArgumentError,
      );
    });

    // trocarSenha valida a nova senha antes de tentar reautenticar (sem
    // Supabase inicializado, a validação precisa ocorrer antes de qualquer
    // chamada de rede — mesmo raciocínio do teste de cadastrar/atualizarSenha
    // acima).
    test('trocarSenha rejeita nova senha abaixo do limite, sem tentar rede', () async {
      await expectLater(
        AuthService().trocarSenha(senhaAtual: 'senhaAntiga123', novaSenha: '12345'),
        throwsArgumentError,
      );
    });
  });

  // Tabela de decisão. Condições: email válido, senha válida, nome
  // preenchido. A verificação segue essa ordem e para no primeiro erro,
  // o que reduz a tabela a 4 regras:
  //   R1: email inválido               -> mensagem de email
  //   R2: email ok, senha inválida     -> mensagem de senha
  //   R3: email e senha ok, nome vazio -> mensagem de nome
  //   R4: tudo válido                  -> null
  group('validarCadastro', () {
    const msgEmail = 'Use um email institucional da UNICAMP (@unicamp.br).';
    const msgSenha = 'A senha deve ter ao menos 6 caracteres.';
    const msgNome = 'Informe seu nome.';

    // Senha e nome também inválidos: garante que a mensagem de email tem
    // precedência sobre as demais.
    test('R1: email inválido retorna a mensagem de email', () {
      expect(
        AuthService.validarCadastro(
          nome: '',
          email: 'ana@gmail.com',
          senha: '123',
        ),
        equals(msgEmail),
      );
    });

    // Senha no valor limite inválido (5) e nome vazio: garante a
    // precedência da senha sobre o nome.
    test('R2: senha curta retorna a mensagem de senha', () {
      expect(
        AuthService.validarCadastro(
          nome: '',
          email: 'ana@unicamp.br',
          senha: '12345',
        ),
        equals(msgSenha),
      );
    });

    test('R3: nome vazio retorna a mensagem de nome', () {
      expect(
        AuthService.validarCadastro(
          nome: '',
          email: 'ana@unicamp.br',
          senha: '123456',
        ),
        equals(msgNome),
      );
    });

    test('R3: nome só com espaços conta como vazio', () {
      expect(
        AuthService.validarCadastro(
          nome: '   ',
          email: 'ana@unicamp.br',
          senha: '123456',
        ),
        equals(msgNome),
      );
    });

    test('R4: dados válidos retornam null', () {
      expect(
        AuthService.validarCadastro(
          nome: 'Ana',
          email: 'ana@dac.unicamp.br',
          senha: '123456',
        ),
        isNull,
      );
    });

    test('cadastrar barra dados inválidos antes de chamar a rede', () async {
      await expectLater(
        AuthService().cadastrar(
          nome: '',
          email: 'ana@gmail.com',
          senha: '123',
        ),
        throwsArgumentError,
      );
    });
  });
}
