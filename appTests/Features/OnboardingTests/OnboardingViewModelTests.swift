import Testing
@testable import app

@MainActor
struct OnboardingViewModelTests {
    @Test func hasOnboardingTitle() {
        let viewModel = OnboardingViewModel(service: OnboardingService())
        #expect(viewModel.title == "Onboarding")
    }
}
