import SwiftUI

enum CharacterDetailAssembler {
    static func make(id: Int, container: DependencyContainer) -> some View {
        let viewModel = CharacterDetailViewModel(
            characterId: id,
            getCharacterDetailUseCase: GetCharacterDetailUseCase(repository: container.characterRepository)
        )
        return CharacterDetailView(viewModel: viewModel)
    }
}
