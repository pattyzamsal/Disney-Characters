import Foundation

@Observable
@MainActor
final class CharacterDetailViewModel {
    private(set) var viewState: ViewState<CharacterDetailPresentationModel> = .idle

    private let characterId: Int
    private let getCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol
    private var currentTask: Task<Void, Never>?

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
        currentTask?.cancel()
        viewState = .loading
        currentTask = Task { await fetchCharacter() }
        await currentTask?.value
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
            viewState = .error(
                DomainErrorPresenter.message(for: error),
                isRetryable: DomainErrorPresenter.isRetryable(for: error)
            )
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
