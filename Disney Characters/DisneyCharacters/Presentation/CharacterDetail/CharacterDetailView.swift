import Kingfisher
import SwiftUI

struct CharacterDetailView: View {
    let viewModel: CharacterDetailViewModel
    @State private var heroImageLoadFailed = false

    var body: some View {
        contentView
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.loadCharacter() }
            .refreshable { await viewModel.refresh() }
    }
}

private extension CharacterDetailView {
    enum Content {
        static let films: LocalizedStringKey = "characterDetail.section.films"
        static let shortFilms: LocalizedStringKey = "characterDetail.section.shortFilms"
        static let tvShows: LocalizedStringKey = "characterDetail.section.tvShows"
        static let videoGames: LocalizedStringKey = "characterDetail.section.videoGames"
        static let parkAttractions: LocalizedStringKey = "characterDetail.section.parkAttractions"
        static let allies: LocalizedStringKey = "characterDetail.section.allies"
        static let enemies: LocalizedStringKey = "characterDetail.section.enemies"
    }

    enum Constant {
        static let heroImageHeight: CGFloat = 300
        static let placeholderIconSize: CGFloat = 60
        static let sectionSpacing: CGFloat = 24
        static let itemSpacing: CGFloat = 4
    }

    enum ImageName {
        static let placeholder = "person.fill"
    }

    var navigationTitle: String {
        guard case .loaded(let character) = viewModel.viewState else { return "" }
        return character.name
    }

    @ViewBuilder
    var contentView: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            LoadingView()
        case .loaded(let character):
            characterDetailView(character)
        case .error(let message, let isRetryable):
            ErrorView(
                message: message,
                retryAction: isRetryable ? { Task { await viewModel.refresh() } } : nil
            )
        }
    }

    func characterDetailView(_ character: CharacterDetailPresentationModel) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .zero) {
                heroImageView(for: character)
                    .accessibilityLabel(character.name)
                    .accessibilityIdentifier(AccessibilityID.CharacterDetail.characterImage)
                sectionsView(character)
                    .padding()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    func heroImageView(for character: CharacterDetailPresentationModel) -> some View {
        if let url = character.imageURL, !heroImageLoadFailed {
            KFImage(url)
                .placeholder { defaultHeroImage }
                .onFailure { _ in heroImageLoadFailed = true }
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: Constant.heroImageHeight)
                .clipped()
        } else {
            defaultHeroImage
        }
    }

    var defaultHeroImage: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.quaternary)
            Image(systemName: ImageName.placeholder)
                .font(.system(size: Constant.placeholderIconSize))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: Constant.heroImageHeight)
        .accessibilityHidden(true)
    }

    func sectionsView(_ character: CharacterDetailPresentationModel) -> some View {
        VStack(alignment: .leading, spacing: Constant.sectionSpacing) {
            if !character.films.isEmpty {
                sectionView(title: Content.films, items: character.films)
            }
            if !character.shortFilms.isEmpty {
                sectionView(title: Content.shortFilms, items: character.shortFilms)
            }
            if !character.tvShows.isEmpty {
                sectionView(title: Content.tvShows, items: character.tvShows)
            }
            if !character.videoGames.isEmpty {
                sectionView(title: Content.videoGames, items: character.videoGames)
            }
            if !character.parkAttractions.isEmpty {
                sectionView(title: Content.parkAttractions, items: character.parkAttractions)
            }
            if !character.allies.isEmpty {
                sectionView(title: Content.allies, items: character.allies)
            }
            if !character.enemies.isEmpty {
                sectionView(title: Content.enemies, items: character.enemies)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func sectionView(title: LocalizedStringKey, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: Constant.itemSpacing) {
            Text(title)
                .font(.headline)
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.body)
            }
        }
    }
}

#if DEBUG
#Preview("Loaded") {
    NavigationStack {
        CharacterDetailView(viewModel: CharacterDetailViewModel(
            characterId: 1,
            getCharacterDetailUseCase: PreviewGetCharacterDetailUseCase()
        ))
    }
}

#Preview("Loaded – No Sections") {
    NavigationStack {
        CharacterDetailView(viewModel: CharacterDetailViewModel(
            characterId: 2,
            getCharacterDetailUseCase: PreviewEmptyCharacterDetailUseCase()
        ))
    }
}

#Preview("Loading") {
    NavigationStack {
        CharacterDetailView(viewModel: previewViewModel(state: .loading))
    }
}

#Preview("Error – No Connection") {
    NavigationStack {
        CharacterDetailView(viewModel: previewViewModel(
            state: .error(String(localized: "error.noConnection"), isRetryable: false)
        ))
    }
}

#Preview("Error – Network Failure") {
    NavigationStack {
        CharacterDetailView(viewModel: previewViewModel(
            state: .error(String(localized: "error.networkFailure"), isRetryable: true)
        ))
    }
}

private func previewViewModel(
    state: ViewState<CharacterDetailPresentationModel>
) -> CharacterDetailViewModel {
    let viewModel = CharacterDetailViewModel(
        characterId: 1,
        getCharacterDetailUseCase: PreviewNeverLoadingDetailUseCase()
    )
    viewModel.overrideState(state)
    return viewModel
}

private final class PreviewGetCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol {
    func execute(id: Int) async throws -> DisneyCharacter {
        DisneyCharacter(
            id: id,
            name: "Mickey Mouse",
            imageURL: nil,
            films: ["Fantasia", "Fun and Fancy Free", "Mickey's Christmas Carol"],
            shortFilms: ["The Pointer", "Mickey's Delayed Date"],
            tvShows: ["The Mickey Mouse Club", "Mickey Mouse Clubhouse"],
            videoGames: ["Kingdom Hearts", "Disney Magical World"],
            parkAttractions: ["Mickey's PhilharMagic", "Town Square Theater"],
            allies: ["Minnie Mouse", "Donald Duck", "Goofy"],
            enemies: ["Pete", "Mortimer Mouse"]
        )
    }
}

private final class PreviewEmptyCharacterDetailUseCase: GetCharacterDetailUseCaseProtocol {
    func execute(id: Int) async throws -> DisneyCharacter {
        DisneyCharacter(
            id: id,
            name: "Unknown Character",
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
}

private final class PreviewNeverLoadingDetailUseCase: GetCharacterDetailUseCaseProtocol {
    func execute(id: Int) async throws -> DisneyCharacter {
        try await Task.sleep(for: .seconds(999))
        throw DomainError.unexpected
    }
}
#endif
