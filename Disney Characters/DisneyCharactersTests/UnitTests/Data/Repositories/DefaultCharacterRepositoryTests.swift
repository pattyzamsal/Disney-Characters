import Testing
@testable import DisneyCharacters

@Suite("DefaultCharacterRepository")
struct DefaultCharacterRepositoryTests {

    // MARK: - getCharacters

    @Suite("getCharacters")
    struct GetCharactersTests {
        private let remoteMock = CharacterRemoteDataSourceProtocolMock()
        private let localMock = CharacterLocalDataSourceProtocolMock()
        private let sut: DefaultCharacterRepository

        init() {
            sut = DefaultCharacterRepository(remoteDataSource: remoteMock, localDataSource: localMock)
        }

        @Test("Returns cached data without calling remote when cache is populated")
        func returnsCachedDataWhenCacheIsPopulated() async throws {
            let cachedCharacters = [DisneyCharacter.stub()]
            let cachedInfo = PaginationInfo.stub()
            localMock.getCachedCharactersReturnValue = cachedCharacters
            localMock.getCachedPaginationInfoReturnValue = cachedInfo

            let result = try await sut.getCharacters(page: 1, forceRefresh: false)

            #expect(result.characters == cachedCharacters)
            #expect(result.info == cachedInfo)
            #expect(remoteMock.getCharactersCallsCount == 0)
        }

        @Test("Calls remote when characters cache is empty")
        func callsRemoteWhenCharactersCacheMisses() async throws {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter]?.none
            remoteMock.getCharactersReturnValue = .stub()

            _ = try await sut.getCharacters(page: 1, forceRefresh: false)

            #expect(remoteMock.getCharactersCallsCount == 1)
        }

        @Test("Calls remote when pagination cache is empty")
        func callsRemoteWhenPaginationCacheMisses() async throws {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter.stub()]
            localMock.getCachedPaginationInfoReturnValue = PaginationInfo?.none
            remoteMock.getCharactersReturnValue = .stub()

            _ = try await sut.getCharacters(page: 1, forceRefresh: false)

