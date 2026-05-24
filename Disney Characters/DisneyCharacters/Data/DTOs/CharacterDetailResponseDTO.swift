import Foundation

// The detail endpoint returns a single character object under `data`, not an array.
struct CharacterDetailResponseDTO: Decodable {
    let info: PaginationInfoDTO
    let data: CharacterDTO
}
