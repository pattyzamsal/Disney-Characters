import Testing
@testable import DisneyCharacters

extension DisneyCharacter {
    static func stub(
        id: Int = 1,
        name: String = "Mickey Mouse",
        imageURL: String? = "https://example.com/mickey.png",
        films: [String] = ["Fantasia"],
        shortFilms: [String] = ["The Simple Things"],
        tvShows: [String] = ["Mickey Mouse Clubhouse"],
        videoGames: [String] = ["Kingdom Hearts"],
        parkAttractions: [String] = ["Mickey's PhilharMagic"],
        allies: [String] = ["Minnie Mouse"],
        enemies: [String] = ["Pete"]
    ) -> DisneyCharacter {
        DisneyCharacter(
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
