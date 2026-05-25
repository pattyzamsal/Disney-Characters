import SwiftUI

enum CharacterListAssembler {
    static func make(container: DependencyContainer, router: AppRouter) -> some View {
        let viewModel = CharacterListViewModel(
            getCharactersUseCase: GetCharactersUseCase(repository: container.characterRepository),
            searchCharactersUseCase: SearchCharactersUseCase(repository: container.characterRepository),
            router: router
        )
        return CharacterListView(viewModel: viewModel)
    }
}
