import Foundation

struct Catalog: Identifiable {
    let id: String
    let name: String
    let description: String?
    let movieIds: [String]

    init(id: String, name: String, description: String?, movieIds: [String] = []) {
        self.id = id
        self.name = name
        self.description = description
        self.movieIds = movieIds
    }
}
