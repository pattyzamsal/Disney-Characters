import SnapshotTesting
import SwiftUI
import XCTest
@testable import DisneyCharacters

final class SplashViewSnapshotTests: XCTestCase {
    @MainActor
    func test_lightMode_iPhone13() {
        assertSnapshot(
            of: makeSUT(),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @MainActor
    func test_darkMode_iPhone13() {
        assertSnapshot(
            of: makeSUT().preferredColorScheme(.dark),
            as: .image(layout: .device(config: .iPhone13))
        )
    }

    @MainActor
    func test_lightMode_iPhoneSe() {
        assertSnapshot(
            of: makeSUT(),
            as: .image(layout: .device(config: .iPhoneSe))
        )
    }

    @MainActor
    func test_accessibilityExtraExtraExtraLarge() {
        assertSnapshot(
            of: makeSUT().environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge),
            as: .image(layout: .device(config: .iPhone13))
        )
    }
}

private extension SplashViewSnapshotTests {
    @MainActor
    func makeSUT() -> some View {
        SplashView(viewModel: SplashViewModel(router: AppRouter()))
    }
}
