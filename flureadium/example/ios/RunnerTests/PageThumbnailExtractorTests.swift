import XCTest
import ImageIO
import UIKit
@testable import flureadium

final class PageThumbnailExtractorTests: XCTestCase {
  func test_extract_validJpeg_returnsSmallerJpeg() throws {
    let data = try fixtureJpeg(width: 200, height: 300)
    let result = PageThumbnailExtractor.extract(data: data, maxHeight: 80, quality: 70)
    XCTAssertNotNil(result)
    XCTAssertLessThan(result!.count, data.count)
  }

  func test_extract_maxHeight80_producesImageWithLongestSideAtMost80() throws {
    let data = try fixtureJpeg(width: 200, height: 300)
    let result = PageThumbnailExtractor.extract(data: data, maxHeight: 80, quality: 70)
    let outputSize = try imageSize(from: XCTUnwrap(result))
    XCTAssertLessThanOrEqual(max(outputSize.width, outputSize.height), 80)
  }

  func test_extract_invalidBytes_returnsNil() {
    let data = Data([0x00, 0x01, 0x02, 0x03])
    XCTAssertNil(PageThumbnailExtractor.extract(data: data, maxHeight: 80, quality: 70))
  }

  func test_extract_emptyData_returnsNil() {
    XCTAssertNil(PageThumbnailExtractor.extract(data: Data(), maxHeight: 80, quality: 70))
  }

  func test_extract_zeroMaxHeight_returnsNil() throws {
    let data = try fixtureJpeg(width: 200, height: 300)
    XCTAssertNil(PageThumbnailExtractor.extract(data: data, maxHeight: 0, quality: 70))
  }

  // MARK: - Helpers

  private func fixtureJpeg(width: Int, height: Int) throws -> Data {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
    let image = renderer.image { ctx in
      UIColor.red.setFill()
      ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
    }
    return try XCTUnwrap(image.jpegData(compressionQuality: 0.9))
  }

  private func imageSize(from data: Data) throws -> CGSize {
    let source = try XCTUnwrap(CGImageSourceCreateWithData(data as CFData, nil))
    let cgImage = try XCTUnwrap(CGImageSourceCreateImageAtIndex(source, 0, nil))
    return CGSize(width: cgImage.width, height: cgImage.height)
  }
}
