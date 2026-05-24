import Foundation

struct CharacterDTO: Decodable {
    let id: Int
    let name: String
    let imageUrl: String?
    let films: [String]
    let shortFilms: [String]
    let tvShows: [String]
    let videoGames: [String]
    let parkAttractions: [String]
    let allies: [String]
    let enemies: [String]
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case imageUrl
        case films
        case shortFilms
        case tvShows
        case videoGames
        case parkAttractions
        case allies
        case enemies
        case url
    }
}
