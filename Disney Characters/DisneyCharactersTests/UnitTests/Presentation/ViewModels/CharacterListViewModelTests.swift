import Foundation
import SwiftUI
import Testing
@testable import DisneyCharacters

@MainActor
@Suite("CharacterListViewModel")
struct CharacterListViewModelTests {
    private let getCharactersMock = GetCharactersUseCaseProtocolMock()
    private let searchCharactersMock = SearchCharactersUseCaseProtocolMock()
    private let router = AppRouter()
    private let sut: CharacterListViewModel

    init() {
        sut = CharacterListViewModel(
            getCharactersUseCase: getCharactersMock,
            searchCharactersUseCase: searchCharactersMock,
            router: router
        )
    }

    // MARK: - Initial state

    @Test("Initial view state is idle")
    func initialStateIsIdle() {
        #expect(sut.viewState == .idle)
    }

    @Test("Initial hasMorePages is false")
    func initialHasMorePagesIsFalse() {
        #expect(sut.hasMorePages == false)
    }

    // MARK: - loadCharacters success

    @Test("loadCharacters sets loaded state with mapped models on success")
    func loadCharactersSuccessYieldsLoadedState() async throws {
        let characters = [DisneyCharacter.stub(id: 1), DisneyCharacter.stub(id: 2, name: "Minnie")]
        let info = PaginationInfo.stub(nextPage: "2")
        getCharactersMock.executeReturnValue = (characters, info)

        await sut.loadCharacters()

        let expected = characters.map(CharacterPresentationMapper.toPresentation)
        #expect(sut.viewState == .loaded(expected))
        #expect(sut.hasMorePages == true)
    }

    @Test("loadCharacters sets hasMorePages false when no next page")
    func loadCharactersSetsHasMorePagesFalseWhenLastPage() async throws {
        getCharactersMock.executeReturnValue = ([], PaginationInfo.stub(nextPage: nil))

        await sut.loadCharacters()

        #expect(sut.hasMorePages == false)
    }

    @Test("loadCharacters skips reload when already loaded")
    func loadCharactersSkipsWhenAlreadyLoaded() async throws {
        getCharactersMock.executeReturnValue = ([], PaginationInfo.stub())
        await sut.loadCharacters()

        await sut.loadCharacters()

        #expect(getCharactersMock.executeCallsCount == 1)
    }

    // MARK: - loadCharacters errors

    @Test("loadCharacters sets non-retryable error on no internet connection")
    func loadCharactersSetsErrorOnNoConnection() async {
        getCharactersMock.executeThrowableError = DomainError.noInternetConnection

        await sut.loadCharacters()

        #expect(sut.viewState == .error(String(localized: "error.noConnection"), isRetryable: false))
    }

    @Test("loadCharacters sets retryable error on network failure")
    func loadCharactersSetsErrorOnNetworkFailure() async {
        getCharactersMock.executeThrowableError = DomainError.networkFailure("timeout")

        await sut.loadCharacters()

        #expect(sut.viewState == .error(String(localized: "error.networkFailure"), isRetryable: true))
    }

    @Test("loadCharacters sets retryable error on unexpected error")
    func loadCharactersSetsErrorOnUnexpectedError() async {
        getCharactersMock.executeThrowableError = DomainError.unexpected

        await sut.loadCharacters()

        #expect(sut.viewState == .error(String(localized: "error.unexpected"), isRetryable: true))
    }

    @Test("loadCharacters sets non-retryable error on character not found")
    func loadCharactersSetsErrorOnCharacterNotFound() async {
        getCharactersMock.executeThrowableError = DomainError.characterNotFound

        await sut.loadCharacters()

        #expect(sut.viewState == .error(String(localized: "error.characterNotFound"), isRetryable: false))
    }

    @Test("loadCharacters does not set error state on cancellation")
    func loadCharactersIgnoresCancellation() async {
        getCharactersMock.executeThrowableError = CancellationError()

        await sut.loadCharacters()

        #expect(sut.viewState == .loading)
    }

    // MARK: - refresh

    @Test("refresh reloads characters replacing existing list")
    func refreshReplacesExistingList() async {
        getCharactersMock.executeReturnValue = ([DisneyCharacter.stub()], PaginationInfo.stub())
        await sut.loadCharacters()

        let newCharacters = [DisneyCharacter.stub(id: 99, name: "Donald")]
        getCharactersMock.executeReturnValue = (newCharacters, PaginationInfo.stub())
        await sut.refresh()

        let expected = newCharacters.map(CharacterPresentationMapper.toPresentation)
        #expect(sut.viewState == .loaded(expected))
    }

