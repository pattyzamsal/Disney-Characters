import Foundation
import Testing
@testable import DisneyCharacters

@Suite("CharacterPresentationMapper")
struct CharacterPresentationMapperTests {

    @Test("Maps id and name from DisneyCharacter")
    func mapsIdAndName() {
        let character = DisneyCharacter.stub(id: 42, name: "Donald Duck")

        let result = CharacterPresentationMapper.toPresentation(character)

        #expect(result.id == 42)
        #expect(result.name == "Donald Duck")
    }

    @Test("Maps valid imageURL string to URL")
    func mapsValidImageURLStringToURL() {
        let character = DisneyCharacter.stub(imageURL: "https://example.com/donald.png")

        let result = CharacterPresentationMapper.toPresentation(character)

        #expect(result.imageURL == URL(string: "https://example.com/donald.png"))
    }

    @Test("Maps nil imageURL string to nil URL")
    func mapsNilImageURLToNil() {
        let character = DisneyCharacter.stub(imageURL: nil)

        let result = CharacterPresentationMapper.toPresentation(character)

        #expect(result.imageURL == nil)
    }

    @Test("Maps invalid imageURL string to nil URL")
    func mapsInvalidImageURLToNil() {
        let character = DisneyCharacter.stub(imageURL: "not a valid url ://")

        let result = CharacterPresentationMapper.toPresentation(character)

        #expect(result.imageURL == nil)
    }

    @Test("Mapped model satisfies Identifiable with correct id")
    func mappedModelIsIdentifiable() {
        let character = DisneyCharacter.stub(id: 7)

        let result = CharacterPresentationMapper.toPresentation(character)

        #expect(result.id == 7)
    }
}
