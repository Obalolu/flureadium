import 'package:flureadium/flureadium.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flureadium_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('CBZ', () {
    tearDown(() async {
      final flureadium = Flureadium();
      await flureadium.closePublication();
    });

    testWidgets('app auto-opens CBZ and shows reader widget', (tester) async {
      app.main(initialAsset: 'assets/pubs/sample_comic.cbz');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) break;
      }

      expect(find.byType(ReadiumReaderWidget), findsOneWidget);
    });

    testWidgets('navigate left and right in CBZ reader', (tester) async {
      app.main(initialAsset: 'assets/pubs/sample_comic.cbz');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) break;
      }

      expect(find.byType(ReadiumReaderWidget), findsOneWidget);

      await tester.tap(find.text('→'));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('←'));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ReadiumReaderWidget), findsOneWidget);
    });
  });
}
