import Foundation

enum DomainErrorPresenter {
    static func message(for error: Error) -> String {
        guard let domainError = error as? DomainError else {
            return String(localized: "error.unexpected")
        }
        switch domainError {
        case .noInternetConnection:
            return String(localized: "error.noConnection")
        case .networkFailure:
            return String(localized: "error.networkFailure")
        case .characterNotFound:
            return String(localized: "error.characterNotFound")
        case .unexpected:
            return String(localized: "error.unexpected")
        }
    }

    static func isRetryable(for error: Error) -> Bool {
        guard let domainError = error as? DomainError else { return true }
        switch domainError {
        case .noInternetConnection, .characterNotFound:
            return false
        case .networkFailure, .unexpected:
            return true
        }
    }
}
