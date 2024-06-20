import Foundation

// MARK: - Links
struct Links: Codable {
    let response: [Link]?
}

// MARK: - Link
struct Link: Codable, Hashable {
    let id: Int?
    let name, type, description: String?
    let collectionID: Int?
    let url: String?
    let textContent, preview, image, pdf: String?
    let readable, lastPreserved: String?
    let importDate: String?
    let createdAt, updatedAt: String?
    let tags: [TagInfo]?
    let collection: LinkCollection?
    let pinnedBy: [PinnedBy]?
}

// MARK: - LinkCollection
struct LinkCollection: Codable, Hashable {
    let id: Int?
    let name, description, color: String?
    let parentID: Int?
    let isPublic: Bool?
    let ownerId: Int?
    let createdAt, updatedAt: String?
}

// MARK: - PinnedBy
struct PinnedBy: Codable, Hashable {
    let id: Int?
}

// MARK: - TagInfo
struct TagInfo: Codable, Hashable {
    let id: Int?
    let name: String?
    let ownerID: String?
    let createdAt, updatedAt: String?
}
