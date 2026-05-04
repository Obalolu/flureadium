import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flureadium/flureadium.dart';

import '../mocks/mock_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFlureadiumPlatform mockPlatform;

  setUp(() {
    mockPlatform = MockFlureadiumPlatform();
    FlureadiumPlatform.instance = mockPlatform;
  });

  tearDown(() {
    mockPlatform.dispose();
  });

  Publication createTestPublication() {
    return Publication(
      metadata: Metadata(
        localizedTitle: LocalizedString.fromString('Test Book'),
        identifier: 'test-book-id',
      ),
      readingOrder: [
        Link(
          href: 'chapter1.xhtml',
          type: 'application/xhtml+xml',
          title: 'Chapter 1',
        ),
        Link(
          href: 'chapter2.xhtml',
          type: 'application/xhtml+xml',
          title: 'Chapter 2',
        ),
      ],
      tableOfContents: [
        Link(href: 'chapter1.xhtml', title: 'Chapter 1'),
        Link(href: 'chapter2.xhtml', title: 'Chapter 2'),
      ],
    );
  }

  group('ReadiumReaderWidget', () {
    group('construction', () {
      test('creates widget with required parameters', () {
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(publication: publication);

        expect(widget.publication, equals(publication));
        expect(widget.loadingWidget, isA<Center>());
        expect(widget.initialLocator, isNull);
      });

      test('creates widget with all parameters', () {
        final publication = createTestPublication();
        final locator = Locator(
          href: 'chapter1.xhtml',
          type: 'application/xhtml+xml',
        );
        const customLoading = Text('Loading...');

        final widget = ReadiumReaderWidget(
          publication: publication,
          initialLocator: locator,
          loadingWidget: customLoading,
          onTap: () {},
          onGoLeft: () {},
          onGoRight: () {},
          onSwipe: () {},
        );

        expect(widget.publication, equals(publication));
        expect(widget.initialLocator, equals(locator));
        expect(widget.loadingWidget, equals(customLoading));
        expect(widget.onTap, isNotNull);
        expect(widget.onGoLeft, isNotNull);
        expect(widget.onGoRight, isNotNull);
        expect(widget.onSwipe, isNotNull);
      });
    });

    group('default loading widget', () {
      test('default loadingWidget is CircularProgressIndicator', () {
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(publication: publication);

        expect(widget.loadingWidget, isA<Center>());
        final center = widget.loadingWidget as Center;
        expect(center.child, isA<CircularProgressIndicator>());
      });
    });

    group('initial locator', () {
      test('accepts initial locator with position', () {
        final publication = createTestPublication();
        final locator = Locator(
          href: 'chapter2.xhtml',
          type: 'application/xhtml+xml',
          locations: Locations(position: 2, progression: 0.5),
        );

        final widget = ReadiumReaderWidget(
          publication: publication,
          initialLocator: locator,
        );

        expect(widget.initialLocator, isNotNull);
        expect(widget.initialLocator!.href, equals('chapter2.xhtml'));
        expect(widget.initialLocator!.locations?.position, equals(2));
      });

      test('accepts initial locator with fragments', () {
        final publication = createTestPublication();
        final locator = Locator(
          href: 'chapter1.xhtml',
          type: 'application/xhtml+xml',
          locations: Locations(
            fragments: ['section1', 'paragraph2'],
            cssSelector: '#my-section',
          ),
        );

        final widget = ReadiumReaderWidget(
          publication: publication,
          initialLocator: locator,
        );

        expect(widget.initialLocator!.locations?.fragments, isNotEmpty);
        expect(
          widget.initialLocator!.locations?.cssSelector,
          equals('#my-section'),
        );
      });
    });

    group('onReady callback', () {
      test('onReady defaults to null', () {
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(publication: publication);

        expect(widget.onReady, isNull);
      });

      test('onReady callback is stored', () {
        var called = false;
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(
          publication: publication,
          onReady: () => called = true,
        );

        widget.onReady!();
        expect(called, isTrue);
      });

      test('widget with onReady is accepted alongside other callbacks', () {
        var readyCalled = false;
        var tappedCalled = false;
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(
          publication: publication,
          onReady: () => readyCalled = true,
          onTap: () => tappedCalled = true,
        );

        widget.onReady!();
        widget.onTap!();
        expect(readyCalled, isTrue);
        expect(tappedCalled, isTrue);
      });
    });

    group('callbacks', () {
      test('onTap callback is stored', () {
        var tapped = false;
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(
          publication: publication,
          onTap: () => tapped = true,
        );

        widget.onTap!();
        expect(tapped, isTrue);
      });

      test('onGoLeft callback is stored', () {
        var wentLeft = false;
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(
          publication: publication,
          onGoLeft: () => wentLeft = true,
        );

        widget.onGoLeft!();
        expect(wentLeft, isTrue);
      });

      test('onGoRight callback is stored', () {
        var wentRight = false;
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(
          publication: publication,
          onGoRight: () => wentRight = true,
        );

        widget.onGoRight!();
        expect(wentRight, isTrue);
      });

      test('createReadiumReaderChannel carries onExternalLinkActivated', () {
        void onExternalLink(String _) {}

        final channel = createReadiumReaderChannel(
          42,
          onPageChanged: (_) {},
          onExternalLinkActivated: onExternalLink,
        );

        expect(channel.onExternalLinkActivated, same(onExternalLink));
      });
    });

    group('publication data', () {
      test('publication is accessible from widget', () {
        final publication = createTestPublication();

        final widget = ReadiumReaderWidget(publication: publication);

        expect(widget.publication.metadata.title, equals('Test Book'));
        expect(widget.publication.readingOrder.length, equals(2));
        expect(widget.publication.tableOfContents.length, equals(2));
      });

      test('publication with cover link', () {
        final publication = Publication(
          metadata: Metadata(
            localizedTitle: LocalizedString.fromString('Book with Cover'),
          ),
          readingOrder: [
            Link(href: 'chapter1.xhtml', type: 'application/xhtml+xml'),
          ],
          resources: [
            Link(href: 'cover.jpg', type: 'image/jpeg', rels: ['cover']),
          ],
        );

        final widget = ReadiumReaderWidget(publication: publication);

        expect(widget.publication.coverLink, isNotNull);
        expect(widget.publication.coverLink!.href, equals('cover.jpg'));
      });
    });
  });

  group('skip navigation with hierarchical TOC', () {
    test('flattenToc exposes nested chapters for navigation', () {
      final publication = Publication(
        metadata: Metadata(
          localizedTitle: LocalizedString.fromString('Hierarchical Book'),
          identifier: 'hierarchical-book',
        ),
        readingOrder: [
          Link(href: '/part.xhtml', type: 'application/xhtml+xml'),
          Link(href: '/ch1.xhtml', type: 'application/xhtml+xml'),
          Link(href: '/ch2.xhtml', type: 'application/xhtml+xml'),
        ],
        tableOfContents: [
          Link(
            href: '/part.xhtml',
            children: [
              Link(href: '/ch1.xhtml'),
              Link(href: '/ch2.xhtml'),
            ],
          ),
        ],
      );

      final flatToc = flattenToc(publication.toc);
      expect(flatToc.map((l) => l.href).toList(), [
        '/part.xhtml',
        '/ch1.xhtml',
        '/ch2.xhtml',
      ]);
    });

    test(
      'skipToNext from child chapter navigates to next child, not sibling',
      () {
        final publication = Publication(
          metadata: Metadata(
            localizedTitle: LocalizedString.fromString('Hierarchical Book'),
            identifier: 'hierarchical-book',
          ),
          readingOrder: [
            Link(href: '/part.xhtml', type: 'application/xhtml+xml'),
            Link(href: '/ch1.xhtml', type: 'application/xhtml+xml'),
            Link(href: '/ch2.xhtml', type: 'application/xhtml+xml'),
            Link(href: '/appendix.xhtml', type: 'application/xhtml+xml'),
          ],
          tableOfContents: [
            Link(
              href: '/part.xhtml',
              children: [
                Link(href: '/ch1.xhtml'),
                Link(href: '/ch2.xhtml'),
              ],
            ),
            Link(href: '/appendix.xhtml'),
          ],
        );

        // reader_widget uses flattenToc(publication.toc)
        final flatToc = flattenToc(publication.toc);
        final ch1Locator = Locator(
          href: '/ch1.xhtml',
          type: 'application/xhtml+xml',
        );
        final curIndex = flatToc.indexWhere((l) => l.href == ch1Locator.href);

        final decision = decideSkipToNext(
          currentLocator: ch1Locator,
          toc: flatToc,
          readingOrder: publication.readingOrder,
          currentTocIndex: curIndex,
          publication: publication,
        );

        expect(decision.canNavigate, isTrue);
        expect(decision.targetLink?.href, '/ch2.xhtml');
        expect(decision.targetTocIndex, 2);
      },
    );

    test('skipToPrevious from child chapter navigates to previous child', () {
      final publication = Publication(
        metadata: Metadata(
          localizedTitle: LocalizedString.fromString('Hierarchical Book'),
          identifier: 'hierarchical-book',
        ),
        readingOrder: [
          Link(href: '/part.xhtml', type: 'application/xhtml+xml'),
          Link(href: '/ch1.xhtml', type: 'application/xhtml+xml'),
          Link(href: '/ch2.xhtml', type: 'application/xhtml+xml'),
        ],
        tableOfContents: [
          Link(
            href: '/part.xhtml',
            children: [
              Link(href: '/ch1.xhtml'),
              Link(href: '/ch2.xhtml'),
            ],
          ),
        ],
      );

      final flatToc = flattenToc(publication.toc);
      final ch2Locator = Locator(
        href: '/ch2.xhtml',
        type: 'application/xhtml+xml',
      );
      final curIndex = flatToc.indexWhere((l) => l.href == ch2Locator.href);

      final decision = decideSkipToPrevious(
        currentLocator: ch2Locator,
        toc: flatToc,
        readingOrder: publication.readingOrder,
        currentTocIndex: curIndex,
        publication: publication,
      );

      expect(decision.canNavigate, isTrue);
      expect(decision.targetLink?.href, '/ch1.xhtml');
      expect(decision.targetTocIndex, 1);
    });
  });

  group('ReadiumReaderWidget custom loading', () {
    test('accepts custom loading widget', () {
      final publication = createTestPublication();
      const customWidget = Column(
        children: [CircularProgressIndicator(), Text('Please wait...')],
      );

      final widget = ReadiumReaderWidget(
        publication: publication,
        loadingWidget: customWidget,
      );

      expect(widget.loadingWidget, isA<Column>());
    });

    test('accepts Placeholder as loading widget', () {
      final publication = createTestPublication();
      const placeholder = Placeholder();

      final widget = ReadiumReaderWidget(
        publication: publication,
        loadingWidget: placeholder,
      );

      expect(widget.loadingWidget, isA<Placeholder>());
    });
  });
}
