import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/perfil_service.dart';

void main() {
  group('PerfilService.fotoValida', () {
    test('aceita extensões de imagem comuns', () {
      expect(PerfilService.fotoValida('foto.jpg'), isTrue);
      expect(PerfilService.fotoValida('foto.JPEG'), isTrue);
      expect(PerfilService.fotoValida('avatar.png'), isTrue);
      expect(PerfilService.fotoValida('avatar.webp'), isTrue);
    });

    test('rejeita extensões não suportadas', () {
      expect(PerfilService.fotoValida('documento.pdf'), isFalse);
      expect(PerfilService.fotoValida('foto.gif'), isFalse);
      expect(PerfilService.fotoValida('semextensao'), isFalse);
    });
  });

  group('PerfilService.subirFotoPerfil', () {
    test('lança ArgumentError para formato de imagem inválido, sem tentar rede', () {
      final service = PerfilService();

      expect(
        () => service.subirFotoPerfil(Uint8List(0), 'arquivo.pdf'),
        throwsArgumentError,
      );
    });
  });
}
