import Foundation
import Testing
@testable import DisneyCharacters

@Suite("URLSessionHTTPClient", .serialized)
struct URLSessionHTTPClientTests {
    private let session: URLSession
    private let sut: URLSessionHTTPClient
    private let baseURL = "https://example.com"

    init() {
        URLProtocolStub.reset()
        session = URLProtocolStub.makeSession()
        sut = URLSessionHTTPClient(session: session, baseURL: baseURL)
    }

    // MARK: - Success

    @Test("Returns decoded response on 2xx with valid JSON")
    func returnsDecodedResponseOnSuccess() async throws {
        let payload = try JSONEncoder().encode(SampleResponse.stub(id: 42, name: "Mickey"))
        URLProtocolStub.stub(
            data: payload,
            response: makeHTTPResponse(statusCode: 200),
            error: nil
        )

        let result: SampleResponse = try await sut.perform(makeEndpoint())

        #expect(result.id == 42)
        #expect(result.name == "Mickey")
    }

    @Test("Builds request URL from endpoint path and base URL")
    func buildsRequestURLFromEndpoint() async throws {
        URLProtocolStub.stub(
            data: try JSONEncoder().encode(SampleResponse.stub()),
            response: makeHTTPResponse(statusCode: 200),
            error: nil
        )

        let endpoint = Endpoint(path: "/character", queryItems: [URLQueryItem(name: "page", value: "1")])
        _ = try await sut.perform(endpoint) as SampleResponse

        let requestedURL = URLProtocolStub.lastRequest?.url
        #expect(requestedURL?.absoluteString == "https://example.com/character?page=1")
    }

    @Test("Sends correct HTTP method from endpoint")
    func sendsCorrectHTTPMethod() async throws {
        URLProtocolStub.stub(
            data: try JSONEncoder().encode(SampleResponse.stub()),
            response: makeHTTPResponse(statusCode: 200),
            error: nil
        )

        _ = try await sut.perform(Endpoint(path: "/character", method: .post)) as SampleResponse

        #expect(URLProtocolStub.lastRequest?.httpMethod == "POST")
    }

    // MARK: - Server errors

    @Test("Throws serverError on 4xx response with status code")
    func throwsServerErrorOn404() async {
        URLProtocolStub.stub(
            data: Data(),
            response: makeHTTPResponse(statusCode: 404),
            error: nil
        )

        await #expect(throws: NetworkError.serverError(statusCode: 404)) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }

    @Test("Throws serverError on 5xx response with status code")
    func throwsServerErrorOn500() async {
        URLProtocolStub.stub(
            data: Data(),
            response: makeHTTPResponse(statusCode: 500),
            error: nil
        )

        await #expect(throws: NetworkError.serverError(statusCode: 500)) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }

    // MARK: - URLError mapping

    @Test("Throws noConnection on URLError.notConnectedToInternet")
    func throwsNoConnectionWhenNotConnected() async {
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: URLError(.notConnectedToInternet)
        )

        await #expect(throws: NetworkError.noConnection) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }

    @Test("Throws noConnection on URLError.networkConnectionLost")
    func throwsNoConnectionWhenConnectionLost() async {
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: URLError(.networkConnectionLost)
        )

        await #expect(throws: NetworkError.noConnection) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }

    @Test("Throws timeout on URLError.timedOut")
    func throwsTimeoutOnRequestTimeout() async {
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: URLError(.timedOut)
        )

        await #expect(throws: NetworkError.timeout) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }

    @Test("Throws unknown on unmapped URLError")
    func throwsUnknownOnUnmappedURLError() async {
        URLProtocolStub.stub(
            data: nil,
            response: nil,
            error: URLError(.badServerResponse)
        )

        await #expect(throws: NetworkError.unknown) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }

    // MARK: - Response shape errors

    @Test("Throws unknown when response is not HTTPURLResponse")
    func throwsUnknownOnNonHTTPResponse() async {
        // swiftlint:disable:next force_unwrapping
        let url = URL(string: baseURL)!
        let nonHTTPResponse = URLResponse(
            url: url,
            mimeType: nil,
            expectedContentLength: 0,
            textEncodingName: nil
        )
        URLProtocolStub.stub(
            data: Data("{}".utf8),
            response: nonHTTPResponse,
            error: nil
        )

        await #expect(throws: NetworkError.unknown) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }

    @Test("Throws noData on empty response body with 2xx status")
    func throwsNoDataOnEmptyBody() async {
        URLProtocolStub.stub(
            data: Data(),
            response: makeHTTPResponse(statusCode: 200),
            error: nil
        )

        await #expect(throws: NetworkError.noData) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }

    @Test("Throws decodingError when JSON does not match Decodable type")
    func throwsDecodingErrorOnMalformedJSON() async {
        URLProtocolStub.stub(
            data: Data("{\"unexpected\":true}".utf8),
            response: makeHTTPResponse(statusCode: 200),
            error: nil
        )

        await #expect(throws: NetworkError.decodingError) {
            let _: SampleResponse = try await sut.perform(makeEndpoint())
        }
    }
}

// MARK: - Helpers

private extension URLSessionHTTPClientTests {
    func makeEndpoint() -> Endpoint {
        Endpoint(path: "/character")
    }

    func makeHTTPResponse(statusCode: Int) -> HTTPURLResponse {
        // swiftlint:disable force_unwrapping
        let url = URL(string: baseURL)!
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        // swiftlint:enable force_unwrapping
    }
}

private struct SampleResponse: Codable, Equatable {
    let id: Int
    let name: String

    static func stub(id: Int = 1, name: String = "Mickey") -> SampleResponse {
        SampleResponse(id: id, name: name)
    }
}
