import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingError
    case serverError(statusCode: Int)
    case noConnection
    case timeout
    case unknown
}
