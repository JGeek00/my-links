import Foundation

// MARK: - LinkCreationRequest
struct LinkCreationRequest: Codable {
    let url: String?
    let name, description: String?
    let tags: [TagCreation]?
    let collection: CollectionCreation?
}

// MARK: - CollectionCreation
struct CollectionCreation: Codable {
    let id: Int?
    let name: String?
    let ownerId: Int?
}

// MARK: - TagCreation
struct TagCreation: Codable {
    let name: String?
}
