import Foundation
import NullCodable

// MARK: - LinkEditingRequest
struct LinkEditingRequest: Codable {
    var id: Int? = nil
    @NullCodable var url: String?
    var name, description, type: String?
    let tags: [TagCreation]?
    let collection: CollectionCreation?
    let pinnedBy: [PinnedByRequestEditing]?
    let image: String?
    let pdf: String?
}

// MARK: - CollectionCreation
struct CollectionEditing: Codable {
    let id: Int?
    let name: String?
    let ownerId: Int?
}

// MARK: - TagCreation
struct TagEditing: Codable {
    let name: String?
}

// MARK: - PinnedByRequest
struct PinnedByRequestEditing: Codable, Hashable {
    let id: Int?
}
