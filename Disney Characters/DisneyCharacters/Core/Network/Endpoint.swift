import Foundation

struct Endpoint {
    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]

    init(path: String, method: HTTPMethod = .get, queryItems: [URLQueryItem] = []) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
    }

    func url(baseURL: String) throws -> URL {
        var components = URLComponents(string: baseURL + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        return url
    }
}
