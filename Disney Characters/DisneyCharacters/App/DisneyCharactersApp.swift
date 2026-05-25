//
//  DisneyCharactersApp.swift
//  DisneyCharacters
//
//  Created by Patricia Zambrano on 24/05/26.
//

import SwiftUI

@main
struct DisneyCharactersApp: App {
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                SplashView(viewModel: SplashViewModel(router: router))
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .characterList:
                            EmptyView()
                        case .characterDetail:
                            EmptyView()
                        }
                    }
            }
        }
    }
}
