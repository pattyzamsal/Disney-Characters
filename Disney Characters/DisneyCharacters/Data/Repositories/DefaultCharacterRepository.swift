import Foundation

final class DefaultCharacterRepository {
    private let remoteDataSource: CharacterRemoteDataSourceProtocol
    private let localDataSource: CharacterLocalDataSourceProtocol
    
    init(remoteDataSource: CharacterRemoteDataSourceProtocol,
         localDataSource: CharacterLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
}

extension DefaultCharacterRepository: CharacterRepositoryProtocol {
    func getCharacters(page: Int, forceRefresh: Bool) async throws -> (characters: [DisneyCharacter], info: PaginationInfo) {
        if !forceRefresh,
           let cachedCharacters = localDataSource.getCachedCharacters(page: page),
           let cachedInfo = localDataSource.getCachedPaginationInfo(page: page) {
            return (cachedCharacters, cachedInfo)
        }
        do {
            let response = try await remoteDataSource.getCharacters(page: page)
            let characters = response.data.map { CharacterDTOMapper.toDomain($0) }
            let info = CharacterDTOMapper.toDomain(response.info)
            localDataSource.cacheCharacters(characters, page: page)
            localDataSource.cachePaginationInfo(info, page: page)
            return (characters, info)
        } catch let error as NetworkError {
            throw error.toDomainError()
        }
    }

    func getCharacterDetail(id: Int) async throws -> DisneyCharacter {
        if let cached = localDataSource.getCachedCharacter(id: id) {
            return cached
        }
        do {
            let dto = try await remoteDataSource.getCharacterDetail(id: id)
            return CharacterDTOMapper.toDomain(dto)
        } catch let error as NetworkError {
            throw error.toDomainError()
        }
    }

    func searchCharacters(name: String) async throws -> [DisneyCharacter] {
        let localResults = localDataSource.searchCachedCharacters(name: name)
        if !localResults.isEmpty {
            return localResults
        }
        do {
            let response = try await remoteDataSource.searchCharacters(name: name)
            let characters = response.data.map { CharacterDTOMapper.toDomain($0) }
            localDataSource.mergeCharacters(characters)
            return characters
        } catch let error as NetworkError {
            throw error.toDomainError()
        }
    }
}

private extension NetworkError {
    func toDomainError() -> DomainError {
        switch self {
        case .noConnection:
            return .noInternetConnection
        case .serverError(let statusCode) where statusCode == 404:
            return .characterNotFound
        case .serverError(let statusCode):
            return .networkFailure("Server error: \(statusCode)")
        case .decodingError:
            return .networkFailure("Failed to decode response")
        case .timeout:
            return .networkFailure("Request timed out")
        case .invalidURL:
            return .networkFailure("Not valid URL")
        case .noData, .unknown:
            return .unexpected
        }
    }
}
