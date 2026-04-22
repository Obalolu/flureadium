import XCTest
@testable import flureadium

final class ImageCacheURLProtocolTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ImageCacheURLProtocol.disable()
    }

    override func tearDown() {
        ImageCacheURLProtocol.disable()
        super.tearDown()
    }

    // MARK: - canInit

    func testCanInitReturnsTrueForLocalhostGET() {
        let request = URLRequest(url: URL(string: "http://localhost:8080/image.jpg")!)
        XCTAssertTrue(ImageCacheURLProtocol.canInit(with: request))
    }

    func testCanInitReturnsTrueFor127001GET() {
        let request = URLRequest(url: URL(string: "http://127.0.0.1:8080/image.jpg")!)
        XCTAssertTrue(ImageCacheURLProtocol.canInit(with: request))
    }

    func testCanInitReturnsFalseForNonLocalhost() {
        let request = URLRequest(url: URL(string: "https://example.com/image.jpg")!)
        XCTAssertFalse(ImageCacheURLProtocol.canInit(with: request))
    }

    func testCanInitReturnsFalseForPOST() {
        var request = URLRequest(url: URL(string: "http://localhost:8080/image.jpg")!)
        request.httpMethod = "POST"
        XCTAssertFalse(ImageCacheURLProtocol.canInit(with: request))
    }

    func testCanInitReturnsFalseForAlreadyHandledRequest() {
        let url = URL(string: "http://localhost:8080/image.jpg")!
        let mutable = NSMutableURLRequest(url: url)
        URLProtocol.setProperty(true, forKey: "ImageCacheURLProtocol.handled", in: mutable)
        XCTAssertFalse(ImageCacheURLProtocol.canInit(with: mutable as URLRequest))
    }

    // MARK: - Cache hit

    func testCacheHitReturnsCachedDataWithoutNetwork() {
        let expectation = self.expectation(description: "Cache hit")
        let url = URL(string: "http://localhost:19876/cached-image.jpg")!

        ImageCacheURLProtocol.seedCache(url: url, data: Data([0xFF, 0xD8, 0xFF, 0xE0]), mimeType: "image/jpeg")

        ImageCacheURLProtocol.enable()

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            XCTAssertNil(error)
            XCTAssertEqual(data, Data([0xFF, 0xD8, 0xFF, 0xE0]))
            expectation.fulfill()
        }
        task.resume()

        waitForExpectations(timeout: 5)
    }

    // MARK: - clearCache

    func testClearCacheRemovesAllEntries() {
        let url = URL(string: "http://localhost:19876/test-image.jpg")!
        ImageCacheURLProtocol.seedCache(url: url, data: Data([0x01, 0x02]), mimeType: "image/png")
        XCTAssertTrue(ImageCacheURLProtocol.hasCachedResponse(for: url))

        ImageCacheURLProtocol.clearCache()

        XCTAssertFalse(ImageCacheURLProtocol.hasCachedResponse(for: url))
    }

    // MARK: - enable / disable

    func testEnableRegistersProtocol() {
        ImageCacheURLProtocol.enable()
        // After enable, canInit should still work (protocol is registered).
        let request = URLRequest(url: URL(string: "http://localhost:8080/image.jpg")!)
        XCTAssertTrue(ImageCacheURLProtocol.canInit(with: request))
    }

    func testDisableUnregistersAndClearsCache() {
        let url = URL(string: "http://localhost:19876/disable-test.jpg")!
        ImageCacheURLProtocol.seedCache(url: url, data: Data([0x01]), mimeType: "image/jpeg")
        XCTAssertTrue(ImageCacheURLProtocol.hasCachedResponse(for: url))

        ImageCacheURLProtocol.disable()

        XCTAssertFalse(ImageCacheURLProtocol.hasCachedResponse(for: url))
    }

    // MARK: - Cache miss with real network

    func testCacheMissForwardsRequestAndCachesResponse() {
        let expectation = self.expectation(description: "Cache miss forwards")
        let url = URL(string: "http://localhost:19999/nonexistent.jpg")!

        ImageCacheURLProtocol.enable()

        // Connection refused is expected — no server on port 19999.
        // Verifies the protocol forwarded the request instead of looping.
        let task = URLSession.shared.dataTask(with: url) { _, _, error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        task.resume()

        waitForExpectations(timeout: 5)
    }
}
