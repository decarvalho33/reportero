import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/dispositivo_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DispositivoService', () {
    test('gera e persiste um id no formato UUID v4', () async {
      final id = await DispositivoService().obterId();

      expect(id, isNotEmpty);
      // UUID v4: 8-4-4-4-12 hex, com versão 4 e variante 8/9/a/b.
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(id),
        isTrue,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('reportero_device_id'), equals(id));
    });

    test('retorna o mesmo id em chamadas consecutivas', () async {
      final primeiro = await DispositivoService().obterId();
      final segundo = await DispositivoService().obterId();

      expect(segundo, equals(primeiro));
    });

    test('a fábrica devolve sempre a mesma instância (Singleton)', () {
      expect(identical(DispositivoService(), DispositivoService()), isTrue);
    });
  });
}
