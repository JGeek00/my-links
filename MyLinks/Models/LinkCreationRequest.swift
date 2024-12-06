import Foundation

// MARK: - LinkCreationRequest
struct LinkCreationRequest: Codable {
    var id: Int? = nil
    let url: String?
    var name, description, type: String?
    let tags: [TagCreation]?
    let collection: CollectionCreation?
    let pinnedBy: [PinnedByRequest]?
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

// MARK: - PinnedByRequest
struct PinnedByRequest: Codable, Hashable {
    let id: Int?
}
