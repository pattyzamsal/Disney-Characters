import Foundation

@Observable
@MainActor
final class CharacterListViewModel {
    private(set) var viewState: ViewState<[CharacterPresentationModel]> = .idle
    private(set) var isLoadingMore = false
    private(set) var hasMorePages = false
    private(set) var paginationError: String?

    private let getCharactersUseCase: GetCharactersUseCaseProtocol
    private let searchCharactersUseCase: SearchCharactersUseCaseProtocol
    private let router: AppRouter

    private var currentPage = 1
    private var searchQuery = ""
    private var searchTask: Task<Void, Never>?
    private var paginationTask: Task<Void, Never>?

    init(getCharactersUseCase: GetCharactersUseCaseProtocol,
         searchCharactersUseCase: SearchCharactersUseCaseProtocol,
         router: AppRouter) {
        self.getCharactersUseCase = getCharactersUseCase
        self.searchCharactersUseCase = searchCharactersUseCase
        self.router = router
    }

    func loadCharacters() async {
        guard viewState == .idle else { return }
        viewState = .loading
        await fetchPage(1, replacing: true, forceRefresh: false)
    }

    func refresh() async {
        searchQuery = ""
        searchTask?.cancel()
        searchTask = nil
        paginationTask?.cancel()
        paginationTask = nil
        paginationError = nil
        currentPage = 1
        await fetchPage(1, replacing: true, forceRefresh: true)
    }

    func loadMoreIfNeeded(currentItem: CharacterPresentationModel) {
        guard hasMorePages, !isLoadingMore else { return }
        guard case .loaded(let characters) = viewState,
              characters.last?.id == currentItem.id else { return }
        paginationTask?.cancel()
        paginationTask = Task { await loadNextPage() }
    }

    func updateSearch(query: String) {
        searchTask?.cancel()
        paginationTask?.cancel()
        paginationTask = nil
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            searchQuery = ""
            searchTask = nil
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

    func retryLoadMore() {
        guard hasMorePages, !isLoadingMore else { return }
        paginationError = nil
        paginationTask?.cancel()
        paginationTask = Task { await loadNextPage() }
    }

    func selectCharacter(id: Int) {
        router.navigate(to: .characterDetail(id: id))
    }
}

private extension CharacterListViewModel {
    func fetchPage(_ page: Int, replacing: Bool, forceRefresh: Bool) async {
        do {
            let result = try await getCharactersUseCase.execute(page: page, forceRefresh: forceRefresh)
            guard !Task.isCancelled else { return }
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
            hasMorePages = result.info.hasNextPage
            paginationError = nil
        } catch is CancellationError {
            return
        } catch {
            if case .loaded = viewState {
                paginationError = DomainErrorPresenter.message(for: error)
                return
            }
            viewState = .error(
                DomainErrorPresenter.message(for: error),
                isRetryable: DomainErrorPresenter.isRetryable(for: error)
            )
        }
    }

    func loadNextPage() async {
        isLoadingMore = true
        defer { isLoadingMore = false }
        await fetchPage(currentPage + 1, replacing: false, forceRefresh: false)
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
            viewState = .error(
                DomainErrorPresenter.message(for: error),
                isRetryable: DomainErrorPresenter.isRetryable(for: error)
            )
        }
    }
}

#if DEBUG
extension CharacterListViewModel {
    func overrideState(_ state: ViewState<[CharacterPresentationModel]>) {
        viewState = state
    }

    func overridePaginationError(_ message: String?) {
        paginationError = message
    }
}
#endif
