import Foundation
import Testing
@testable import DisneyCharacters

@Suite("CharacterLocalDataSource")
struct CharacterLocalDataSourceTests {

    // MARK: - Single-threaded behaviour

    @Test("Stores and returns cached characters per page")
    func storesAndReturnsCachedCharactersPerPage() async {
        let sut = CharacterLocalDataSource()
        let page1 = [DisneyCharacter.stub(id: 1), DisneyCharacter.stub(id: 2, name: "Minnie")]
        let page2 = [DisneyCharacter.stub(id: 3, name: "Donald")]

        await sut.cacheCharacters(page1, page: 1)
        await sut.cacheCharacters(page2, page: 2)

        let cachedPage1 = await sut.getCachedCharacters(page: 1)
        let cachedPage2 = await sut.getCachedCharacters(page: 2)
        #expect(cachedPage1 == page1)
        #expect(cachedPage2 == page2)
    }

    @Test("Caching a page also adds characters to the by-id lookup")
    func cachingPagePopulatesById() async {
        let sut = CharacterLocalDataSource()
        let character = DisneyCharacter.stub(id: 42, name: "Goofy")

        await sut.cacheCharacters([character], page: 1)
        let fetched = await sut.getCachedCharacter(id: 42)

        #expect(fetched == character)
    }

    @Test("Re-caching a page replaces previous characters for that page")
    func recachingPageReplacesContents() async {
        let sut = CharacterLocalDataSource()
        await sut.cacheCharacters([DisneyCharacter.stub(id: 1, name: "Original")], page: 1)

        let updated = [DisneyCharacter.stub(id: 1, name: "Updated")]
        await sut.cacheCharacters(updated, page: 1)
        let cached = await sut.getCachedCharacters(page: 1)

        #expect(cached?.first?.name == "Updated")
    }

    @Test("searchCachedCharacters matches case-insensitively across cached entries")
    func searchMatchesCaseInsensitively() async {
        let sut = CharacterLocalDataSource()
        await sut.mergeCharacters([
            DisneyCharacter.stub(id: 1, name: "Mickey Mouse"),
            DisneyCharacter.stub(id: 2, name: "Minnie Mouse"),
            DisneyCharacter.stub(id: 3, name: "Donald Duck")
        ])

        let results = await sut.searchCachedCharacters(name: "mouse")

        #expect(results.count == 2)
        #expect(results.allSatisfy { $0.name.contains("Mouse") })
    }

    @Test("mergeCharacters overwrites existing entries by id")
    func mergeOverwritesById() async {
        let sut = CharacterLocalDataSource()
        await sut.mergeCharacters([DisneyCharacter.stub(id: 1, name: "Original")])

        await sut.mergeCharacters([DisneyCharacter.stub(id: 1, name: "Updated")])
        let fetched = await sut.getCachedCharacter(id: 1)

        #expect(fetched?.name == "Updated")
    }

    // MARK: - Concurrency safety (regression test for the race the actor closes)

    @Test("Concurrent merges do not lose writes")
    func concurrentMergesDoNotLoseWrites() async {
        let sut = CharacterLocalDataSource()
        let characterCount = 200

        await withTaskGroup(of: Void.self) { group in
            for index in 1...characterCount {
                group.addTask {
                    await sut.mergeCharacters([DisneyCharacter.stub(id: index, name: "Character \(index)")])
                }
            }
        }

        var observed = Set<Int>()
        for index in 1...characterCount {
            if let character = await sut.getCachedCharacter(id: index) {
                observed.insert(character.id)
            }
        }
        #expect(observed.count == characterCount)
    }

    @Test("Concurrent page caches and reads stay consistent")
    func concurrentPageCachesStayConsistent() async {
        let sut = CharacterLocalDataSource()
        let pageCount = 50

        await withTaskGroup(of: Void.self) { group in
            for page in 1...pageCount {
                group.addTask {
                    await sut.cacheCharacters([DisneyCharacter.stub(id: page, name: "P\(page)")], page: page)
                    await sut.cachePaginationInfo(
                        PaginationInfo(totalPages: pageCount, count: 1, previousPage: nil, nextPage: nil),
                        page: page
                    )
                }
            }
        }

        for page in 1...pageCount {
            let cached = await sut.getCachedCharacters(page: page)
            let info = await sut.getCachedPaginationInfo(page: page)
            #expect(cached?.first?.name == "P\(page)")
            #expect(info != nil)
        }
    }
}
