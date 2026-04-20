import UIKit

struct ImageReaderNavigationState {
  var enableEdgeTapNavigation = true
  var enableSwipeNavigation = true
  var edgeTapAreaPoints: CGFloat?

  mutating func apply(_ navConfig: FlutterNavigationConfig) {
    if let value = navConfig.enableEdgeTapNavigation {
      enableEdgeTapNavigation = value
    }
    if let value = navConfig.enableSwipeNavigation {
      enableSwipeNavigation = value
    }
    if let points = navConfig.edgeTapAreaPoints {
      edgeTapAreaPoints = Self.clamp(points)
    }
  }

  func configure(
    edgeTapView: EdgeTapInterceptView,
    onLeftEdgeTap: @escaping () -> Void,
    onRightEdgeTap: @escaping () -> Void,
    onSwipeLeft: @escaping () -> Void,
    onSwipeRight: @escaping () -> Void
  ) {
    edgeTapView.interceptEdgeTaps = enableEdgeTapNavigation

    if enableEdgeTapNavigation {
      if let points = edgeTapAreaPoints {
        edgeTapView.edgeThresholdPoints = points
      }
      edgeTapView.onLeftEdgeTap = onLeftEdgeTap
      edgeTapView.onRightEdgeTap = onRightEdgeTap
    } else {
      edgeTapView.onLeftEdgeTap = nil
      edgeTapView.onRightEdgeTap = nil
    }

    if enableSwipeNavigation {
      edgeTapView.onSwipeLeft = onSwipeLeft
      edgeTapView.onSwipeRight = onSwipeRight
    } else {
      edgeTapView.onSwipeLeft = nil
      edgeTapView.onSwipeRight = nil
    }
  }

  static func clamp(_ points: Double) -> CGFloat {
    CGFloat(min(max(points, 44.0), 120.0))
  }
}
