import Testing
@testable import DisneyCharacters

extension CharacterListResponseDTO {
    static func stub(
        info: PaginationInfoDTO = .stub(),
        data: [CharacterDTO] = [.stub()]
    ) -> CharacterListResponseDTO {
        CharacterListResponseDTO(info: info, data: data)
    }
}
