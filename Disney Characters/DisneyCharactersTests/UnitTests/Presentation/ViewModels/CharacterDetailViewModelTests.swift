import Foundation
import Testing
@testable import DisneyCharacters

@MainActor
@Suite("CharacterDetailViewModel")
struct CharacterDetailViewModelTests {
    private let getCharacterDetailMock = GetCharacterDetailUseCaseProtocolMock()
    private let sut: CharacterDetailViewModel

    init() {
        sut = CharacterDetailViewModel(
            characterId: 1,
            getCharacterDetailUseCase: getCharacterDetailMock
        )
    }

    // MARK: - Initial state

    @Test("Initial view state is idle")
    func initialStateIsIdle() {
        #expect(sut.viewState == .idle)
    }

    // MARK: - loadCharacter success

    @Test("loadCharacter sets loaded state with mapped model on success")
    func loadCharacterSuccessYieldsLoadedState() async {
        let character = DisneyCharacter.stub(id: 1)
        getCharacterDetailMock.executeReturnValue = character

        await sut.loadCharacter()

        let expected = CharacterDetailPresentationMapper.toPresentation(character)
        #expect(sut.viewState == .loaded(expected))
    }

    @Test("loadCharacter passes the correct id to the use case")
    func loadCharacterPassesCorrectId() async {
        getCharacterDetailMock.executeReturnValue = DisneyCharacter.stub()

        await sut.loadCharacter()

        #expect(getCharacterDetailMock.executeReceivedArguments == 1)
    }

    @Test("loadCharacter skips reload when not in idle state")
    func loadCharacterSkipsWhenAlreadyLoaded() async {
        getCharacterDetailMock.executeReturnValue = DisneyCharacter.stub()
        await sut.loadCharacter()

        await sut.loadCharacter()

        #expect(getCharacterDetailMock.executeCallsCount == 1)
    }

    // MARK: - loadCharacter errors

    @Test("loadCharacter sets non-retryable error on no internet connection")
    func loadCharacterSetsErrorOnNoConnection() async {
        getCharacterDetailMock.executeThrowableError = DomainError.noInternetConnection

        await sut.loadCharacter()

        #expect(sut.viewState == .error(String(localized: "error.noConnection"), isRetryable: false))
    }

    @Test("loadCharacter sets retryable error on network failure")
    func loadCharacterSetsErrorOnNetworkFailure() async {
        getCharacterDetailMock.executeThrowableError = DomainError.networkFailure("timeout")

        await sut.loadCharacter()

        #expect(sut.viewState == .error(String(localized: "error.networkFailure"), isRetryable: true))
    }

    @Test("loadCharacter sets non-retryable error on character not found")
    func loadCharacterSetsErrorOnCharacterNotFound() async {
        getCharacterDetailMock.executeThrowableError = DomainError.characterNotFound

        await sut.loadCharacter()

        #expect(sut.viewState == .error(String(localized: "error.characterNotFound"), isRetryable: false))
    }

    @Test("loadCharacter sets retryable error on unexpected error")
    func loadCharacterSetsErrorOnUnexpectedError() async {
        getCharacterDetailMock.executeThrowableError = DomainError.unexpected

        await sut.loadCharacter()

        #expect(sut.viewState == .error(String(localized: "error.unexpected"), isRetryable: true))
    }

    @Test("loadCharacter does not set error state on cancellation")
    func loadCharacterIgnoresCancellation() async {
        getCharacterDetailMock.executeThrowableError = CancellationError()

        await sut.loadCharacter()

        #expect(sut.viewState == .loading)
    }

    // MARK: - refresh

    @Test("refresh fetches character regardless of current state")
    func refreshFetchesWhenAlreadyLoaded() async {
        getCharacterDetailMock.executeReturnValue = DisneyCharacter.stub()
        await sut.loadCharacter()

        let updated = DisneyCharacter.stub(id: 1, name: "Updated Mickey")
        getCharacterDetailMock.executeReturnValue = updated
        await sut.refresh()

        let expected = CharacterDetailPresentationMapper.toPresentation(updated)
        #expect(sut.viewState == .loaded(expected))
        #expect(getCharacterDetailMock.executeCallsCount == 2)
    }

    @Test("refresh sets retryable error on network failure")
    func refreshSetsErrorOnNetworkFailure() async {
        getCharacterDetailMock.executeThrowableError = DomainError.networkFailure("timeout")

        await sut.refresh()

        #expect(sut.viewState == .error(String(localized: "error.networkFailure"), isRetryable: true))
    }
}
