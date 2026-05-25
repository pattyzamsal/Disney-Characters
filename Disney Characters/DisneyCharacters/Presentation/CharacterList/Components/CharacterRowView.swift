import Kingfisher
import SwiftUI

struct CharacterRowView: View {
    let character: CharacterPresentationModel
    @State private var imageLoadFailed = false

    var body: some View {
        HStack(spacing: Constant.horizontalSpacing) {
            thumbnailImage
            nameText
            Spacer()
        }
        .padding(.vertical, Constant.verticalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(character.name)
        .accessibilityIdentifier(AccessibilityID.CharacterList.characterRow + "\(character.id)")
    }
}

private extension CharacterRowView {
    enum Constant {
        static let thumbnailSize: CGFloat = 56
        static let cornerRadius: CGFloat = 8
        static let horizontalSpacing: CGFloat = 12
        static let verticalPadding: CGFloat = 4
        static let placeholderIconSize: CGFloat = 26
        static let lineLimitationForName: Int = 2
    }

    enum ImageName {
        static let placeholder = "person.fill"
    }

    @ViewBuilder
    var thumbnailImage: some View {
        if character.imageURL == nil || imageLoadFailed {
            defaultThumbnail
        } else {
            KFImage(character.imageURL)
                .placeholder { defaultThumbnail }
                .onFailure { _ in imageLoadFailed = true }
                .resizable()
                .scaledToFill()
                .frame(width: Constant.thumbnailSize, height: Constant.thumbnailSize)
                .clipShape(RoundedRectangle(cornerRadius: Constant.cornerRadius))
                .accessibilityHidden(true)
        }
    }

    var defaultThumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Constant.cornerRadius)
                .foregroundStyle(.quaternary)
            Image(systemName: ImageName.placeholder)
                .font(.system(size: Constant.placeholderIconSize))
                .foregroundStyle(.tertiary)
        }
        .frame(width: Constant.thumbnailSize, height: Constant.thumbnailSize)
        .accessibilityHidden(true)
    }

    var nameText: some View {
        Text(character.name)
            .font(.body)
            .lineLimit(Constant.lineLimitationForName)
    }
}

#if DEBUG
#Preview {
    VStack {
        CharacterRowView(character: CharacterPresentationModel(
            id: 1,
            name: "Mickey Mouse",
            imageURL: nil
        ))
        CharacterRowView(character: CharacterPresentationModel(
            id: 2,
            name: "A Character With A Very Long Name That Should Wrap",
            imageURL: nil
        ))
    }
    .padding()
}
#endif
