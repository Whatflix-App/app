import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var title = "Profile"

    private let service: ProfileService

    init(service: ProfileService) {
        self.service = service
    }

    func load() async {
        _ = try? await service.fetchProfile()
    }
}
