import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                Button("Finish") {
                    viewModel.finish()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .navigationTitle("Welcome")
            .padding()
        }
    }
}

#Preview {
    OnboardingView(viewModel: PreviewSupport.onboardingViewModel)
}
