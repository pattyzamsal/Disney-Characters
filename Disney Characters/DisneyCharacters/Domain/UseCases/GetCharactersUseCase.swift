// sourcery: AutoMockable
protocol GetCharactersUseCaseProtocol {
    func execute(page: Int) async throws -> (characters: [DisneyCharacter], info: PaginationInfo)
}

final class GetCharactersUseCase: GetCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int) async throws -> (characters: [DisneyCharacter], info: PaginationInfo) {
        try await repository.getCharacters(page: page)
    }
}
