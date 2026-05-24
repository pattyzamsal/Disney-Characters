import Testing
@testable import DisneyCharacters

extension PaginationInfoDTO {
    static func stub(
        totalPages: Int = 149,
        count: Int = 50,
        previousPage: String? = nil,
        nextPage: String? = "https://api.disneyapi.dev/character?page=2&pageSize=50"
    ) -> PaginationInfoDTO {
        PaginationInfoDTO(
            totalPages: totalPages,
            count: count,
            previousPage: previousPage,
            nextPage: nextPage
        )
    }
}
