import Observation

@Observable
@MainActor
final class SplashViewModel {
    private let router: AppRouter

    init(router: AppRouter) {
        self.router = router
    }

    func startExploring() {
        router.navigate(to: .characterList)
    }
}
