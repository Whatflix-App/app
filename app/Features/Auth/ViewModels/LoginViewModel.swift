import Foundation
import Combine
import AuthenticationServices

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var title = "Sign In"
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var debugState = "Idle"

    private let authService: any AuthServicing
    private let session: SessionStore

    init(authService: any AuthServicing, session: SessionStore) {
        self.authService = authService
        self.session = session
    }

    func loginWithApple(identityToken: String, authorizationCode: String) async {
        isLoading = true
        errorMessage = nil
        debugState = "Calling backend /auth/apple..."
        defer { isLoading = false }

        do {
            _ = try await authService.loginWithApple(
                identityToken: identityToken,
                authorizationCode: authorizationCode
            )
            session.markAuthenticated()
            debugState = "Login succeeded"
        } catch {
            session.markLoggedOut()
            errorMessage = mapError(error)
            debugState = "Backend login failed"
        }
    }

    func handleAppleAuthorizationFailure(_ error: Error) {
        debugState = "Apple authorization failed"
        if let authError = error as? ASAuthorizationError {
            switch authError.code {
            case .canceled:
                errorMessage = "Sign in was cancelled."
            case .notHandled:
                errorMessage = "Apple Sign In could not be handled."
            case .failed:
                errorMessage = "Apple Sign In failed."
            case .invalidResponse:
                errorMessage = "Apple Sign In returned an invalid response."
            case .notInteractive:
                errorMessage = "Apple Sign In requires user interaction."
            case .unknown:
                errorMessage = "Apple Sign In failed."
            @unknown default:
                errorMessage = "Apple Sign In failed."
            }
            return
        }

        errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
    }

    func handleMissingAppleCredential() {
        debugState = "Missing Apple credential"
        errorMessage = "Missing Apple credential data. Try again."
    }

    func pingBackend() async {
        isLoading = true
        errorMessage = nil
        debugState = "Pinging backend /health..."
        defer { isLoading = false }

        do {
            try await authService.pingBackend()
            debugState = "Backend reachable"
        } catch {
            errorMessage = mapError(error)
            debugState = "Backend ping failed"
        }
    }

    private func mapError(_ error: Error) -> String {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .invalidURL:
                return "Invalid API URL."
            case .requestFailed:
                return "Request failed. Check API server connectivity."
            case .decodingFailed:
                return "Invalid response from server."
            case .unauthorized:
                return "Authorization failed."
            case let .serverError(code, message):
                return "\(code): \(message)"
            }
        }

        if let urlError = error as? URLError {
            return "Network error (\(urlError.code.rawValue)). Check API host/IP."
        }

        return "Sign in failed: \(error.localizedDescription)"
    }
}
