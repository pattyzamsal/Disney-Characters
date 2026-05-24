import Foundation

struct CharacterListResponseDTO: Decodable {
    let info: PaginationInfoDTO
    let data: [CharacterDTO]
}
