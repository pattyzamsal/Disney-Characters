import Foundation

enum DomainError: Error, Equatable {
    case characterNotFound
    case noInternetConnection
    case networkFailure(String)
    case unexpected
}
