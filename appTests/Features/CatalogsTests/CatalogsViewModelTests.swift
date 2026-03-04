import Testing
@testable import app

@MainActor
struct CatalogsViewModelTests {
    @Test func hasCatalogTitle() {
        let viewModel = CatalogsViewModel(service: CatalogsService(apiClient: APIClient()))
        #expect(viewModel.title == "Catalogs")
    }
}
