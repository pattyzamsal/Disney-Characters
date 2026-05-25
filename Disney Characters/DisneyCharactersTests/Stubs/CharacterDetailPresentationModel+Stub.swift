import Foundation
@testable import DisneyCharacters

extension CharacterDetailPresentationModel {
    static func stub(
        id: Int = 1,
        name: String = "Mickey Mouse",
        imageURL: URL? = nil,
        films: [String] = ["Fantasia", "Fun and Fancy Free"],
        shortFilms: [String] = ["The Simple Things"],
        tvShows: [String] = ["Mickey Mouse Clubhouse"],
        videoGames: [String] = ["Kingdom Hearts"],
        parkAttractions: [String] = ["Mickey's PhilharMagic"],
        allies: [String] = ["Minnie Mouse"],
        enemies: [String] = ["Pete"]
    ) -> CharacterDetailPresentationModel {
        CharacterDetailPresentationModel(
            id: id,
            name: name,
            imageURL: imageURL,
            films: films,
            shortFilms: shortFilms,
            tvShows: tvShows,
            videoGames: videoGames,
            parkAttractions: parkAttractions,
            allies: allies,
            enemies: enemies
        )
    }
}
