import SwiftUI

struct MovieCardList<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        List {
            content()
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}

private struct MovieCardListRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            .listRowSeparator(.hidden)
    }
}

extension View {
    func movieCardListRowStyle() -> some View {
        modifier(MovieCardListRowModifier())
    }
}
