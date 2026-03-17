import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var title = "Profile"
    @Published var displayName = "Loading..."
    @Published var fullName = ""
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: ProfileService
    private let authService: any AuthServicing
    private let session: SessionStore
    private let historyState: HistoryState
    private var hasLoadedOnce = false

    init(
        service: ProfileService,
        authService: any AuthServicing,
        session: SessionStore,
        historyState: HistoryState
    ) {
        self.service = service
        self.authService = authService
        self.session = session
        self.historyState = historyState
    }

    func load(force: Bool = false) async {
        if hasLoadedOnce && !force { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let profileTask = service.fetchProfile()
            async let historyTask: Void = historyState.refresh(force: force)

            let user = try await profileTask
            await historyTask
            displayName = user.displayName ?? "User"
            fullName = user.fullName ?? ""
            email = user.email ?? ""
            hasLoadedOnce = true
        } catch {
            errorMessage = "Failed to load profile"
        }
    }

    func logout() async {
        await authService.logout()
        session.markLoggedOut()
    }
}
