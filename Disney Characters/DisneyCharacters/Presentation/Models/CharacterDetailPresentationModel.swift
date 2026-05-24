import Foundation

struct CharacterDetailPresentationModel: Equatable {
    let id: Int
    let name: String
    let imageURL: URL?
    let films: [String]
    let shortFilms: [String]
    let tvShows: [String]
    let videoGames: [String]
    let parkAttractions: [String]
    let allies: [String]
    let enemies: [String]
}
