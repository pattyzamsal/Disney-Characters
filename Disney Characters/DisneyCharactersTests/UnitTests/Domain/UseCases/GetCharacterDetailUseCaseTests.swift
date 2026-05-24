import Testing
@testable import DisneyCharacters

@Suite("GetCharacterDetailUseCase")
struct GetCharacterDetailUseCaseTests {
    private let repositoryMock = CharacterRepositoryProtocolMock()
    private let sut: GetCharacterDetailUseCase

    init() {
        sut = GetCharacterDetailUseCase(repository: repositoryMock)
    }

    @Test("Returns character on success")
    func returnsCharacterOnSuccess() async throws {
        let expected = DisneyCharacter.stub(id: 42, name: "Hercules")
        repositoryMock.getCharacterDetailReturnValue = expected

        let result = try await sut.execute(id: 42)

        #expect(result == expected)
    }

    @Test("Passes correct id to repository")
    func passesCorrectIdToRepository() async throws {
        repositoryMock.getCharacterDetailReturnValue = DisneyCharacter.stub()

        _ = try await sut.execute(id: 112)

        #expect(repositoryMock.getCharacterDetailReceivedArguments == 112)
    }

    @Test("Calls repository exactly once")
    func callsRepositoryExactlyOnce() async throws {
        repositoryMock.getCharacterDetailReturnValue = DisneyCharacter.stub()

        _ = try await sut.execute(id: 1)

        #expect(repositoryMock.getCharacterDetailCallsCount == 1)
    }

    @Test("Propagates character not found error")
    func propagatesCharacterNotFoundError() async {
        repositoryMock.getCharacterDetailThrowableError = DomainError.characterNotFound

        await #expect(throws: DomainError.characterNotFound) {
            _ = try await sut.execute(id: 999)
        }
    }

    @Test("Propagates no internet connection error")
    func propagatesNoInternetConnectionError() async {
        repositoryMock.getCharacterDetailThrowableError = DomainError.noInternetConnection

        await #expect(throws: DomainError.noInternetConnection) {
            _ = try await sut.execute(id: 1)
        }
    }
}
