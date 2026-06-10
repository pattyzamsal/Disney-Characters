import SnapshotTesting
import SwiftUI
import XCTest
@testable import DisneyCharacters

final class CharacterDetailViewSnapshotTests: XCTestCase {
    @MainActor
    func test_detail_loadedState_lightMode() {
        assertSnapshot(
            of: makeLoadedSUT(),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @MainActor
    func test_detail_loadedState_darkMode() {
        assertSnapshot(
            of: makeLoadedSUT().preferredColorScheme(.dark),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @MainActor
    func test_detail_loadedState_noSections() {
        assertSnapshot(
            of: makeLoadedSUT(character: .stub(films: [], shortFilms: [], tvShows: [],
                                               videoGames: [], parkAttractions: [],
                                               allies: [], enemies: [])),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @MainActor
    func test_detail_loadingState() {
        assertSnapshot(
            of: makeLoadingSUT(),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @MainActor
    func test_detail_errorState() {
        assertSnapshot(
            of: makeErrorSUT(),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @MainActor
    func test_detail_loadedState_iPhoneSe() {
        assertSnapshot(
            of: makeLoadedSUT(),
            as: .image(layout: .device(config: .iPhoneSe))
        )
    }

    @MainActor
    func test_detail_loadedState_accessibilityExtraExtraExtraLarge() {
        assertSnapshot(
            of: makeLoadedSUT().environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge),
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}

private extension CharacterDetailViewSnapshotTests {
    @MainActor
    func makeLoadedSUT(character: CharacterDetailPresentationModel = .stub()) -> some View {
        NavigationStack {
            CharacterDetailView(viewModel: makeViewModel(state: .loaded(character)))
        }
    }

    @MainActor
    func makeLoadingSUT() -> some View {
        NavigationStack {
            CharacterDetailView(viewModel: makeViewModel(state: .loading))
        }
    }

    @MainActor
    func makeErrorSUT() -> some View {
        NavigationStack {
            CharacterDetailView(viewModel: makeViewModel(
                state: .error(String(localized: "error.networkFailure"), isRetryable: true)
            ))
        }
    }

    @MainActor
    func makeViewModel(state: ViewState<CharacterDetailPresentationModel>) -> CharacterDetailViewModel {
        let viewModel = CharacterDetailViewModel(
            characterId: 1,
            getCharacterDetailUseCase: NeverLoadingDetailUseCase()
        )
        viewModel.overrideState(state)
        return viewModel
    }
}

private final class NeverLoadingDetailUseCase: GetCharacterDetailUseCaseProtocol {
    func execute(id: Int) async throws -> DisneyCharacter {
        try await Task.sleep(for: .seconds(999))
        throw DomainError.unexpected
    }
}
