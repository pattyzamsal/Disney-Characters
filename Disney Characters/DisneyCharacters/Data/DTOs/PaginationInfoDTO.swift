import Foundation

struct PaginationInfoDTO: Decodable {
    let totalPages: Int
    let count: Int
    let previousPage: String?
    let nextPage: String?
}
