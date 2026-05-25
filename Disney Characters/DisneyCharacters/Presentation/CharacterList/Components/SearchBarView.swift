import SwiftUI

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: Constant.iconSpacing) {
            searchIcon
            textField
            if !text.isEmpty {
                clearButton
            }
        }
        .padding(Constant.innerPadding)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: Constant.cornerRadius))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(AccessibilityContent.label))
        .accessibilityIdentifier(AccessibilityID.CharacterList.searchBar)
    }
}

private extension SearchBarView {
    enum AccessibilityContent {
        static let label: LocalizedStringKey = "characterList.searchBar.accessibilityLabel"
        static let clearButtonLabel: LocalizedStringKey = "characterList.searchBar.clearButton.accessibilityLabel"
    }

    enum Content {
        static let placeholder: LocalizedStringKey = "characterList.searchBar.placeholder"
    }

    enum Constant {
        static let iconSpacing: CGFloat = 8
        static let innerPadding: CGFloat = 10
        static let cornerRadius: CGFloat = 10
    }

    enum ImageName {
        static let search = "magnifyingglass"
        static let clear = "xmark.circle.fill"
    }

    var searchIcon: some View {
        Image(systemName: ImageName.search)
            .foregroundStyle(.secondary)
            .accessibilityHidden(true)
    }

    var textField: some View {
        TextField(Content.placeholder, text: $text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
    }

    var clearButton: some View {
        Button {
            text = ""
        } label: {
            Image(systemName: ImageName.clear)
                .foregroundStyle(.secondary)
        }
        .accessibilityLabel(Text(AccessibilityContent.clearButtonLabel))
    }
}

#if DEBUG
#Preview {
    @Previewable @State var query = ""
    SearchBarView(text: $query)
        .padding()
}
#endif
