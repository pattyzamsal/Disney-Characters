import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: Constant.verticalSpacing) {
            imageView
            errorDescriptionText
            buttonView
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension ErrorView {
    enum AccessibilityContent {
        static let buttonLabel = "error.retry.button"
        static let buttonHint = "error.retry.hint"
    }
    
    enum Content {
        static let errorTextButton = "error.retry.button"
    }
    
    enum Constant {
        static let verticalSpacing: CGFloat = 16
    }
    
    enum ImageName {
        static let warningTriangle = "exclamationmark.triangle"
    }
    
    var imageView: some View {
        Image(systemName: ImageName.warningTriangle)
            .font(.largeTitle)
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
    }
    
    var errorDescriptionText: some View {
        Text(message)
            .font(.body)
            .multilineTextAlignment(.center)
    }
    
    var buttonView: some View {
        Button(action: retryAction) {
            Text(Content.errorTextButton)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel(Text(AccessibilityContent.buttonLabel))
        .accessibilityHint(Text(AccessibilityContent.buttonHint))
    }
}
