import SwiftUI

struct CatalogsView: View {
    @ObservedObject var viewModel: CatalogsViewModel
    private let gridSpacing: CGFloat = 14
    private let horizontalPadding: CGFloat = 18
    private let bottomPadding: CGFloat = 28
    private let previewAspectRatio: CGFloat = 3 / 4
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    @State private var showingCreateSheet = false
    @State private var newCatalogName = ""
    @State private var newCatalogDescription = ""
    @State private var newCatalogIsPublic = false

    var body: some View {
        NavigationStack {
            ZStack {
                SystemScreenBackground()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 16) {
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .padding(.horizontal, horizontalPadding)
                    }

                    GeometryReader { geometry in
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVGrid(columns: columns, spacing: gridSpacing) {
                                createCatalogCard

                                ForEach(viewModel.catalogs) { catalog in
                                    NavigationLink {
                                        CatalogListView(catalog: catalog, viewModel: viewModel)
                                    } label: {
                                        CatalogPreview()
                                            .frame(maxWidth: .infinity)
                                            .overlay(
                                                Text(catalog.name)
                                                    .font(.headline.weight(.semibold))
                                                    .foregroundStyle(SystemTheme.primaryText)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                                    .minimumScaleFactor(0.8)
                                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                                                    .padding(.horizontal, 14)
                                                    .padding(.vertical, 12)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }

                                ForEach(0..<placeholderCount(for: geometry.size), id: \.self) { _ in
                                    placeholderCard
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.top, 4)
                            .padding(.bottom, bottomPadding)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .sheet(isPresented: $showingCreateSheet) {
                NavigationStack {
                    Form {
                        TextField("Catalog name", text: $newCatalogName)
                        TextField("Description (optional)", text: $newCatalogDescription)
                    }
                    .navigationTitle("New Catalog")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingCreateSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Create") {
                                Task {
                                    await viewModel.createCatalog(
                                        name: newCatalogName,
                                        description: newCatalogDescription.isEmpty ? nil : newCatalogDescription,
                                        isPublic: newCatalogIsPublic
                                    )
                                    if viewModel.errorMessage == nil {
                                        newCatalogName = ""
                                        newCatalogDescription = ""
                                        newCatalogIsPublic = false
                                        showingCreateSheet = false
                                    }
                                }
                            }
                            .disabled(newCatalogName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.load()
                }
            }
        }
    }

    private var createCatalogCard: some View {
        Button {
            showingCreateSheet = true
        } label: {
            CatalogPreview()
                .frame(maxWidth: .infinity)
                .overlay(
                    Image(systemName: "plus")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(.secondary)
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Create catalog")
    }

    private var placeholderCard: some View {
        CatalogPreview()
            .frame(maxWidth: .infinity)
            .opacity(0.4)
    }

    private func placeholderCount(for size: CGSize) -> Int {
        let baseSlots = 1 + viewModel.catalogs.count
        let availableWidth = max(0, size.width - (horizontalPadding * 2) - gridSpacing)
        let cellWidth = availableWidth / CGFloat(columns.count)
        let cardHeight = cellWidth / previewAspectRatio
        let rowHeight = cardHeight + gridSpacing
        let visibleRows = max(1, Int(ceil(size.height / rowHeight)))
        let visibleSlots = visibleRows * columns.count
        let evenSlots = baseSlots + (baseSlots % columns.count)
        let requiredSlots = max(visibleSlots, evenSlots)
        return max(0, requiredSlots - baseSlots)
    }
}

#Preview {
    CatalogsView(viewModel: PreviewSupport.catalogsViewModel)
}
