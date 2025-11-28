import 'package:flutter_test/flutter_test.dart';
import 'package:oqueeoquee/injection_container.dart';

void main() {
  group('Dependency Injection Container', () {
    test('deve exportar service locator (sl)', () {
      expect(sl, isNotNull);
    });

    test('deve ter função initializeDependencies', () {
      expect(initializeDependencies, isNotNull);
      expect(initializeDependencies, isA<Function>());
    });

    test('deve ter função resetDependencies', () {
      expect(resetDependencies, isNotNull);
      expect(resetDependencies, isA<Function>());
    });

    // Testes de integração completos serão feitos manualmente
    // pois requerem Supabase e SharedPreferences reais
    test('deve permitir reset sem erros', () async {
      await expectLater(
        resetDependencies(),
        completes,
      );
    });
  });
}
