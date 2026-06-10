import Foundation
import Testing
@testable import DisneyCharacters

@Suite("Endpoint")
struct EndpointTests {

    @Test("Builds URL from base URL and path")
    func buildsURLFromBaseAndPath() throws {
        let endpoint = Endpoint(path: "/character")

        let url = try endpoint.url(baseURL: "https://api.example.com")

        #expect(url.absoluteString == "https://api.example.com/character")
    }

    @Test("Appends query items to URL when present")
    func appendsQueryItems() throws {
        let endpoint = Endpoint(
            path: "/character",
            queryItems: [
                URLQueryItem(name: "page", value: "1"),
                URLQueryItem(name: "pageSize", value: "50")
            ]
        )

        let url = try endpoint.url(baseURL: "https://api.example.com")

        #expect(url.absoluteString == "https://api.example.com/character?page=1&pageSize=50")
    }

    @Test("Does not append query string when query items are empty")
    func omitsQueryStringWhenEmpty() throws {
        let endpoint = Endpoint(path: "/character", queryItems: [])

        let url = try endpoint.url(baseURL: "https://api.example.com")

        #expect(url.absoluteString == "https://api.example.com/character")
    }

    @Test("Defaults HTTP method to GET")
    func defaultsToGET() {
        let endpoint = Endpoint(path: "/character")

        #expect(endpoint.method == .get)
    }

    @Test("Throws invalidURL when base URL cannot be composed")
    func throwsInvalidURLOnMalformedInput() {
        let endpoint = Endpoint(path: "/character")

        #expect(throws: NetworkError.invalidURL) {
            _ = try endpoint.url(baseURL: "https://exa mple.com")
        }
    }
}
