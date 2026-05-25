import Testing
@testable import DisneyCharacters

extension CharacterDTO {
    static func stub(
        id: Int = 1,
        name: String = "Mickey Mouse",
        imageUrl: String? = "https://example.com/mickey.png",
        films: [String] = ["Fantasia"],
        shortFilms: [String] = ["The Simple Things"],
        tvShows: [String] = ["Mickey Mouse Clubhouse"],
        videoGames: [String] = ["Kingdom Hearts"],
        parkAttractions: [String] = ["Mickey's PhilharMagic"],
        allies: [String] = ["Minnie Mouse"],
        enemies: [String] = ["Pete"],
        url: String? = "https://api.disneyapi.dev/character/1"
    ) -> CharacterDTO {
        CharacterDTO(
            id: id,
            name: name,
            imageUrl: imageUrl,
            films: films,
            shortFilms: shortFilms,
            tvShows: tvShows,
            videoGames: videoGames,
            parkAttractions: parkAttractions,
            allies: allies,
            enemies: enemies,
            url: url
        )
    }
}
