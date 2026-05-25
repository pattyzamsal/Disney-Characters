import SwiftUI

@main
struct DisneyCharactersApp: App {
    @State private var router = AppRouter()
    private let container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                SplashView(viewModel: SplashViewModel(router: router))
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .characterList:
                            CharacterListAssembler.make(container: container, router: router)
                        case .characterDetail(let id):
                            CharacterDetailAssembler.make(id: id, container: container)
                        }
                    }
            }
        }
    }
}