    @Test("refresh calls use case with forceRefresh true")
    func refreshCallsUseCaseWithForceRefreshTrue() async {
        getCharactersMock.executeReturnValue = ([], PaginationInfo.stub())

        await sut.refresh()

        #expect(getCharactersMock.executeReceivedArguments?.forceRefresh == true)
    }

    @Test("loadCharacters calls use case with forceRefresh false")
    func loadCharactersCallsUseCaseWithForceRefreshFalse() async {
        getCharactersMock.executeReturnValue = ([], PaginationInfo.stub())

        await sut.loadCharacters()

        #expect(getCharactersMock.executeReceivedArguments?.forceRefresh == false)
    }

    // MARK: - loadMoreIfNeeded

    @Test("loadMoreIfNeeded appends next page when current item is last")
    func loadMoreIfNeededAppendsNextPage() async {
        let firstPage = [DisneyCharacter.stub(id: 1), DisneyCharacter.stub(id: 2, name: "Minnie")]
        let secondPage = [DisneyCharacter.stub(id: 3, name: "Donald")]
        getCharactersMock.executeReturnValue = (firstPage, PaginationInfo.stub(nextPage: "2"))
        await sut.loadCharacters()

        getCharactersMock.executeReturnValue = (secondPage, PaginationInfo.stub(nextPage: nil))
        guard let last = firstPage.last else { Issue.record("firstPage is empty"); return }
        let lastItem = CharacterPresentationMapper.toPresentation(last)
        sut.loadMoreIfNeeded(currentItem: lastItem)
        try? await Task.sleep(for: .milliseconds(100))

        if case .loaded(let all) = sut.viewState {
            #expect(all.count == 3)
        } else {
            Issue.record("Expected loaded state")
        }
    }

    @Test("loadMoreIfNeeded does nothing when hasMorePages is false")
    func loadMoreIfNeededDoesNothingWhenNoMorePages() async {
        getCharactersMock.executeReturnValue = ([DisneyCharacter.stub()], PaginationInfo.stub(nextPage: nil))
        await sut.loadCharacters()

        let item = CharacterPresentationMapper.toPresentation(DisneyCharacter.stub())
        sut.loadMoreIfNeeded(currentItem: item)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(getCharactersMock.executeCallsCount == 1)
    }

    @Test("loadMoreIfNeeded does nothing when item is not last in list")
    func loadMoreIfNeededDoesNothingForNonLastItem() async {
        let characters = [DisneyCharacter.stub(id: 1), DisneyCharacter.stub(id: 2, name: "Minnie")]
        getCharactersMock.executeReturnValue = (characters, PaginationInfo.stub(nextPage: "2"))
        await sut.loadCharacters()

        guard let first = characters.first else { Issue.record("characters is empty"); return }
        let firstItem = CharacterPresentationMapper.toPresentation(first)
        sut.loadMoreIfNeeded(currentItem: firstItem)
        try? await Task.sleep(for: .milliseconds(50))

        #expect(getCharactersMock.executeCallsCount == 1)
    }

    // MARK: - updateSearch

    @Test("updateSearch with non-empty query calls search use case after debounce")
    func updateSearchCallsSearchUseCaseAfterDebounce() async {
        searchCharactersMock.executeReturnValue = [DisneyCharacter.stub()]

        sut.updateSearch(query: "Mickey")
        try? await Task.sleep(for: .milliseconds(600))

        #expect(searchCharactersMock.executeCalled)
        #expect(searchCharactersMock.executeReceivedArguments == "Mickey")
    }

    @Test("updateSearch with empty string reloads the characters list")
    func updateSearchWithEmptyStringReloadsCharacterList() async {
        getCharactersMock.executeReturnValue = ([DisneyCharacter.stub()], PaginationInfo.stub())
        await sut.loadCharacters()
        searchCharactersMock.executeReturnValue = []
        sut.updateSearch(query: "Mickey")
        try? await Task.sleep(for: .milliseconds(600))

        getCharactersMock.executeReturnValue = ([DisneyCharacter.stub(id: 2)], PaginationInfo.stub())
        sut.updateSearch(query: "")
        try? await Task.sleep(for: .milliseconds(100))

        #expect(getCharactersMock.executeCallsCount >= 2)
    }

    @Test("updateSearch cancels previous debounce task on new input")
    func updateSearchCancelsPreviousTask() async {
        searchCharactersMock.executeReturnValue = []

        sut.updateSearch(query: "Mi")
        sut.updateSearch(query: "Mickey")
        try? await Task.sleep(for: .milliseconds(600))

        #expect(searchCharactersMock.executeCallsCount == 1)
        #expect(searchCharactersMock.executeReceivedArguments == "Mickey")
    }

