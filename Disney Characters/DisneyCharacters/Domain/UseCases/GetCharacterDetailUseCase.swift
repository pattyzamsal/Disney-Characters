// sourcery: AutoMockable
protocol GetCharacterDetailUseCaseProtocol: Sendable {
    func execute(id: Int) async throws -> DisneyCharacter
}

final class GetCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> DisneyCharacter {
        try await repository.getCharacterDetail(id: id)
    }
}
