import SwiftUI

@main
struct FlicksApp: App {
    private let environment = AppEnvironment.live

    var body: some Scene {
        WindowGroup {
            AppRouter(environment: environment)
        }
    }
}

#Preview {
    AppRouter(environment: .live)
}
