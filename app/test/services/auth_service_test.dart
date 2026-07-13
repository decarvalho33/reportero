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
}
