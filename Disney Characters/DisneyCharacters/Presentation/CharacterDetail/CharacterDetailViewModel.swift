import Foundation

@Observable
@MainActor
final class CharacterDetailViewModel {
    private(set) var viewState: ViewState<CharacterDetailPresentationModel> = .idle

    private let characterId: Int
    private let getCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol

    init(characterId: Int, getCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol) {
        self.characterId = characterId
        self.getCharacterDetailUseCase = getCharacterDetailUseCase
    }

    func loadCharacter() async {
        guard viewState == .idle else { return }
        viewState = .loading
        await fetchCharacter()
    }

    func refresh() async {
        viewState = .loading
        await fetchCharacter()
    }
}

private extension CharacterDetailViewModel {
    func fetchCharacter() async {
        do {
            let character = try await getCharacterDetailUseCase.execute(id: characterId)
            viewState = .loaded(CharacterDetailPresentationMapper.toPresentation(character))
        } catch is CancellationError {
            return
        } catch {
            viewState = .error(errorMessage(for: error), isRetryable: isRetryable(for: error))
        }
    }

    func errorMessage(for error: Error) -> String {
        guard let domainError = error as? DomainError else {
            return String(localized: "error.unexpected")
        }
        switch domainError {
        case .noInternetConnection:
            return String(localized: "error.noConnection")
        case .networkFailure:
            return String(localized: "error.networkFailure")
        case .characterNotFound:
            return String(localized: "error.characterNotFound")
        case .unexpected:
            return String(localized: "error.unexpected")
        }
    }

    func isRetryable(for error: Error) -> Bool {
        guard let domainError = error as? DomainError else { return true }
        switch domainError {
        case .noInternetConnection, .characterNotFound:
            return false
        case .networkFailure, .unexpected:
            return true
        }
    }
}

#if DEBUG
extension CharacterDetailViewModel {
    func overrideState(_ state: ViewState<CharacterDetailPresentationModel>) {
        viewState = state
    }
}
#endif
