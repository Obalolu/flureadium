import Foundation
import ImageIO
import CoreGraphics
import MobileCoreServices
import UniformTypeIdentifiers

/// Decodes raw image bytes into a downscaled JPEG via ImageIO's thumbnail-direct path.
/// DCT-domain downscale during decode — never materializes the full-resolution bitmap.
enum PageThumbnailExtractor {
  static func extract(data: Data, maxHeight: Int, quality: Int) -> Data? {
    guard !data.isEmpty, maxHeight > 0 else { return nil }

    guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
      return nil
    }

    let options: [CFString: Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceThumbnailMaxPixelSize: maxHeight,
      kCGImageSourceCreateThumbnailWithTransform: true,
    ]

    guard let cgImage = CGImageSourceCreateThumbnailAtIndex(
      source, 0, options as CFDictionary
    ) else {
      return nil
    }

    let outputData = NSMutableData()
    let utType: CFString
    if #available(iOS 14.0, *) {
      utType = UTType.jpeg.identifier as CFString
    } else {
      utType = kUTTypeJPEG
    }
    guard let dest = CGImageDestinationCreateWithData(outputData, utType, 1, nil) else {
      return nil
    }
    let q = max(0.0, min(1.0, Double(quality) / 100.0))
    let destOptions: [CFString: Any] = [
      kCGImageDestinationLossyCompressionQuality: q,
    ]
    CGImageDestinationAddImage(dest, cgImage, destOptions as CFDictionary)
    guard CGImageDestinationFinalize(dest) else { return nil }

    return outputData as Data
  }
}
