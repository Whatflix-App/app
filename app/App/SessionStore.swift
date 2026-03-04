import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published var isAuthenticated = false
    @Published var hasCompletedOnboarding = false
}
