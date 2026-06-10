import Testing
@testable import DisneyCharacters

@Suite("GetCharactersUseCase")
struct GetCharactersUseCaseTests {
    private let repositoryMock = CharacterRepositoryProtocolMock()
    private let sut: GetCharactersUseCase

    init() {
        sut = GetCharactersUseCase(repository: repositoryMock)
    }

    @Test("Returns characters and pagination info on success")
    func returnsCharactersAndInfoOnSuccess() async throws {
        let expectedCharacters = [DisneyCharacter.stub(), DisneyCharacter.stub(id: 2, name: "Minnie Mouse")]
        let expectedInfo = PaginationInfo.stub()
        repositoryMock.getCharactersReturnValue = (expectedCharacters, expectedInfo)

        let result = try await sut.execute(page: 1, forceRefresh: false)

        #expect(result.characters == expectedCharacters)
        #expect(result.info == expectedInfo)
    }

    @Test("Passes correct page number to repository")
    func passesCorrectPageToRepository() async throws {
        repositoryMock.getCharactersReturnValue = ([], PaginationInfo.stub())

        _ = try await sut.execute(page: 5, forceRefresh: false)

        #expect(repositoryMock.getCharactersReceivedArguments?.page == 5)
    }

    @Test("Calls repository exactly once")
    func callsRepositoryExactlyOnce() async throws {
        repositoryMock.getCharactersReturnValue = ([], PaginationInfo.stub())

        _ = try await sut.execute(page: 1, forceRefresh: false)

        #expect(repositoryMock.getCharactersCallsCount == 1)
    }

    @Test("Forwards forceRefresh true to repository")
    func forwardsForceRefreshTrue() async throws {
        repositoryMock.getCharactersReturnValue = ([], PaginationInfo.stub())

        _ = try await sut.execute(page: 1, forceRefresh: true)

        #expect(repositoryMock.getCharactersReceivedArguments?.forceRefresh == true)
    }

    @Test("Forwards forceRefresh false to repository")
    func forwardsForceRefreshFalse() async throws {
        repositoryMock.getCharactersReturnValue = ([], PaginationInfo.stub())

        _ = try await sut.execute(page: 1, forceRefresh: false)

        #expect(repositoryMock.getCharactersReceivedArguments?.forceRefresh == false)
    }

    @Test("Propagates no internet connection error")
    func propagatesNoInternetConnectionError() async {
        repositoryMock.getCharactersThrowableError = DomainError.noInternetConnection

        await #expect(throws: DomainError.noInternetConnection) {
            _ = try await sut.execute(page: 1, forceRefresh: false)
        }
    }

    @Test("Propagates network failure error")
    func propagatesNetworkFailureError() async {
        repositoryMock.getCharactersThrowableError = DomainError.networkFailure("Server error: 500")

        await #expect(throws: DomainError.networkFailure("Server error: 500")) {
            _ = try await sut.execute(page: 1, forceRefresh: false)
        }
    }
}
