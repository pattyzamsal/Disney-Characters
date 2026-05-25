import Foundation
import Testing
@testable import DisneyCharacters

extension CharacterPresentationModel {
    static func stub(
        id: Int = 1,
        name: String = "Mickey Mouse",
        imageURL: URL? = URL(string: "https://example.com/mickey.png")
    ) -> CharacterPresentationModel {
        CharacterPresentationModel(
            id: id,
            name: name,
            imageURL: imageURL
        )
    }
}
