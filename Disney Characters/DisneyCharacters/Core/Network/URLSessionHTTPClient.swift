import Foundation

final class URLSessionHTTPClient {
    private let session: URLSession
    private let baseURL: String

    init(session: URLSession = .shared, baseURL: String = Environment.baseURL) {
        self.session = session
        self.baseURL = baseURL
    }
}

extension URLSessionHTTPClient: HTTPClient {
    func perform<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let url = try endpoint.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }

            guard !data.isEmpty else {
                throw NetworkError.noData
            }

            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError
            }
        } catch let error as NetworkError {
            throw error
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noConnection
            case .timedOut:
                throw NetworkError.timeout
            default:
                throw NetworkError.unknown
            }
        } catch {
            throw NetworkError.unknown
        }
    }
}
