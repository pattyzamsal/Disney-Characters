// sourcery: AutoMockable
protocol CharacterRepositoryProtocol {
    func getCharacters(page: Int) async throws -> (characters: [Character], info: PaginationInfo)
    func getCharacterDetail(id: Int) async throws -> Character
    func searchCharacters(name: String) async throws -> [Character]
}
