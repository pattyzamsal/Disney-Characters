import Testing
@testable import DisneyCharacters

@Suite("DomainErrorPresenter")
struct DomainErrorPresenterTests {

    // MARK: - message(for:)

    @Test("Returns noConnection message for noInternetConnection")
    func messageForNoInternetConnection() {
        #expect(DomainErrorPresenter.message(for: DomainError.noInternetConnection) == String(localized: "error.noConnection"))
    }

    @Test("Returns networkFailure message for networkFailure")
    func messageForNetworkFailure() {
        #expect(DomainErrorPresenter.message(for: DomainError.networkFailure("timeout")) == String(localized: "error.networkFailure"))
    }

    @Test("Returns characterNotFound message for characterNotFound")
    func messageForCharacterNotFound() {
        #expect(DomainErrorPresenter.message(for: DomainError.characterNotFound) == String(localized: "error.characterNotFound"))
    }

    @Test("Returns unexpected message for unexpected")
    func messageForUnexpected() {
        #expect(DomainErrorPresenter.message(for: DomainError.unexpected) == String(localized: "error.unexpected"))
    }

    @Test("Returns unexpected message for unknown error type")
    func messageForUnknownError() {
        struct UnknownError: Error {}
        #expect(DomainErrorPresenter.message(for: UnknownError()) == String(localized: "error.unexpected"))
    }

    // MARK: - isRetryable(for:)

    @Test("noInternetConnection is not retryable")
    func noInternetConnectionIsNotRetryable() {
        #expect(DomainErrorPresenter.isRetryable(for: DomainError.noInternetConnection) == false)
    }

    @Test("characterNotFound is not retryable")
    func characterNotFoundIsNotRetryable() {
        #expect(DomainErrorPresenter.isRetryable(for: DomainError.characterNotFound) == false)
    }

    @Test("networkFailure is retryable")
    func networkFailureIsRetryable() {
        #expect(DomainErrorPresenter.isRetryable(for: DomainError.networkFailure("timeout")) == true)
    }

    @Test("unexpected is retryable")
    func unexpectedIsRetryable() {
        #expect(DomainErrorPresenter.isRetryable(for: DomainError.unexpected) == true)
    }

    @Test("Unknown error type is retryable")
    func unknownErrorIsRetryable() {
        struct UnknownError: Error {}
        #expect(DomainErrorPresenter.isRetryable(for: UnknownError()) == true)
    }
}
