import Testing
@testable import DisneyCharacters

extension PaginationInfo {
    static func stub(
        totalPages: Int = 149,
        count: Int = 50,
        previousPage: String? = nil,
        nextPage: String? = "https://api.disneyapi.dev/character?page=2&pageSize=50"
    ) -> PaginationInfo {
        PaginationInfo(
            totalPages: totalPages,
            count: count,
            previousPage: previousPage,
            nextPage: nextPage
        )
    }
}
