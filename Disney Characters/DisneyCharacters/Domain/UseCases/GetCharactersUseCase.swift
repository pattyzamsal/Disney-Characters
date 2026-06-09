// sourcery: AutoMockable
protocol GetCharactersUseCaseProtocol: Sendable {
    func execute(page: Int, forceRefresh: Bool) async throws -> (characters: [DisneyCharacter], info: PaginationInfo)
}

final class GetCharactersUseCase: GetCharactersUseCaseProtocol {
    private let repository: CharacterRepositoryProtocol

    init(repository: CharacterRepositoryProtocol) {
        self.repository = repository
    }

    func execute(page: Int, forceRefresh: Bool) async throws -> (characters: [DisneyCharacter], info: PaginationInfo) {
        try await repository.getCharacters(page: page, forceRefresh: forceRefresh)
    }
}
