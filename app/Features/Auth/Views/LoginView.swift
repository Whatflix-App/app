import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        ZStack {
            AppStyle.screenBackground()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Whatflix")
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(.black)

                    Text("find. watch. share.")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.black.opacity(0.85))
                }
                .padding(.bottom, 20)

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
                        let fullName = PersonNameComponentsFormatter().string(from: appleCredential.fullName ?? PersonNameComponents()).trimmingCharacters(in: .whitespacesAndNewlines)

                        Task {
                            await viewModel.loginWithApple(
                                identityToken: identityToken,
                                authorizationCode: authorizationCode,
                                fullName: fullName.isEmpty ? nil : fullName
                            )
                        }
                    case let .failure(error):
                        viewModel.handleAppleAuthorizationFailure(error)
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(maxWidth: 280)
                .frame(height: 54)
                .clipShape(Capsule())
                .padding(.horizontal, 40)
                .disabled(viewModel.isLoading)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red.opacity(0.95))
                        .font(.footnote.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
                    .frame(height: 60)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
        }
    }
}

#Preview {
    LoginView(viewModel: PreviewSupport.loginViewModel)
}
