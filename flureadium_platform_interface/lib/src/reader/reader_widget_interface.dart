import '../index.dart';

abstract class ReadiumReaderWidgetInterface {
  /// Call to navigate the reader to a location.
  Future<void> go(
    final Locator locator, {
    required final bool isAudioBookWithText,
    final bool animated = false,
  });

  /// Go to previous page.
  Future<void> goLeft({final bool animated = true});

  /// Go to next page.
  Future<void> goRight({final bool animated = true});

  /// Scroll by roughly one viewport in scroll-mode readers.
  ///
  /// Returns true when the current visual position changed or when boundary
  /// navigation was attempted by the platform reader.
  Future<bool> scrollByViewport({
    required ReaderScrollDirection direction,
    double viewportFraction = 0.88,
    bool animated = true,
  });

  /// Skip to previous chapter (toc)
  Future<void> skipToPrevious({final bool animated = true});

  /// Skip to next chapter (toc)
  Future<void> skipToNext({final bool animated = true});

  /// Gets the current Navigator's locator.
  Future<Locator?> getCurrentLocator();

  /// Get a locator with relevant fragments
  Future<Locator?> getLocatorFragments(final Locator locator);

  /// Set EPUB preferences
  Future<void> setEPUBPreferences(EPUBPreferences preferences);

  /// Set PDF preferences
  Future<void> setPDFPreferences(PDFPreferences preferences);

  /// Set navigation config
  Future<void> setNavigationConfig(ReaderNavigationConfig config);

  /// Apply decorations
  Future<void> applyDecorations(String id, List<ReaderDecoration> decorations);
}
