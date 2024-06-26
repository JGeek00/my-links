import Foundation

// MARK: - Collections
struct CollectionsResponse: Codable {
    let response: [Collection]?
}

// MARK: - CollectionResponse
struct CollectionResponse: Codable {
    let response: Collection?
}

// MARK: - Collection
struct Collection: Codable, Hashable {
    let id: Int?
    let name, description, color: String?
    let parentID: Int?
    let isPublic: Bool?
    let ownerId: Int?
    let createdAt, updatedAt: String?
    let parent: Parent?
    let _count: CollectionCount?
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
