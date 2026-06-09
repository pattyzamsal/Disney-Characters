import Foundation

// sourcery: AutoMockable
protocol CharacterRemoteDataSourceProtocol: Sendable {
    func getCharacters(page: Int) async throws -> CharacterListResponseDTO
    func getCharacterDetail(id: Int) async throws -> CharacterDTO
    func searchCharacters(name: String) async throws -> CharacterListResponseDTO
}

final class CharacterRemoteDataSource {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
}

extension CharacterRemoteDataSource: CharacterRemoteDataSourceProtocol {
    func getCharacters(page: Int) async throws -> CharacterListResponseDTO {
        let endpoint = Endpoint(
            path: AppConfiguration.PathName.characters,
            queryItems: [
                URLQueryItem(name: AppConfiguration.QueryKeyName.page, value: "\(page)"),
                URLQueryItem(name: AppConfiguration.QueryKeyName.pageSize, value: "\(AppConfiguration.pageSize)")
            ]
        )
        return try await httpClient.perform(endpoint)
    }

    func getCharacterDetail(id: Int) async throws -> CharacterDTO {
        let endpoint = Endpoint(path: AppConfiguration.PathName.characterDetail(id: id))
        let response: CharacterDetailResponseDTO = try await httpClient.perform(endpoint)
        return response.data
    }

    func searchCharacters(name: String) async throws -> CharacterListResponseDTO {
        let endpoint = Endpoint(
            path: AppConfiguration.PathName.characters,
            queryItems: [URLQueryItem(name: AppConfiguration.QueryKeyName.name, value: name)]
        )
        return try await httpClient.perform(endpoint)
    }
}
