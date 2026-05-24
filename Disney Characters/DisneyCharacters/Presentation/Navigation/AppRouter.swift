import SwiftUI

enum AppRoute: Hashable {
    case characterList
    case characterDetail(id: Int)
}

@Observable
final class AppRouter {
    var path = NavigationPath()

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func navigateBack() {
        path.removeLast()
    }

    func navigateToRoot() {
        path.removeLast(path.count)
    }
}
