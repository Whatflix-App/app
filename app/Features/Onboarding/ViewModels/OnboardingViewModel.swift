import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var title = "Onboarding"

    private let service: OnboardingService

    init(service: OnboardingService) {
        self.service = service
    }

    func finish() {
        service.completeOnboarding()
    }
}
