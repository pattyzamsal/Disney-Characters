// sourcery: AutoMockable
protocol SearchCharactersUseCaseProtocol {
    func execute(name: String) async throws -> [Character]
}

final class SearchCharactersUseCase: SearchCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(name: String) async throws -> [Character] {
        try await repository.searchCharacters(name: name)
    }
}
