import SwiftUI

struct CharacterListView: View {
    let viewModel: CharacterListViewModel
    @State private var searchText = ""

    var body: some View {
        contentView
            .navigationTitle(Content.title)
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.loadCharacters() }
            .refreshable { await viewModel.refresh() }
            .onChange(of: searchText) { _, newValue in
                viewModel.updateSearch(query: newValue)
            }
    }
}

private extension CharacterListView {
    enum Content {
        static let title: LocalizedStringKey = "characterList.title"
        static let emptyState: LocalizedStringKey = "characterList.emptyState"
    }

    @ViewBuilder
    var contentView: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            LoadingView()
        case .loaded(let characters):
            if characters.isEmpty {
                emptyStateView
            } else {
                characterListView(characters)
            }
        case .error(let message, let isRetryable):
            ErrorView(
                message: message,
                retryAction: isRetryable ? { Task { await viewModel.refresh() } } : nil
            )
        }
    }

    var emptyStateView: some View {
        VStack {
            if !searchText.isEmpty {
                searchBarView
            }
            Spacer()
            Text(Content.emptyState)
                .font(.body)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(.horizontal)
    }

    func characterListView(_ characters: [CharacterPresentationModel]) -> some View {
        VStack(spacing: .zero) {
            searchBarView
                .padding(.horizontal)
                .padding(.bottom, Constant.searchBarBottomPadding)
            ScrollView {
                LazyVStack(spacing: .zero) {
                    ForEach(characters) { character in
                        Button {
                            viewModel.selectCharacter(id: character.id)
                        } label: {
                            CharacterRowView(character: character)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentItem: character)
                        }
                        Divider()
                            .padding(.leading, Constant.dividerLeading)
                    }
                    if viewModel.isLoadingMore {
                        loadingMoreView
                    }
                }
            }
        }
    }

    var searchBarView: some View {
        SearchBarView(text: $searchText)
    }

    var loadingMoreView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .padding()
            .frame(maxWidth: .infinity)
    }

    enum Constant {
        static let dividerLeading: CGFloat = 80
        static let searchBarBottomPadding: CGFloat = 8
    }
}

#if DEBUG
#Preview("Loaded") {
    NavigationStack {
        CharacterListView(viewModel: CharacterListViewModel(
            getCharactersUseCase: PreviewGetCharactersUseCase(),
            searchCharactersUseCase: PreviewSearchCharactersUseCase(),
            router: AppRouter()
        ))
    }
}

#Preview("Loading") {
    NavigationStack {
        CharacterListView(viewModel: previewViewModel(state: .loading))
    }
}

#Preview("Empty State") {
    NavigationStack {
        CharacterListView(viewModel: previewViewModel(state: .loaded([])))
    }
}

#Preview("Error – No Connection") {
    NavigationStack {
        CharacterListView(viewModel: previewViewModel(
            state: .error(String(localized: "error.noConnection"), isRetryable: false)
        ))
    }
}

#Preview("Error – Network Failure") {
    NavigationStack {
        CharacterListView(viewModel: previewViewModel(
            state: .error(String(localized: "error.networkFailure"), isRetryable: true)
        ))
    }
}

@MainActor
private func previewViewModel(
    state: ViewState<[CharacterPresentationModel]>
) -> CharacterListViewModel {
    let viewModel = CharacterListViewModel(
        getCharactersUseCase: PreviewNeverLoadingUseCase(),
        searchCharactersUseCase: PreviewSearchCharactersUseCase(),
        router: AppRouter()
    )
    viewModel.overrideState(state)
    return viewModel
}

private final class PreviewGetCharactersUseCase: GetCharactersUseCaseProtocol {
    func execute(page: Int) async throws -> (characters: [DisneyCharacter], info: PaginationInfo) {
        let characters = (1...10).map { index in
            DisneyCharacter(
                id: index,
                name: "Character \(index)",
                imageURL: nil,
                films: [],
                shortFilms: [],
                tvShows: [],
                videoGames: [],
                parkAttractions: [],
                allies: [],
                enemies: []
            )
        }
        return (characters, PaginationInfo(totalPages: 2, count: 10, previousPage: nil, nextPage: "2"))
    }
}

private final class PreviewNeverLoadingUseCase: GetCharactersUseCaseProtocol {
    func execute(page: Int) async throws -> (characters: [DisneyCharacter], info: PaginationInfo) {
        try await Task.sleep(for: .seconds(999))
        throw DomainError.unexpected
    }
}

private final class PreviewSearchCharactersUseCase: SearchCharactersUseCaseProtocol {
    func execute(name: String) async throws -> [DisneyCharacter] { [] }
}
#endif
