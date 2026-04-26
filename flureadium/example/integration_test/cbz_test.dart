import 'dart:io';

import 'package:flureadium/flureadium.dart';
import 'package:flutter/services.dart';
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
        Publication? pub;
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(seconds: 1));
          if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) {
            pub = await Flureadium().loadPublication(
              await _resolveAsset('assets/pubs/sample_comic.cbz'),
            );
            break;
          }
        }

        expect(find.byType(ReadiumReaderWidget), findsOneWidget);
        expect(pub, isNotNull);
        expect(pub!.readingOrder.length, greaterThan(2));

        final targetLink = pub.readingOrder[2];
        final locator = pub.locatorFromLink(targetLink);
        expect(locator, isNotNull);

        final navigated = await Flureadium().goToLocator(locator!);
        await tester.pump(const Duration(seconds: 1));

        expect(navigated, isTrue);
      },
    );

    testWidgets(
      'extractPageThumbnail returns JPEG bytes for a valid CBZ page',
      (tester) async {
        app.main(initialAsset: 'assets/pubs/sample_comic.cbz');
        Publication? pub;
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(seconds: 1));
          if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) {
            pub = await Flureadium().loadPublication(
              await _resolveAsset('assets/pubs/sample_comic.cbz'),
            );
            break;
          }
        }
        expect(pub, isNotNull);

        final href = pub!.readingOrder.first.href;
        final bytes = await Flureadium().extractPageThumbnail(href, 80, 70);

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
      Publication? pub;
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(ReadiumReaderWidget).evaluate().isNotEmpty) {
          pub = await Flureadium().loadPublication(
            await _resolveAsset('assets/pubs/sample_comic.cbz'),
          );
          break;
        }
      }
      expect(pub, isNotNull);
      final href = pub!.readingOrder.first.href;

      await Flureadium().closePublication();
      final bytes = await Flureadium().extractPageThumbnail(href, 80, 70);

      expect(bytes, isNull);
    });
  });
}

Future<String> _resolveAsset(String assetPath) async {
  final bytes = await rootBundle.load(assetPath);
  final filename = assetPath.split('/').last;
  final tmp = File(
    '${Directory.systemTemp.path}/${DateTime.now().millisecondsSinceEpoch}_$filename',
  );
  await tmp.writeAsBytes(bytes.buffer.asUint8List());
  return tmp.path;
}