            #expect(remoteMock.getCharactersCallsCount == 1)
        }

        @Test("Maps remote response to domain models")
        func mapsRemoteResponseToDomainModels() async throws {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter]?.none
            let dto = CharacterDTO.stub(id: 42, name: "Donald Duck")
            let infoDTO = PaginationInfoDTO.stub(totalPages: 10, count: 25)
            remoteMock.getCharactersReturnValue = CharacterListResponseDTO.stub(info: infoDTO, data: [dto])

            let result = try await sut.getCharacters(page: 1, forceRefresh: false)

            #expect(result.characters.count == 1)
            #expect(result.characters[0].id == 42)
            #expect(result.characters[0].name == "Donald Duck")
            #expect(result.info.totalPages == 10)
            #expect(result.info.count == 25)
        }

        @Test("Caches characters and pagination info after remote fetch")
        func cachesDataAfterRemoteFetch() async throws {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter]?.none
            remoteMock.getCharactersReturnValue = .stub()

            _ = try await sut.getCharacters(page: 3, forceRefresh: false)

            #expect(localMock.cacheCharactersCalled)
            #expect(localMock.cacheCharactersReceivedArguments?.page == 3)
            #expect(localMock.cachePaginationInfoCalled)
            #expect(localMock.cachePaginationInfoReceivedArguments?.page == 3)
        }

        @Test("Throws noInternetConnection when remote has no connection")
        func throwsNoInternetConnectionError() async {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter]?.none
            remoteMock.getCharactersThrowableError = NetworkError.noConnection

            await #expect(throws: DomainError.noInternetConnection) {
                _ = try await sut.getCharacters(page: 1, forceRefresh: false)
            }
        }

        @Test("Throws characterNotFound when remote returns 404")
        func throwsCharacterNotFoundOn404() async {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter]?.none
            remoteMock.getCharactersThrowableError = NetworkError.serverError(statusCode: 404)

            await #expect(throws: DomainError.characterNotFound) {
                _ = try await sut.getCharacters(page: 1, forceRefresh: false)
            }
        }

        @Test("Throws networkFailure when remote returns 500")
        func throwsNetworkFailureOn500() async {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter]?.none
            remoteMock.getCharactersThrowableError = NetworkError.serverError(statusCode: 500)

            await #expect(throws: DomainError.networkFailure("Server error: 500")) {
                _ = try await sut.getCharacters(page: 1, forceRefresh: false)
            }
        }

        @Test("Throws unexpected when remote returns noData")
        func throwsUnexpectedOnNoData() async {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter]?.none
            remoteMock.getCharactersThrowableError = NetworkError.noData

            await #expect(throws: DomainError.unexpected) {
                _ = try await sut.getCharacters(page: 1, forceRefresh: false)
            }
        }

        @Test("Bypasses cache and calls remote when forceRefresh is true")
        func bypassesCacheWhenForceRefreshIsTrue() async throws {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter.stub()]
            localMock.getCachedPaginationInfoReturnValue = PaginationInfo.stub()
            remoteMock.getCharactersReturnValue = .stub()

            _ = try await sut.getCharacters(page: 1, forceRefresh: true)

            #expect(remoteMock.getCharactersCallsCount == 1)
            #expect(localMock.getCachedCharactersCallsCount == 0)
            #expect(localMock.getCachedPaginationInfoCallsCount == 0)
        }

        @Test("Overwrites cache with fresh data when forceRefresh is true")
        func overwritesCacheOnForceRefresh() async throws {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter.stub(id: 1, name: "Stale")]
            localMock.getCachedPaginationInfoReturnValue = PaginationInfo.stub()
            let freshDTO = CharacterDTO.stub(id: 1, name: "Fresh")
            remoteMock.getCharactersReturnValue = CharacterListResponseDTO.stub(data: [freshDTO])

            let result = try await sut.getCharacters(page: 1, forceRefresh: true)

            #expect(result.characters.count == 1)
            #expect(result.characters[0].name == "Fresh")
            #expect(localMock.cacheCharactersCalled)
            #expect(localMock.cacheCharactersReceivedArguments?.characters.first?.name == "Fresh")
            #expect(localMock.cachePaginationInfoCalled)
        }

        @Test("Propagates remote error without falling back to cache when forceRefresh is true")
        func propagatesErrorOnForceRefreshFailure() async {
            localMock.getCachedCharactersReturnValue = [DisneyCharacter.stub()]
            localMock.getCachedPaginationInfoReturnValue = PaginationInfo.stub()
            remoteMock.getCharactersThrowableError = NetworkError.noConnection

            await #expect(throws: DomainError.noInternetConnection) {
                _ = try await sut.getCharacters(page: 1, forceRefresh: true)
            }
            #expect(remoteMock.getCharactersCallsCount == 1)
        }
    }

    // MARK: - getCharacterDetail

    @Suite("getCharacterDetail")
    struct GetCharacterDetailTests {
        private let remoteMock = CharacterRemoteDataSourceProtocolMock()
        private let localMock = CharacterLocalDataSourceProtocolMock()
        private let sut: DefaultCharacterRepository

        init() {
            sut = DefaultCharacterRepository(remoteDataSource: remoteMock, localDataSource: localMock)
        }

        @Test("Returns cached character without calling remote")
        func returnsCachedCharacterWhenAvailable() async throws {
            let cached = DisneyCharacter.stub(id: 7)
            localMock.getCachedCharacterReturnValue = cached

            let result = try await sut.getCharacterDetail(id: 7)

            #expect(result == cached)
            #expect(remoteMock.getCharacterDetailCallsCount == 0)
        }

        @Test("Calls remote when character is not cached")
        func callsRemoteWhenNotCached() async throws {
            localMock.getCachedCharacterReturnValue = DisneyCharacter?.none
            remoteMock.getCharacterDetailReturnValue = .stub(id: 7)

            _ = try await sut.getCharacterDetail(id: 7)

            #expect(remoteMock.getCharacterDetailCallsCount == 1)
            #expect(remoteMock.getCharacterDetailReceivedArguments == 7)
        }

        @Test("Maps remote DTO to domain model")
        func mapsRemoteDTOToDomainModel() async throws {
            localMock.getCachedCharacterReturnValue = DisneyCharacter?.none
            let dto = CharacterDTO.stub(id: 99, name: "Goofy", imageUrl: nil)
            remoteMock.getCharacterDetailReturnValue = dto

            let result = try await sut.getCharacterDetail(id: 99)

            #expect(result.id == 99)
            #expect(result.name == "Goofy")
            #expect(result.imageURL == nil)
        }

        @Test("Throws noInternetConnection when remote has no connection")
        func throwsNoInternetConnectionError() async {
            localMock.getCachedCharacterReturnValue = DisneyCharacter?.none
            remoteMock.getCharacterDetailThrowableError = NetworkError.noConnection

            await #expect(throws: DomainError.noInternetConnection) {
                _ = try await sut.getCharacterDetail(id: 1)
            }
        }

        @Test("Throws characterNotFound when remote returns 404")
        func throwsCharacterNotFoundOn404() async {
            localMock.getCachedCharacterReturnValue = DisneyCharacter?.none
            remoteMock.getCharacterDetailThrowableError = NetworkError.serverError(statusCode: 404)

            await #expect(throws: DomainError.characterNotFound) {
                _ = try await sut.getCharacterDetail(id: 1)
            }
        }

        @Test("Throws networkFailure on decoding error")
        func throwsNetworkFailureOnDecodingError() async {
            localMock.getCachedCharacterReturnValue = DisneyCharacter?.none
            remoteMock.getCharacterDetailThrowableError = NetworkError.decodingError

            await #expect(throws: DomainError.networkFailure("Failed to decode response")) {
                _ = try await sut.getCharacterDetail(id: 1)
            }
        }
    }

    // MARK: - searchCharacters

    @Suite("searchCharacters")
    struct SearchCharactersTests {
        private let remoteMock = CharacterRemoteDataSourceProtocolMock()
        private let localMock = CharacterLocalDataSourceProtocolMock()
        private let sut: DefaultCharacterRepository

        init() {
            sut = DefaultCharacterRepository(remoteDataSource: remoteMock, localDataSource: localMock)
        }

        @Test("Always calls remote regardless of local cache state")
        func alwaysCallsRemote() async throws {
            remoteMock.searchCharactersReturnValue = .stub(data: [.stub(name: "Mickey Mouse")])

            _ = try await sut.searchCharacters(name: "Mickey")

            #expect(remoteMock.searchCharactersCallsCount == 1)
            #expect(remoteMock.searchCharactersReceivedArguments == "Mickey")
        }

        @Test("Maps remote search response to domain models")
        func mapsRemoteSearchResponseToDomainModels() async throws {
            let dto = CharacterDTO.stub(id: 5, name: "Pluto")
            remoteMock.searchCharactersReturnValue = CharacterListResponseDTO.stub(data: [dto])

            let result = try await sut.searchCharacters(name: "Pluto")

            #expect(result.count == 1)
            #expect(result[0].id == 5)
            #expect(result[0].name == "Pluto")
        }

        @Test("Merges remote results into local cache after search")
        func mergesRemoteResultsIntoLocalCache() async throws {
            remoteMock.searchCharactersReturnValue = .stub(data: [.stub(id: 5)])

            _ = try await sut.searchCharacters(name: "Pluto")

            #expect(localMock.mergeCharactersCalled)
            #expect(localMock.mergeCharactersReceivedArguments?.count == 1)
            #expect(localMock.mergeCharactersReceivedArguments?[0].id == 5)
        }

        @Test("Throws noInternetConnection when remote has no connection")
        func throwsNoInternetConnectionError() async {
            remoteMock.searchCharactersThrowableError = NetworkError.noConnection

            await #expect(throws: DomainError.noInternetConnection) {
                _ = try await sut.searchCharacters(name: "Mickey")
            }
        }

        @Test("Throws networkFailure on timeout")
        func throwsNetworkFailureOnTimeout() async {
            remoteMock.searchCharactersThrowableError = NetworkError.timeout

            await #expect(throws: DomainError.networkFailure("Request timed out")) {
                _ = try await sut.searchCharacters(name: "Mickey")
            }
        }
    }
}
