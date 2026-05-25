import Foundation

@Observable
@MainActor
final class CharacterListViewModel {
    private(set) var viewState: ViewState<[CharacterPresentationModel]> = .idle
    private(set) var isLoadingMore = false
    private(set) var hasMorePages = false

    private let getCharactersUseCase: GetCharactersUseCaseProtocol
    private let searchCharactersUseCase: SearchCharactersUseCaseProtocol
    private let router: AppRouter

    private var currentPage = 1
    private var searchQuery = ""
    private var searchTask: Task<Void, Never>?

    init(getCharactersUseCase: GetCharactersUseCaseProtocol,
         searchCharactersUseCase: SearchCharactersUseCaseProtocol,
         router: AppRouter) {
        self.getCharactersUseCase = getCharactersUseCase
        self.searchCharactersUseCase = searchCharactersUseCase
        self.router = router
    }

    func loadCharacters() async {
        guard viewState == .idle || viewState == .loading else { return }
        viewState = .loading
        await fetchPage(1, replacing: true)
    }

    func refresh() async {
        searchQuery = ""
        searchTask?.cancel()
        searchTask = nil
        currentPage = 1
        await fetchPage(1, replacing: true)
    }

    func loadMoreIfNeeded(currentItem: CharacterPresentationModel) {
        guard hasMorePages, !isLoadingMore else { return }
        guard case .loaded(let characters) = viewState,
              characters.last?.id == currentItem.id else { return }
        Task { await loadNextPage() }
    }

    func updateSearch(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            searchQuery = ""
            Task { await refresh() }
            return
        }

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            searchQuery = trimmed
            await performSearch(trimmed)
        }
    }

    func selectCharacter(id: Int) {
        router.navigate(to: .characterDetail(id: id))
    }
}

private extension CharacterListViewModel {
    func fetchPage(_ page: Int, replacing: Bool) async {
        do {
            let result = try await getCharactersUseCase.execute(page: page)
            let newModels = result.characters.map(CharacterPresentationMapper.toPresentation)

            if replacing {
                viewState = .loaded(newModels)
            } else {
                if case .loaded(let existing) = viewState {
                    viewState = .loaded(existing + newModels)
                } else {
                    viewState = .loaded(newModels)
                }
            }

            currentPage = page
            hasMorePages = result.info.nextPage != nil
        } catch is CancellationError {
            return
        } catch {
            if case .loaded = viewState { return }
            viewState = .error(errorMessage(for: error), isRetryable: isRetryable(for: error))
        }
    }

    func loadNextPage() async {
        isLoadingMore = true
        defer { isLoadingMore = false }
        await fetchPage(currentPage + 1, replacing: false)
    }

    func performSearch(_ query: String) async {
        viewState = .loading
        do {
            let characters = try await searchCharactersUseCase.execute(name: query)
            let models = characters.map(CharacterPresentationMapper.toPresentation)
            viewState = models.isEmpty ? .loaded([]) : .loaded(models)
            hasMorePages = false
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
extension CharacterListViewModel {
    func overrideState(_ state: ViewState<[CharacterPresentationModel]>) {
        viewState = state
    }
}
#endif
