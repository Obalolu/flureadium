import Foundation

/// Caches HTTP responses from Readium's local server for image-based
/// publications (CBZ, DiViNa). Readium's ResourceResponse disables
/// HTTP caching for DRM safety, but CBZ/DiViNa have no DRM — caching
/// is safe and eliminates redundant ZIP extraction + HTTP round-trips
/// on every page turn.
final class ImageCacheURLProtocol: URLProtocol {
    private static let handledKey = "ImageCacheURLProtocol.handled"
    private static let cache = NSCache<NSURL, CachedResponse>()

    override class func canInit(with request: URLRequest) -> Bool {
        guard
            let url = request.url,
            let host = url.host,
            (host == "localhost" || host == "127.0.0.1"),
            request.httpMethod == "GET",
            URLProtocol.property(
                forKey: handledKey, in: request
            ) == nil
        else { return false }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let url = request.url! as NSURL
        if let cached = Self.cache.object(forKey: url) {
            let response = URLResponse(
                url: url as URL,
                mimeType: cached.mimeType,
                expectedContentLength: cached.data.count,
                textEncodingName: nil
            )
            client?.urlProtocol(self, didReceive: response,
                                cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: cached.data)
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        let mutable = (request as NSURLRequest).mutableCopy()
            as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: Self.handledKey, in: mutable)

        let task = URLSession.shared.dataTask(with: mutable as URLRequest) {
            [weak self] data, response, error in
            guard let self else { return }
            if let error {
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }
            if let data, let response {
                let entry = CachedResponse(
                    data: data,
                    mimeType: response.mimeType
                )
                Self.cache.setObject(entry, forKey: url, cost: data.count)

                self.client?.urlProtocol(self, didReceive: response,
                                         cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: data)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
        task.resume()
    }

    override func stopLoading() {}

    // MARK: - Public API

    static func enable() {
        URLProtocol.registerClass(ImageCacheURLProtocol.self)
    }

    static func disable() {
        URLProtocol.unregisterClass(ImageCacheURLProtocol.self)
        cache.removeAllObjects()
    }

    static func clearCache() {
        cache.removeAllObjects()
    }

    // MARK: - Test Helpers

    static func seedCache(url: URL, data: Data, mimeType: String?) {
        let entry = CachedResponse(data: data, mimeType: mimeType)
        cache.setObject(entry, forKey: url as NSURL, cost: data.count)
    }

    static func hasCachedResponse(for url: URL) -> Bool {
        cache.object(forKey: url as NSURL) != nil
    }
}

// NSCache requires AnyObject values, so this must be a class.
private final class CachedResponse {
    let data: Data
    let mimeType: String?

    init(data: Data, mimeType: String?) {
        self.data = data
        self.mimeType = mimeType
    }
}
