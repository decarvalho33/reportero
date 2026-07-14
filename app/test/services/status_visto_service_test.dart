import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/models/denuncia.dart';
import 'package:app/services/status_visto_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StatusVistoService', () {
    test('retorna mapa vazio quando nada foi salvo ainda', () async {
      final vistos = await StatusVistoService().obterStatusVistos();

      expect(vistos, isEmpty);
    });

    test('marca uma denúncia como vista e persiste o status', () async {
      await StatusVistoService().marcarComoVisto('denuncia-1', StatusDenuncia.pendente);

      final vistos = await StatusVistoService().obterStatusVistos();

      expect(vistos['denuncia-1'], equals(StatusDenuncia.pendente.label));
    });

    test('atualiza o status visto sem afetar outras denúncias já salvas', () async {
      await StatusVistoService().marcarComoVisto('denuncia-1', StatusDenuncia.pendente);
      await StatusVistoService().marcarComoVisto('denuncia-2', StatusDenuncia.emAnalise);

      final vistos = await StatusVistoService().obterStatusVistos();

      expect(vistos['denuncia-1'], equals(StatusDenuncia.pendente.label));
      expect(vistos['denuncia-2'], equals(StatusDenuncia.emAnalise.label));
    });

    test('sobrescreve o status visto quando a denúncia já tinha um status salvo', () async {
      await StatusVistoService().marcarComoVisto('denuncia-1', StatusDenuncia.pendente);
      await StatusVistoService().marcarComoVisto('denuncia-1', StatusDenuncia.resolvida);

      final vistos = await StatusVistoService().obterStatusVistos();

      expect(vistos.length, equals(1));
      expect(vistos['denuncia-1'], equals(StatusDenuncia.resolvida.label));
    });

    test('a fábrica devolve sempre a mesma instância (Singleton)', () {
      expect(identical(StatusVistoService(), StatusVistoService()), isTrue);
    });
  });
}
