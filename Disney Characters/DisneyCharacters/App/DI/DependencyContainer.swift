final class DependencyContainer {
    let characterRepository: CharacterRepositoryProtocol

    init() {
        let httpClient = URLSessionHTTPClient()
        let remote = CharacterRemoteDataSource(httpClient: httpClient)
        let local = CharacterLocalDataSource()
        characterRepository = DefaultCharacterRepository(remoteDataSource: remote, localDataSource: local)
    }
}
