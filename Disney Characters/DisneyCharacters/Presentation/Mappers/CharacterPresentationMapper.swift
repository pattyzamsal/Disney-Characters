import Foundation

enum CharacterPresentationMapper {
    static func toPresentation(_ character: DisneyCharacter) -> CharacterPresentationModel {
        CharacterPresentationModel(
            id: character.id,
            name: character.name,
            imageURL: character.imageURL.flatMap(URL.init(string:))
        )
    }
}
