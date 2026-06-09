import Foundation

protocol HTTPClient: Sendable {
    func perform<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
