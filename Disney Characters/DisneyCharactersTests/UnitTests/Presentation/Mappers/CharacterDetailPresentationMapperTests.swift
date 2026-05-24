import Foundation
import Testing
@testable import DisneyCharacters

@Suite("CharacterDetailPresentationMapper")
struct CharacterDetailPresentationMapperTests {

    @Test("Maps id and name from DisneyCharacter")
    func mapsIdAndName() {
        let character = DisneyCharacter.stub(id: 10, name: "Goofy")

        let result = CharacterDetailPresentationMapper.toPresentation(character)

        #expect(result.id == 10)
        #expect(result.name == "Goofy")
    }

    @Test("Maps valid imageURL string to URL")
    func mapsValidImageURLStringToURL() {
        let character = DisneyCharacter.stub(imageURL: "https://example.com/goofy.png")

        let result = CharacterDetailPresentationMapper.toPresentation(character)

        #expect(result.imageURL == URL(string: "https://example.com/goofy.png"))
    }

    @Test("Maps nil imageURL string to nil URL")
    func mapsNilImageURLToNil() {
        let character = DisneyCharacter.stub(imageURL: nil)

        let result = CharacterDetailPresentationMapper.toPresentation(character)

        #expect(result.imageURL == nil)
    }

    @Test("Maps invalid imageURL string to nil URL")
    func mapsInvalidImageURLToNil() {
        let character = DisneyCharacter.stub(imageURL: "not a valid url ://")

        let result = CharacterDetailPresentationMapper.toPresentation(character)

        #expect(result.imageURL == nil)
    }

    @Test("Maps all array fields from DisneyCharacter")
    func mapsAllArrayFields() {
        let character = DisneyCharacter.stub(
            films: ["Fantasia"],
            shortFilms: ["The Simple Things"],
            tvShows: ["Mickey Mouse Clubhouse"],
            videoGames: ["Kingdom Hearts"],
            parkAttractions: ["Mickey's PhilharMagic"],
            allies: ["Minnie Mouse"],
            enemies: ["Pete"]
        )

        let result = CharacterDetailPresentationMapper.toPresentation(character)

        #expect(result.films == ["Fantasia"])
        #expect(result.shortFilms == ["The Simple Things"])
        #expect(result.tvShows == ["Mickey Mouse Clubhouse"])
        #expect(result.videoGames == ["Kingdom Hearts"])
        #expect(result.parkAttractions == ["Mickey's PhilharMagic"])
        #expect(result.allies == ["Minnie Mouse"])
        #expect(result.enemies == ["Pete"])
    }

    @Test("Maps empty arrays correctly")
    func mapsEmptyArrays() {
        let character = DisneyCharacter.stub(
            films: [], shortFilms: [], tvShows: [], videoGames: [],
            parkAttractions: [], allies: [], enemies: []
        )

        let result = CharacterDetailPresentationMapper.toPresentation(character)

        #expect(result.films.isEmpty)
        #expect(result.shortFilms.isEmpty)
        #expect(result.tvShows.isEmpty)
        #expect(result.videoGames.isEmpty)
        #expect(result.parkAttractions.isEmpty)
        #expect(result.allies.isEmpty)
        #expect(result.enemies.isEmpty)
    }
}
