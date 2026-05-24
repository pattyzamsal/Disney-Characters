import Foundation

// sourcery: AutoMockable
protocol CharacterLocalDataSourceProtocol {
    func getCachedCharacters(page: Int) -> [Character]?
    func cacheCharacters(_ characters: [Character], page: Int)
    func getCachedPaginationInfo(page: Int) -> PaginationInfo?
    func cachePaginationInfo(_ info: PaginationInfo, page: Int)
    func getCachedCharacter(id: Int) -> Character?
    func searchCachedCharacters(name: String) -> [Character]
    func mergeCharacters(_ characters: [Character])
}

final class CharacterLocalDataSource {
    private var characterCache: [Int: Character] = [:]
    private var pageCache: [Int: [Character]] = [:]
    private var paginationCache: [Int: PaginationInfo] = [:]
}

extension CharacterLocalDataSource: CharacterLocalDataSourceProtocol {
    func getCachedCharacters(page: Int) -> [Character]? {
        pageCache[page]
    }

    func cacheCharacters(_ characters: [Character], page: Int) {
        pageCache[page] = characters
        characters.forEach { characterCache[$0.id] = $0 }
    }

    func getCachedPaginationInfo(page: Int) -> PaginationInfo? {
        paginationCache[page]
    }

    func cachePaginationInfo(_ info: PaginationInfo, page: Int) {
        paginationCache[page] = info
    }

    func getCachedCharacter(id: Int) -> Character? {
        characterCache[id]
    }

    func searchCachedCharacters(name: String) -> [Character] {
        characterCache.values.filter { $0.name.localizedCaseInsensitiveContains(name) }
    }

    func mergeCharacters(_ characters: [Character]) {
        characters.forEach { characterCache[$0.id] = $0 }
    }
}
