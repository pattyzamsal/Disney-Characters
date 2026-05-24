// sourcery: AutoMockable
protocol GetCharacterDetailUseCaseProtocol {
    func execute(id: Int) async throws -> Character
}

final class GetCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Character {
        try await repository.getCharacterDetail(id: id)
    }
}
