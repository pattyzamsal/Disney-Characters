import SnapshotTesting
import SwiftUI
import XCTest
@testable import DisneyCharacters

final class SplashViewSnapshotTests: XCTestCase {
    // Set to true the first time to record reference snapshots, then revert to false.
    private let isRecording = false

    @MainActor
    func test_lightMode_iPhone13() {
        assertSnapshot(
            of: makeSUT(),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }

    @MainActor
    func test_darkMode_iPhone13() {
        assertSnapshot(
            of: makeSUT().preferredColorScheme(.dark),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }

    @MainActor
    func test_lightMode_iPhoneSe() {
        assertSnapshot(
            of: makeSUT(),
            as: .image(layout: .device(config: .iPhoneSe)),
            record: isRecording
        )
    }

    @MainActor
    func test_accessibilityExtraExtraExtraLarge() {
        assertSnapshot(
            of: makeSUT().environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge),
            as: .image(layout: .device(config: .iPhone13)),
            record: isRecording
        )
    }
}

private extension SplashViewSnapshotTests {
    @MainActor
    func makeSUT() -> some View {
        SplashView(viewModel: SplashViewModel(router: AppRouter()))
    }
}
