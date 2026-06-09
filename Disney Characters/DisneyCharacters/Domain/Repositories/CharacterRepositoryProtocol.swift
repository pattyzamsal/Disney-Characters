// sourcery: AutoMockable
protocol CharacterRepositoryProtocol {
    func getCharacters(page: Int, forceRefresh: Bool) async throws -> (characters: [DisneyCharacter], info: PaginationInfo)
    func getCharacterDetail(id: Int) async throws -> DisneyCharacter
    func searchCharacters(name: String) async throws -> [DisneyCharacter]
}
