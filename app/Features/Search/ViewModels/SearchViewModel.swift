import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var title = "Movie Search"
    @Published var query = ""
    @Published private(set) var results: [Movie] = []
    @Published private(set) var isSearching = false

    private let service: any SearchServicing
    private var cancellables = Set<AnyCancellable>()

    init(service: any SearchServicing) {
        self.service = service
        setupSearch()
    }

    private func setupSearch() {
        // Use Combine for a more robust debouncing implementation
        $query
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] snapshot in
                guard let self else { return }
                if snapshot.isEmpty {
                    self.results = []
                    self.isSearching = false
                } else {
                    Task { await self.runSearch(with: snapshot) }
                }
            }
            .store(in: &cancellables)
    }

    // This is now handled by the Combine pipeline above
    func scheduleSearch() {
        // Keeping this for compatibility but it's empty as setupSearch handles it.
    }

    func runSearch(with snapshot: String? = nil) async {
        let currentQuery = (snapshot ?? query).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currentQuery.isEmpty else {
            results = []
            isSearching = false
            return
        }

        isSearching = true
        do {
            let searchResults = try await service.search(query: currentQuery)
            // Ensure results match the latest query state if runSearch was called manually
            if currentQuery == query.trimmingCharacters(in: .whitespacesAndNewlines) {
                results = searchResults
            }
        } catch {
            results = []
        }
        isSearching = false
    }
}
