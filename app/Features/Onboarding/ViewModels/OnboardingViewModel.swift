import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var title = "Onboarding"

    private let service: any OnboardingServicing
    private let session: SessionStore

    init(service: any OnboardingServicing, session: SessionStore) {
        self.service = service
        self.session = session
    }

    func finish() {
        service.completeOnboarding()
        session.hasCompletedOnboarding = true
    }
}