    @Test("updateSearch loaded state contains search results")
    func updateSearchSetsLoadedStateWithResults() async {
        let character = DisneyCharacter.stub(name: "Mickey Mouse")
        searchCharactersMock.executeReturnValue = [character]

        sut.updateSearch(query: "Mickey")
        try? await Task.sleep(for: .milliseconds(600))

        let expected = [CharacterPresentationMapper.toPresentation(character)]
        #expect(sut.viewState == .loaded(expected))
    }

    @Test("updateSearch sets non-retryable error on no internet connection")
    func updateSearchSetsNonRetryableErrorOnNoConnection() async {
        searchCharactersMock.executeThrowableError = DomainError.noInternetConnection

        sut.updateSearch(query: "Mickey")
        try? await Task.sleep(for: .milliseconds(600))

        #expect(sut.viewState == .error(String(localized: "error.noConnection"), isRetryable: false))
    }

    @Test("updateSearch sets retryable error on network failure")
    func updateSearchSetsRetryableErrorOnNetworkFailure() async {
        searchCharactersMock.executeThrowableError = DomainError.networkFailure("timeout")

        sut.updateSearch(query: "Mickey")
        try? await Task.sleep(for: .milliseconds(600))

        #expect(sut.viewState == .error(String(localized: "error.networkFailure"), isRetryable: true))
    }

    @Test("updateSearch does not set error state on cancellation")
    func updateSearchIgnoresCancellation() async {
        searchCharactersMock.executeThrowableError = CancellationError()

        sut.updateSearch(query: "Mickey")
        try? await Task.sleep(for: .milliseconds(600))

        #expect(sut.viewState == .loading)
    }

    // MARK: - selectCharacter

    @Test("selectCharacter navigates to characterDetail route")
    func selectCharacterNavigatesToDetail() {
        sut.selectCharacter(id: 42)

        #expect(router.path.count == 1)
    }

    // MARK: - Pagination cancellation

    @Test("refresh cancels in-flight pagination task")
    func refreshCancelsPaginationTask() async {
        let firstPage = [DisneyCharacter.stub(id: 1, name: "Page1")]
        getCharactersMock.executeReturnValue = (firstPage, PaginationInfo.stub(nextPage: "2"))
        await sut.loadCharacters()

        let stalePage = [DisneyCharacter.stub(id: 2, name: "Stale")]
        getCharactersMock.executeClosure = { page, _ in
            if page == 2 {
                try await Task.sleep(for: .milliseconds(500))
                return (stalePage, PaginationInfo.stub(nextPage: nil))
            }
            let refreshed = [DisneyCharacter.stub(id: 99, name: "Refreshed")]
            return (refreshed, PaginationInfo.stub(nextPage: nil))
        }
        guard let last = firstPage.last else { Issue.record("firstPage is empty"); return }
        sut.loadMoreIfNeeded(currentItem: CharacterPresentationMapper.toPresentation(last))
        try? await Task.sleep(for: .milliseconds(50))

        await sut.refresh()
        try? await Task.sleep(for: .milliseconds(600))

        if case .loaded(let chars) = sut.viewState {
            #expect(chars.count == 1)
            #expect(chars.first?.name == "Refreshed")
            #expect(chars.contains { $0.name == "Stale" } == false)
        } else {
            Issue.record("Expected loaded state")
        }
    }

    @Test("updateSearch cancels in-flight pagination task")
    func updateSearchCancelsPaginationTask() async {
        let firstPage = [DisneyCharacter.stub(id: 1, name: "Page1")]
        getCharactersMock.executeReturnValue = (firstPage, PaginationInfo.stub(nextPage: "2"))
        await sut.loadCharacters()

        let stalePage = [DisneyCharacter.stub(id: 2, name: "Stale")]
        getCharactersMock.executeClosure = { page, _ in
            if page == 2 {
                try await Task.sleep(for: .milliseconds(500))
                return (stalePage, PaginationInfo.stub(nextPage: nil))
            }
            return (firstPage, PaginationInfo.stub(nextPage: "2"))
        }
        guard let last = firstPage.last else { Issue.record("firstPage is empty"); return }
        sut.loadMoreIfNeeded(currentItem: CharacterPresentationMapper.toPresentation(last))
        try? await Task.sleep(for: .milliseconds(50))

        let searchMatch = DisneyCharacter.stub(id: 50, name: "Mickey")
        searchCharactersMock.executeReturnValue = [searchMatch]
        sut.updateSearch(query: "Mickey")
        try? await Task.sleep(for: .milliseconds(700))

        if case .loaded(let chars) = sut.viewState {
            #expect(chars.contains { $0.name == "Stale" } == false)
            #expect(chars.contains { $0.name == "Mickey" })
        } else {
            Issue.record("Expected loaded state")
        }
    }

}
