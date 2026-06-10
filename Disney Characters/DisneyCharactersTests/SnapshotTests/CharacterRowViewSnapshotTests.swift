import SnapshotTesting
import SwiftUI
import XCTest
@testable import DisneyCharacters

final class CharacterRowViewSnapshotTests: XCTestCase {
    @MainActor
    func test_lightMode() {
        assertSnapshot(
            of: makeSUT(),
            as: .image(layout: .fixed(width: 375, height: 80))
        )
    }

    @MainActor
    func test_darkMode() {
        assertSnapshot(
            of: makeSUT().preferredColorScheme(.dark),
            as: .image(layout: .fixed(width: 375, height: 80))
        )
    }

    @MainActor
    func test_longName() {
        assertSnapshot(
            of: makeSUT(name: "A Very Long Character Name That Wraps Across Multiple Lines"),
            as: .image(layout: .fixed(width: 375, height: 80))
        )
    }

    @MainActor
    func test_row_accessibilityExtraExtraExtraLarge() {
        assertSnapshot(
            of: makeSUT().environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge),
            as: .image(layout: .fixed(width: 375, height: 100))
        )
    }
}

private extension CharacterRowViewSnapshotTests {
    @MainActor
    func makeSUT(name: String = "Mickey Mouse") -> some View {
        CharacterRowView(character: CharacterPresentationModel(
            id: 1,
            name: name,
            imageURL: nil
        ))
        .padding(.horizontal)
    }
}
