import SwiftUI
import UIKit

@main
struct FlicksApp: App {
    private let environment = AppEnvironment.live
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = SystemTheme.navigationBarColor
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: SystemTheme.navigationTextColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: SystemTheme.navigationTextColor]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = SystemTheme.navigationTextColor

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = SystemTheme.navigationBarColor
        tabAppearance.shadowColor = .clear
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = SystemTheme.navigationTextColor
    }

    var body: some Scene {
        WindowGroup {
            AppRouter(environment: environment)
        }
    }
}

#Preview {
    AppRouter(environment: .live)
}
