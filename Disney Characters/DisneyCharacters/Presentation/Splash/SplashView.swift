import SwiftUI

struct SplashView: View {
    let viewModel: SplashViewModel

    var body: some View {
        VStack {
            Spacer()
            mainContent
            Spacer()
            creditsSection
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension SplashView {
    enum AccessibilityContent {
        static let logoLabel: LocalizedStringKey = "splash.logo.accessibilityLabel"
        static let buttonHint: LocalizedStringKey = "splash.start.accessibilityHint"
    }

    enum Content {
        static let title: LocalizedStringKey = "splash.title"
        static let subtitle: LocalizedStringKey = "splash.subtitle"
        static let startButton: LocalizedStringKey = "splash.start.button"
        static let creditsLabel: LocalizedStringKey = "splash.credits.label"
        static let creditsAuthor: LocalizedStringKey = "splash.credits.author"
    }

    enum Constant {
        static let verticalSpacing: CGFloat = 24
        static let logoSize: CGFloat = 120
        static let creditsSpacing: CGFloat = 4
    }

    enum ImageName {
        static let logo = "splash_logo"
    }

    var mainContent: some View {
        VStack(spacing: Constant.verticalSpacing) {
            logoImage
            titleText
            subtitleText
            startButton
        }
    }

    var creditsSection: some View {
        VStack(spacing: Constant.creditsSpacing) {
            Text(Content.creditsLabel)
            Text(Content.creditsAuthor)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }

    var logoImage: some View {
        Image(ImageName.logo)
            .resizable()
            .scaledToFit()
            .frame(width: Constant.logoSize, height: Constant.logoSize)
            .accessibilityLabel(Text(AccessibilityContent.logoLabel))
            .accessibilityIdentifier(AccessibilityID.Splash.logo)
    }

    var titleText: some View {
        Text(Content.title)
            .font(.title)
            .multilineTextAlignment(.center)
    }

    var subtitleText: some View {
        Text(Content.subtitle)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
    }

    var startButton: some View {
        Button(action: viewModel.startExploring) {
            Text(Content.startButton)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityLabel(Text(Content.startButton))
        .accessibilityHint(Text(AccessibilityContent.buttonHint))
        .accessibilityIdentifier(AccessibilityID.Splash.startButton)
    }
}

#if DEBUG
#Preview {
    SplashView(viewModel: SplashViewModel(router: AppRouter()))
}
#endif
