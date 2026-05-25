import SnapshotTesting
import SwiftUI
import XCTest
@testable import DisneyCharacters

final class CharacterListViewSnapshotTests: XCTestCase {
    private let isRecording = false

    @MainActor
    func test_loadingState_lightMode() {
        assertSnapshot(
            of: makeLoadingSUT(),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }

    @MainActor
    func test_loadedState_lightMode() {
        assertSnapshot(
            of: makeLoadedSUT(),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }

    @MainActor
    func test_loadedState_darkMode() {
        assertSnapshot(
            of: makeLoadedSUT().preferredColorScheme(.dark),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }

    @MainActor
    func test_emptyState() {
        assertSnapshot(
            of: makeEmptySUT(),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }

    @MainActor
    func test_errorState() {
        assertSnapshot(
            of: makeErrorSUT(),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }

    @MainActor
    func test_loadedState_iPhoneSe() {
        assertSnapshot(
            of: makeLoadedSUT(),
            as: .image(layout: .device(config: .iPhoneSe)),
            record: isRecording
        )
    }

    @MainActor
    func test_loadedState_accessibilityExtraExtraExtraLarge() {
        assertSnapshot(
            of: makeLoadedSUT().environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }
}

private extension CharacterListViewSnapshotTests {
    @MainActor
    func makeLoadingSUT() -> some View {
        NavigationStack {
            CharacterListView(viewModel: makeViewModel(state: .loading))
        }
    }

    @MainActor
    func makeLoadedSUT() -> some View {
        let characters = (1...5).map { index in
            CharacterPresentationModel(id: index, name: "Character \(index)", imageURL: nil)
        }
        return NavigationStack {
            CharacterListView(viewModel: makeViewModel(state: .loaded(characters)))
        }
    }

    @MainActor
    func makeEmptySUT() -> some View {
        NavigationStack {
            CharacterListView(viewModel: makeViewModel(state: .loaded([])))
        }
    }

    @MainActor
    func makeErrorSUT() -> some View {
        NavigationStack {
            CharacterListView(viewModel: makeViewModel(state: .error(String(localized: "error.networkFailure"), isRetryable: true)))
        }
    }

    @MainActor
    func makeViewModel(state: ViewState<[CharacterPresentationModel]>) -> CharacterListViewModel {
        let viewModel = CharacterListViewModel(
            getCharactersUseCase: NeverLoadingGetCharactersUseCase(),
            searchCharactersUseCase: NeverLoadingSearchCharactersUseCase(),
            router: AppRouter()
        )
        viewModel.overrideState(state)
        return viewModel
    }
}

private final class NeverLoadingGetCharactersUseCase: GetCharactersUseCaseProtocol {
    func execute(page: Int) async throws -> (characters: [DisneyCharacter], info: PaginationInfo) {
        try await Task.sleep(for: .seconds(999))
        throw DomainError.unexpected
    }
}

private final class NeverLoadingSearchCharactersUseCase: SearchCharactersUseCaseProtocol {
    func execute(name: String) async throws -> [DisneyCharacter] {
        try await Task.sleep(for: .seconds(999))
        throw DomainError.unexpected
    }
}
