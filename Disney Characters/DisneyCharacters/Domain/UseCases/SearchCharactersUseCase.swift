// sourcery: AutoMockable
protocol SearchCharactersUseCaseProtocol: Sendable {
    func execute(name: String) async throws -> [DisneyCharacter]
}

final class SearchCharactersUseCase: SearchCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String) async throws -> [DisneyCharacter] {
        try await repository.searchCharacters(name: name)
    }
}
