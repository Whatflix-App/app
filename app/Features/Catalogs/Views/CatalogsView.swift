import SwiftUI

struct CatalogsView: View {
    @ObservedObject var viewModel: CatalogsViewModel
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var showingCreateSheet = false
    @State private var newCatalogName = ""
    @State private var newCatalogDescription = ""
    @State private var newCatalogIsPublic = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.catalogs) { catalog in
                            NavigationLink {
                                CatalogListView(catalog: catalog, viewModel: viewModel)
                            } label: {
                                CatalogPreview()
                                    .overlay(
                                        Text(catalog.name)
                                            .font(FlicksTypography.screenTitle)
                                            .foregroundStyle(.primary)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .navigationTitle("Other Catalogs")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
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
}

#Preview {
    CatalogsView(viewModel: PreviewSupport.catalogsViewModel)
}
