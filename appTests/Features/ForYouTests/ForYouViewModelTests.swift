import Foundation
import Testing
@testable import app

@MainActor
struct ForYouViewModelTests {
    @Test func hasForYouTitle() {
        let viewModel = ForYouViewModel()
        #expect(viewModel.title == "For You")
    }
}
