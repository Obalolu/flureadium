import { EpubPage } from './EpubPage';
import { Locations, Readium } from './types';

// Mock the global readium object
const mockScrollToPosition = jest.fn();
const mockReadium: Partial<Readium> = {
  scrollToPosition: mockScrollToPosition,
  isScrollModeEnabled: jest.fn().mockReturnValue(true),
};

// Set up globals before importing EpubPage
(global as any).readium = mockReadium;
(global as any).isIos = false;
(global as any).isAndroid = false;
(global as any).webkit = undefined;
(global as any).Android = null;
(global as any).comicBookPage = null;

describe('EpubPage', () => {
  let epubPage: EpubPage;
  let originalInnerHeight: number;

  beforeEach(() => {
    jest.clearAllMocks();
    epubPage = new EpubPage();
    originalInnerHeight = window.innerHeight;
  });

  afterEach(() => {
    Object.defineProperty(window, 'innerHeight', {
      configurable: true,
      value: originalInnerHeight,
    });
  });

  function setScroller({ scrollTop, scrollHeight, clientHeight }: { scrollTop: number; scrollHeight: number; clientHeight: number }) {
    const scroller = {
      scrollTop,
      scrollHeight,
      clientHeight,
    };
    Object.defineProperty(document, 'scrollingElement', {
      configurable: true,
      value: scroller,
    });
    return scroller;
  }

  describe('scrollToLocations', () => {
    describe('scroll mode (isVerticalScroll = true)', () => {
      it('uses progression directly when available', () => {
        const locations: Locations = {
          cssSelector: 'body > :nth-child(38)',
          progression: 0.446870373151943,
          totalProgression: 0.05,
          fragments: null,
          domRange: null,
        };

        const result = epubPage.scrollToLocations(locations, true, false);

        expect(result).toBe(true);
        expect(mockScrollToPosition).toHaveBeenCalledTimes(1);
        expect(mockScrollToPosition).toHaveBeenCalledWith(0.446870373151943);
      });

      it('preserves full precision of progression value', () => {
        const preciseProgression = 0.123456789012345;
        const locations: Locations = {
          cssSelector: '#some-element',
          progression: preciseProgression,
          totalProgression: null,
          fragments: null,
          domRange: null,
        };

        epubPage.scrollToLocations(locations, true, false);

        expect(mockScrollToPosition).toHaveBeenCalledWith(preciseProgression);
      });

      it('handles progression at boundaries (0 and 1)', () => {
        const locationsStart: Locations = {
          cssSelector: null,
          progression: 0,
          totalProgression: null,
          fragments: null,
          domRange: null,
        };

        epubPage.scrollToLocations(locationsStart, true, false);
        expect(mockScrollToPosition).toHaveBeenCalledWith(0);

        mockScrollToPosition.mockClear();

        const locationsEnd: Locations = {
          cssSelector: null,
          progression: 1,
          totalProgression: null,
          fragments: null,
          domRange: null,
        };

        epubPage.scrollToLocations(locationsEnd, true, false);
        expect(mockScrollToPosition).toHaveBeenCalledWith(1);
      });

      it('returns false when no progression or CSS selector available', () => {
        const locations: Locations = {
          cssSelector: null,
          progression: null,
          totalProgression: 0.05,
          fragments: null,
          domRange: null,
        };

        const result = epubPage.scrollToLocations(locations, true, false);

        expect(result).toBe(false);
        expect(mockScrollToPosition).not.toHaveBeenCalled();
      });
    });

    describe('paginated mode (isVerticalScroll = false)', () => {
      it('does not prioritize progression over CSS selector', () => {
        const locations: Locations = {
          cssSelector: 'body > :nth-child(38)',
          progression: 0.446870373151943,
          totalProgression: null,
          fragments: null,
          domRange: null,
        };

        // In paginated mode, it will try _processLocations first
        // Since we can't easily mock DOM elements, it will fail and fall back to progression
        const result = epubPage.scrollToLocations(locations, false, false);

        // It should still work (via fallback to progression)
        expect(result).toBe(true);
      });

      it('uses progression as fallback when CSS selector processing fails', () => {
        const locations: Locations = {
          cssSelector: '#non-existent-element',
          progression: 0.75,
          totalProgression: null,
          fragments: null,
          domRange: null,
        };

        const result = epubPage.scrollToLocations(locations, false, false);

        expect(result).toBe(true);
        expect(mockScrollToPosition).toHaveBeenCalledWith(0.75);
      });
    });

    describe('edge cases', () => {
      it('handles undefined readium gracefully', () => {
        const originalReadium = (global as any).readium;
        (global as any).readium = undefined;

        const locations: Locations = {
          cssSelector: null,
          progression: 0.5,
          totalProgression: null,
          fragments: null,
          domRange: null,
        };

        // Should not throw
        expect(() => {
          epubPage.scrollToLocations(locations, true, false);
        }).not.toThrow();

        (global as any).readium = originalReadium;
      });

      it('handles progression value of 0 correctly (not falsy)', () => {
        const locations: Locations = {
          cssSelector: 'body',
          progression: 0,
          totalProgression: 0,
          fragments: null,
          domRange: null,
        };

        const result = epubPage.scrollToLocations(locations, true, false);

        expect(result).toBe(true);
        // 0 is a valid progression, should be used
        expect(mockScrollToPosition).toHaveBeenCalledWith(0);
      });
    });
  });

  describe('scrollByViewport', () => {
    beforeEach(() => {
      Object.defineProperty(window, 'innerHeight', {
        configurable: true,
        value: 1000,
      });
    });

    it('scrolls down by viewport fraction', () => {
      setScroller({ scrollTop: 100, scrollHeight: 3000, clientHeight: 1000 });

      const result = epubPage.scrollByViewport('next', 0.88);

      expect(result).toEqual({ moved: true, boundary: null });
      expect(mockScrollToPosition).toHaveBeenCalledWith(980 / 3000);
    });

    it('scrolls up by viewport fraction', () => {
      setScroller({ scrollTop: 1000, scrollHeight: 3000, clientHeight: 1000 });

      const result = epubPage.scrollByViewport('previous', 0.5);

      expect(result).toEqual({ moved: true, boundary: null });
      expect(mockScrollToPosition).toHaveBeenCalledWith(500 / 3000);
    });

    it('clamps to the end of the document', () => {
      setScroller({ scrollTop: 1800, scrollHeight: 3000, clientHeight: 1000 });

      const result = epubPage.scrollByViewport('next', 0.88);

      expect(result).toEqual({ moved: true, boundary: null });
      expect(mockScrollToPosition).toHaveBeenCalledWith(2000 / 3000);
    });

    it('returns end boundary when already at the end', () => {
      setScroller({ scrollTop: 2000, scrollHeight: 3000, clientHeight: 1000 });

      const result = epubPage.scrollByViewport('next', 0.88);

      expect(result).toEqual({ moved: false, boundary: 'end' });
      expect(mockScrollToPosition).not.toHaveBeenCalled();
    });

    it('returns start boundary when already at the start', () => {
      setScroller({ scrollTop: 0, scrollHeight: 3000, clientHeight: 1000 });

      const result = epubPage.scrollByViewport('previous', 0.88);

      expect(result).toEqual({ moved: false, boundary: 'start' });
      expect(mockScrollToPosition).not.toHaveBeenCalled();
    });

    it('returns boundary for a non-scrollable document', () => {
      setScroller({ scrollTop: 0, scrollHeight: 900, clientHeight: 1000 });

      expect(epubPage.scrollByViewport('previous', 0.88)).toEqual({ moved: false, boundary: 'start' });
      expect(epubPage.scrollByViewport('next', 0.88)).toEqual({ moved: false, boundary: 'end' });
      expect(mockScrollToPosition).not.toHaveBeenCalled();
    });

    it('uses default fraction for invalid values', () => {
      setScroller({ scrollTop: 100, scrollHeight: 3000, clientHeight: 1000 });

      epubPage.scrollByViewport('next', Number.NaN);

      expect(mockScrollToPosition).toHaveBeenCalledWith(980 / 3000);
    });

    it('uses scroller clientHeight instead of window innerHeight for the step', () => {
      Object.defineProperty(window, 'innerHeight', {
        configurable: true,
        value: 1200,
      });
      setScroller({ scrollTop: 100, scrollHeight: 3000, clientHeight: 800 });

      epubPage.scrollByViewport('next', 0.5);

      expect(mockScrollToPosition).toHaveBeenCalledWith(500 / 3000);
    });
  });
});
