import Foundation

// MARK: - Collections
struct Collections: Codable {
    let response: [CollectionResponse]?
}

// MARK: - CollectionResponse
struct CollectionResponse: Codable, Hashable {
    let id: Int?
    let name, description, color: String?
    let parentID: Int?
    let isPublic: Bool?
    let ownerID: Int?
    let createdAt, updatedAt: String?
    let parent: Parent?
    let count: CollectionCount?
}

// MARK: - CollectionCount
struct CollectionCount: Codable, Hashable {
    let links: Int?
}

// MARK: - Parent
struct Parent: Codable, Hashable {
    let id: Int?
    let name: String?
}
