import SwiftUI
import UIKit

@main
struct FlicksApp: App {
    private let environment = AppEnvironment.live
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.97, green: 0.96, blue: 0.94, alpha: 1.0)
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .black
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
