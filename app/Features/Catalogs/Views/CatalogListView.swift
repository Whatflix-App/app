import SwiftUI

struct CatalogListView: View {
    let catalog: Catalog
    @ObservedObject var viewModel: CatalogsViewModel
    @State private var previewItems: [CatalogListPreviewItem]
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false

    init(catalog: Catalog, viewModel: CatalogsViewModel) {
        self.catalog = catalog
        self.viewModel = viewModel
        _previewItems = State(initialValue: CatalogListPreviewItem.samples(prefix: catalog.name))
    }

    var body: some View {
        ZStack {
            SystemScreenBackground()
                .ignoresSafeArea()

            MovieCardList {
                ForEach(previewItems) { item in
                    MovieCardPreview(
                        title: item.title,
                        subtitle: "From this catalog",
                        imageName: nil,
                        dateAdded: Date(),
                        cornerRadius: 20,
                        aspectRatio: 16 / 9,
                        showBorder: false
                    )
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                previewItems.removeAll { $0.id == item.id }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            // method call
                        } label: {
                            Label("Dislike", systemImage: "hand.thumbsdown.fill")
                        }
                        .tint(.red)
                        Button(role: .destructive) {
                            // method call
                        } label: {
                            Label("Neutral", systemImage: "minus")
                        }
                        .tint(.gray)
                        Button(role: .destructive) {
                            // method call
                        } label: {
                            Label("Like", systemImage: "hand.thumbsup.fill")
                        }
                        .tint(.green)
                    }
                    .movieCardListRowStyle()
                }
            }
        }
        .navigationTitle(catalog.name)
    }
}

private struct CatalogListPreviewItem: Identifiable {
    let id: Int
    let title: String

    static func samples(prefix: String) -> [CatalogListPreviewItem] {
        (1...12).map {
            CatalogListPreviewItem(id: $0, title: "\(prefix) Movie \($0)")
        }
    }
}

#Preview {
    NavigationStack {
        CatalogListView(
            catalog: Catalog(
                id: "cat_preview",
                name: "Trending",
                description: nil
            ),
            viewModel: PreviewSupport.catalogsViewModel
        )
    }
}
