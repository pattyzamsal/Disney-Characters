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

    @Test("hasNextPage is true when nextPage is present")
    func hasNextPageTrueWhenNextPagePresent() {
        let dto = PaginationInfoDTO.stub(nextPage: "https://api.disneyapi.dev/character?page=2")

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.hasNextPage == true)
    }

    @Test("hasNextPage is false when nextPage is nil")
    func hasNextPageFalseWhenNextPageNil() {
        let dto = PaginationInfoDTO.stub(nextPage: nil)

        let result = CharacterDTOMapper.toDomain(dto)

        #expect(result.hasNextPage == false)
    }
}
