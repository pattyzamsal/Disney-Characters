import Foundation

enum AppConfiguration {
    static let pageSize = 50

    enum PathName {
        static let characters = "/character"
        static func characterDetail(id: Int) -> String { "/character/\(id)" }
    }

    enum QueryKeyName {
        static let page = "page"
        static let pageSize = "pageSize"
        static let name = "name"
    }
}
