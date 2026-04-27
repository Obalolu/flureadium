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

    testWidgets('revisiting pages loads from cache without errors', (
      tester,
    ) async {
      app.main(initialAsset: 'assets/pubs/sample_comic.cbz');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) break;
      }

      expect(find.byType(ReadiumReaderWidget), findsOneWidget);

      // Navigate forward two pages
      await tester.tap(find.text('→'));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('→'));
      await tester.pump(const Duration(seconds: 2));

      // Navigate back to previously visited pages (cache hit path on iOS)
      await tester.tap(find.text('←'));
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.text('←'));
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(ReadiumReaderWidget), findsOneWidget);
    });

    testWidgets(
      'Flureadium.goToLocator navigates CBZ reader (Bug 1 regression)',
      (tester) async {
        app.main(initialAsset: 'assets/pubs/sample_comic.cbz');
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(seconds: 1));
          if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) break;
        }

        expect(find.byType(ReadiumReaderWidget), findsOneWidget);

        const locator = Locator(
          href: '003.jpg',
          type: 'image/jpeg',
          locations: Locations(position: 3, progression: 0.4),
        );
        final navigated = await Flureadium().goToLocator(locator);
        await tester.pump(const Duration(seconds: 1));

        expect(navigated, isTrue);
      },
    );

    testWidgets(
      'extractPageThumbnail returns JPEG bytes for a valid CBZ page',
      (tester) async {
        app.main(initialAsset: 'assets/pubs/sample_comic.cbz');
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(seconds: 1));
          if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) break;
        }

        final bytes = await Flureadium().extractPageThumbnail(
          '001.jpg',
          80,
          70,
        );

        expect(bytes, isNotNull);
        expect(bytes!.length, greaterThan(2));
        // JPEG magic bytes (SOI marker)
        expect(bytes[0], 0xFF);
        expect(bytes[1], 0xD8);
      },
    );

    testWidgets('extractPageThumbnail returns null for bogus href', (
      tester,
    ) async {
      app.main(initialAsset: 'assets/pubs/sample_comic.cbz');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) break;
      }

      final bytes = await Flureadium().extractPageThumbnail(
        '/does/not/exist.jpg',
        80,
        70,
      );

      expect(bytes, isNull);
    });

    testWidgets('extractPageThumbnail returns null after closePublication', (
      tester,
    ) async {
      app.main(initialAsset: 'assets/pubs/sample_comic.cbz');
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) break;
      }

      await Flureadium().closePublication();
      final bytes = await Flureadium().extractPageThumbnail('001.jpg', 80, 70);

      expect(bytes, isNull);
    });
  });
}
