import Testing
@testable import DisneyCharacters

@Suite("SearchCharactersUseCase")
struct SearchCharactersUseCaseTests {
    private let repositoryMock = CharacterRepositoryProtocolMock()
    private let sut: SearchCharactersUseCase

    init() {
        sut = SearchCharactersUseCase(repository: repositoryMock)
    }

    @Test("Returns matching characters on success")
    func returnsMatchingCharactersOnSuccess() async throws {
        let expected = [DisneyCharacter.stub(id: 1, name: "Mickey Mouse")]
        repositoryMock.searchCharactersReturnValue = expected

        let result = try await sut.execute(name: "Mickey")

        #expect(result == expected)
    }

    @Test("Returns empty list when no characters match")
    func returnsEmptyListWhenNoMatch() async throws {
        repositoryMock.searchCharactersReturnValue = []

        let result = try await sut.execute(name: "unknown")

        #expect(result.isEmpty)
    }

    @Test("Passes correct name to repository")
    func passesCorrectNameToRepository() async throws {
        repositoryMock.searchCharactersReturnValue = []

        _ = try await sut.execute(name: "Elsa")

        #expect(repositoryMock.searchCharactersReceivedArguments == "Elsa")
    }

    @Test("Calls repository exactly once")
    func callsRepositoryExactlyOnce() async throws {
        repositoryMock.searchCharactersReturnValue = []

        _ = try await sut.execute(name: "Elsa")

        #expect(repositoryMock.searchCharactersCallsCount == 1)
    }

    @Test("Propagates no internet connection error")
    func propagatesNoInternetConnectionError() async {
        repositoryMock.searchCharactersThrowableError = DomainError.noInternetConnection

        await #expect(throws: DomainError.noInternetConnection) {
            _ = try await sut.execute(name: "Mickey")
        }
    }

    @Test("Propagates network failure error")
    func propagatesNetworkFailureError() async {
        repositoryMock.searchCharactersThrowableError = DomainError.networkFailure("Request timed out")

        await #expect(throws: DomainError.networkFailure("Request timed out")) {
            _ = try await sut.execute(name: "Mickey")
        }
    }
}
