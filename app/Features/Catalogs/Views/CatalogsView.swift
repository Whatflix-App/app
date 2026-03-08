import SwiftUI

struct CatalogsView: View {
    @ObservedObject var viewModel: CatalogsViewModel
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    private let cardHeight: CGFloat = 320
    private let gridSpacing: CGFloat = 16
    @State private var showingCreateSheet = false
    @State private var newCatalogName = ""
    @State private var newCatalogDescription = ""
    @State private var newCatalogIsPublic = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 16)
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
                                                .font(FlicksTypography.screenTitle)
                                                .foregroundStyle(.primary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.center)
                                                .minimumScaleFactor(0.8)
                                                .padding(.horizontal, 14)
                                        )
                                }
                                .buttonStyle(.plain)
                            }

                            ForEach(0..<placeholderCount(for: geometry.size.height), id: \.self) { _ in
                                placeholderCard
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color(.systemBackground))
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
                        .font(.system(size: 42, weight: .semibold))
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

    private func placeholderCount(for availableHeight: CGFloat) -> Int {
        let baseSlots = 1 + viewModel.catalogs.count
        let rowHeight = cardHeight + gridSpacing
        let visibleRows = max(1, Int(ceil(availableHeight / rowHeight)))
        let visibleSlots = visibleRows * columns.count
        let evenSlots = baseSlots + (baseSlots % columns.count)
        let requiredSlots = max(visibleSlots, evenSlots)
        return max(0, requiredSlots - baseSlots)
    }
}

#Preview {
    CatalogsView(viewModel: PreviewSupport.catalogsViewModel)
}
