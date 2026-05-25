import Foundation

enum CharacterDetailPresentationMapper {
    static func toPresentation(_ character: DisneyCharacter) -> CharacterDetailPresentationModel {
        CharacterDetailPresentationModel(
            id: character.id,
            name: character.name,
            imageURL: character.imageURL.flatMap(URL.init(string:)),
            films: character.films,
            shortFilms: character.shortFilms,
            tvShows: character.tvShows,
            videoGames: character.videoGames,
            parkAttractions: character.parkAttractions,
            allies: character.allies,
            enemies: character.enemies
        )
    }
}
