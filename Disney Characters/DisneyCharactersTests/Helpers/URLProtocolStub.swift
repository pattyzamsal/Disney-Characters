import Foundation

final class URLProtocolStub: URLProtocol {
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var currentStub: Stub?
    nonisolated(unsafe) private static var observedRequests: [URLRequest] = []

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        lock.lock()
        defer { lock.unlock() }
        currentStub = Stub(data: data, response: response, error: error)
    }

    static func reset() {
        lock.lock()
        defer { lock.unlock() }
        currentStub = nil
        observedRequests.removeAll()
    }

    static var lastRequest: URLRequest? {
        lock.lock()
        defer { lock.unlock() }
        return observedRequests.last
    }

    static func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: config)
    }

    override static func canInit(with request: URLRequest) -> Bool {
        lock.lock()
        observedRequests.append(request)
        lock.unlock()
        return true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.lock.lock()
        let stub = Self.currentStub
        Self.lock.unlock()

        if let error = stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
