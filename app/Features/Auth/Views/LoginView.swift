import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                SignInWithAppleButton(.continue) { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    switch result {
                    case let .success(authorization):
                        guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                              let identityTokenData = appleCredential.identityToken,
                              let authorizationCodeData = appleCredential.authorizationCode,
                              let identityToken = String(data: identityTokenData, encoding: .utf8),
                              let authorizationCode = String(data: authorizationCodeData, encoding: .utf8) else {
                            viewModel.handleMissingAppleCredential()
                            return
                        }

                        Task {
                            await viewModel.loginWithApple(
                                identityToken: identityToken,
                                authorizationCode: authorizationCode
                            )
                        }
                    case let .failure(error):
                        viewModel.handleAppleAuthorizationFailure(error)
                    }
                }
                .frame(height: 44)
                .disabled(viewModel.isLoading)

                Button("Ping Backend") {
                    Task { await viewModel.pingBackend() }
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.isLoading)

                Text("Debug: \(viewModel.debugState)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            .navigationTitle("Auth")
            .padding()
        }
    }
}

#Preview {
    let environment = AppEnvironment.live
    let session = SessionStore()
    let viewModel = environment.makeLoginViewModel(session: session)
    return LoginView(viewModel: viewModel)
}
