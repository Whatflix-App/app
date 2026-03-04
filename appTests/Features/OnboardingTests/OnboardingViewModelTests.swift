import Testing
@testable import app

private final class MockOnboardingService: OnboardingServicing {
    private(set) var didComplete = false

    func completeOnboarding() {
        didComplete = true
    }
}

@MainActor
struct OnboardingViewModelTests {
    @Test func finishCompletesOnboardingAndSession() {
        let service = MockOnboardingService()
        let session = SessionStore()
        let viewModel = OnboardingViewModel(service: service, session: session)

        viewModel.finish()

        #expect(service.didComplete)
        #expect(session.hasCompletedOnboarding)
    }
}
