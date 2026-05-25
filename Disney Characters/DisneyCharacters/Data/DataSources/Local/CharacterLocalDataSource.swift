import Foundation

// sourcery: AutoMockable
protocol CharacterLocalDataSourceProtocol {
    func getCachedCharacters(page: Int) -> [DisneyCharacter]?
    func cacheCharacters(_ characters: [DisneyCharacter], page: Int)
    func getCachedPaginationInfo(page: Int) -> PaginationInfo?
    func cachePaginationInfo(_ info: PaginationInfo, page: Int)
    func getCachedCharacter(id: Int) -> DisneyCharacter?
    func searchCachedCharacters(name: String) -> [DisneyCharacter]
    func mergeCharacters(_ characters: [DisneyCharacter])
}

final class CharacterLocalDataSource {
    private var characterCache: [Int: DisneyCharacter] = [:]
    private var pageCache: [Int: [DisneyCharacter]] = [:]
    private var paginationCache: [Int: PaginationInfo] = [:]
}

extension CharacterLocalDataSource: CharacterLocalDataSourceProtocol {
    func getCachedCharacters(page: Int) -> [DisneyCharacter]? {
        pageCache[page]
    }

    func cacheCharacters(_ characters: [DisneyCharacter], page: Int) {
        pageCache[page] = characters
        characters.forEach { characterCache[$0.id] = $0 }
    }

    func getCachedPaginationInfo(page: Int) -> PaginationInfo? {
        paginationCache[page]
    }

    func cachePaginationInfo(_ info: PaginationInfo, page: Int) {
        paginationCache[page] = info
    }

    func getCachedCharacter(id: Int) -> DisneyCharacter? {
        characterCache[id]
    }

    func searchCachedCharacters(name: String) -> [DisneyCharacter] {
        characterCache.values.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }

    func mergeCharacters(_ characters: [DisneyCharacter]) {
        characters.forEach { characterCache[$0.id] = $0 }
    }
}
