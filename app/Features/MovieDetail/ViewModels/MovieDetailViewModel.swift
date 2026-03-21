import Foundation
import Combine

@MainActor
final class MovieDetailViewModel: ObservableObject {
    @Published var fullScreenTitle = "Movie Card"
    @Published var detailPopupTitle = "Movie Detail Card"

    private let service: MovieDetailService

    init(service: MovieDetailService) {
        self.service = service
    }

    func load(movieID: String) async {
        _ = try? await service.fetchMovieDetail(movieID: movieID)
    }
}
