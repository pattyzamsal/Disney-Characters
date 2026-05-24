import SwiftUI

struct LoadingView: View {
    var body: some View {
        progressView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension LoadingView {
    enum AccessibilityContent {
        static let label = "loading.accessibilityLabel"
    }

    var progressView: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .accessibilityLabel(Text(AccessibilityContent.label))
    }
}
