import Testing
@testable import DisneyCharacters

@Suite("CharacterDTOMapper")
struct CharacterDTOMapperTests {

    // MARK: - CharacterDTO → DisneyCharacter

    @Test("Maps all fields from CharacterDTO to DisneyCharacter")
    func mapsAllFieldsFromCharacterDTO() {
        let dto = CharacterDTO.stub()

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.id == dto.id)
        #expect(result.name == dto.name)
        #expect(result.imageURL == dto.imageUrl)
        #expect(result.films == dto.films)
        #expect(result.shortFilms == dto.shortFilms)
        #expect(result.tvShows == dto.tvShows)
        #expect(result.videoGames == dto.videoGames)
        #expect(result.parkAttractions == dto.parkAttractions)
        #expect(result.allies == dto.allies)
        #expect(result.enemies == dto.enemies)
    }

    @Test("Maps optional imageURL as nil when absent")
    func mapsNilImageURL() {
        let dto = CharacterDTO.stub(imageUrl: nil)

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.imageURL == nil)
    }

    @Test("Maps optional imageURL when present")
    func mapsImageURLWhenPresent() {
        let dto = CharacterDTO.stub(imageUrl: "https://example.com/character.png")

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.imageURL == "https://example.com/character.png")
    }

    @Test("Maps empty arrays correctly")
    func mapsEmptyArrayFields() {
        let dto = CharacterDTO.stub(films: [], shortFilms: [], tvShows: [], videoGames: [],
                                    parkAttractions: [], allies: [], enemies: [])

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.films.isEmpty)
        #expect(result.shortFilms.isEmpty)
        #expect(result.tvShows.isEmpty)
        #expect(result.videoGames.isEmpty)
        #expect(result.parkAttractions.isEmpty)
        #expect(result.allies.isEmpty)
        #expect(result.enemies.isEmpty)
    }

    @Test("Does not map url field from CharacterDTO")
    func doesNotMapURLField() {
        let dto = CharacterDTO.stub(url: "https://api.disneyapi.dev/character/1")

        let result = CharacterDTOMapper.toDomain(dto)

        // DisneyCharacter has no url property — this confirms the mapper intentionally drops it
        #expect(result.id == dto.id)
    }

    // MARK: - PaginationInfoDTO → PaginationInfo

    @Test("Maps all fields from PaginationInfoDTO to PaginationInfo")
    func mapsAllFieldsFromPaginationInfoDTO() {
        let dto = PaginationInfoDTO.stub()

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.totalPages == dto.totalPages)
        #expect(result.count == dto.count)
        #expect(result.previousPage == dto.previousPage)
        #expect(result.nextPage == dto.nextPage)
    }

    @Test("Maps nil previousPage")
    func mapsNilPreviousPage() {
        let dto = PaginationInfoDTO.stub(previousPage: nil)

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.previousPage == nil)
    }

    @Test("Maps nil nextPage on last page")
    func mapsNilNextPageOnLastPage() {
        let dto = PaginationInfoDTO.stub(nextPage: nil)

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.nextPage == nil)
    }

    @Test("Maps both page links when present")
    func mapsBothPageLinks() {
        let dto = PaginationInfoDTO.stub(
            previousPage: "https://api.disneyapi.dev/character?page=1",
            nextPage: "https://api.disneyapi.dev/character?page=3"
        )

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.previousPage == "https://api.disneyapi.dev/character?page=1")
        #expect(result.nextPage == "https://api.disneyapi.dev/character?page=3")
    }
}
