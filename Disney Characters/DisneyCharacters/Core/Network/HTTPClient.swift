import Foundation

protocol HTTPClient {
    func perform<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
