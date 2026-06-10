import Testing
@testable import DisneyCharacters

extension PaginationInfo {
    static func stub(
        nextPage: String? = "https://api.disneyapi.dev/character?page=2&pageSize=50"
    ) -> PaginationInfo {
        PaginationInfo(hasNextPage: nextPage != nil)
    }
}
