import SwiftUI

struct CatalogListView: View {
    let catalog: Catalog
    @ObservedObject var viewModel: CatalogsViewModel
    private let previewCount = 12
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirm = false

    var body: some View {
        ZStack {
            AppStyle.brandGradient
                .ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    ForEach(0..<previewCount, id: \.self) { index in
                        MovieCardPreview(
                            title: "\(catalog.name) Movie \(index + 1)",
                            subtitle: "From this catalog",
                            imageName: nil,
                            dateAdded: Date(),
                            cornerRadius: 20,
                            aspectRatio: 16 / 9,
                            showBorder: false
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle(catalog.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .confirmationDialog(
            "Delete catalog?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    let deleted = await viewModel.deleteCatalog(id: catalog.id)
                    if deleted {
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the catalog and its movies.")
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
