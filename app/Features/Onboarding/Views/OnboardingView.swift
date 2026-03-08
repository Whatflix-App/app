import SwiftUI

struct OnboardingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var selectedPersonas: Set<UUID> = []
    @State private var currentIndex = 0

    struct Persona: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let colors: [Color]
    }

    private let personas: [Persona] = [
        Persona(
            title: "Epic Adventures",
            description: "Big worlds, unforgettable stakes, and blockbuster energy.",
            colors: [Color(red: 0.17, green: 0.31, blue: 0.58), Color(red: 0.44, green: 0.23, blue: 0.63)]
        ),
        Persona(
            title: "Cozy Comfort",
            description: "Warm, character-first stories for low-stress nights.",
            colors: [Color(red: 0.27, green: 0.48, blue: 0.42), Color(red: 0.38, green: 0.28, blue: 0.52)]
        ),
        Persona(
            title: "Mind-Bending",
            description: "Twists, layered themes, and movies that linger after credits.",
            colors: [Color(red: 0.49, green: 0.31, blue: 0.22), Color(red: 0.19, green: 0.22, blue: 0.46)]
        )
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer
                    .ignoresSafeArea()

                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    TabView(selection: $currentIndex) {
                        ForEach(Array(personas.enumerated()), id: \.element.id) { index, persona in
                            PersonaCard(
                                persona: persona,
                                isSelected: selectedPersonas.contains(persona.id),
                                size: CGSize(width: geometry.size.width - 40, height: geometry.size.height * 0.75)
                            ) {
                                toggleSelection(for: persona)
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: geometry.size.height * 0.85)

                    footerControls
                        .padding(.horizontal, 40)
                        .padding(.bottom, 40)
                }
            }
        }
        .ignoresSafeArea()
    }

    private var backgroundLayer: some View {
        ZStack {
            ForEach(Array(personas.enumerated()), id: \.offset) { index, persona in
                LinearGradient(
                    colors: persona.colors + [.black.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(index == currentIndex ? 1 : 0)
                .animation(.easeInOut(duration: 0.8), value: currentIndex)
            }
        }
    }

    private var footerControls: some View {
        HStack {
            HStack(spacing: 8) {
                ForEach(0..<personas.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(currentIndex == index ? 1.0 : 0.4))
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentIndex == index ? 1.2 : 1.0)
                        .animation(.spring(), value: currentIndex)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .glassEffect(in: Capsule())

            Spacer()

            Button(action: completeOnboarding) {
                ZStack {
                    Circle()
                        .fill(selectedPersonas.isEmpty ? Color.white.opacity(0.2) : Color.white)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 10)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(selectedPersonas.isEmpty ? .white.opacity(0.5) : .black)
                }
            }
            .disabled(selectedPersonas.isEmpty)
        }
    }

    private func toggleSelection(for persona: Persona) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if selectedPersonas.contains(persona.id) {
                selectedPersonas.remove(persona.id)
            } else {
                selectedPersonas.insert(persona.id)
            }
        }
    }

    private func completeOnboarding() {
        viewModel.finish()
    }
}

private struct PersonaCard: View {
    let persona: OnboardingView.Persona
    let isSelected: Bool
    let size: CGSize
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .fill(Color.white.opacity(0.0001))
                    .glassEffect(in: RoundedRectangle(cornerRadius: 32, style: .continuous))

                VStack(alignment: .leading, spacing: 16) {
                    Text(persona.title)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(persona.description)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.95))
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
                .padding(32)
                .padding(.bottom, 20)
            }
        }
        .buttonStyle(.plain)
        .frame(width: size.width, height: size.height)
        .contentShape(RoundedRectangle(cornerRadius: 32))
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .shadow(color: isSelected ? Color.white.opacity(0.3) : Color.black.opacity(0.2), radius: 20)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}

#Preview {
    OnboardingView(viewModel: PreviewSupport.onboardingViewModel)
}
