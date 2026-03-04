import Foundation

struct AppEnvironment {
    let apiClient: APIClient
    let authTokenStore: AuthTokenStore

    static let live = AppEnvironment(
        apiClient: APIClient(),
        authTokenStore: AuthTokenStore()
    )
}
