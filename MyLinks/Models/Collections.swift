import Foundation

// MARK: - Collections
struct CollectionsResponse: Codable, Sendable {
    let response: [Collection]?
}

// MARK: - CollectionResponse
struct CollectionResponse: Codable, Sendable {
    let response: Collection?
}

// MARK: - Collection
struct Collection: Codable, Hashable, Sendable {
    let id: Int
    let name: String
    let description, color: String?
    var parentID: Int?
    let isPublic: Bool?
    let ownerId: Int?
    let createdAt, updatedAt: String?
    var parent: Parent?
    var members: [CollectionMember]
    let _count: CollectionCount?
}

// MARK: - CollectionCount
struct CollectionCount: Codable, Hashable, Sendable {
    let links: Int?
}

// MARK: - Parent
struct Parent: Codable, Hashable, Sendable {
    let id: Int?
    let name: String?
}

// MARK: - CollectionMember
struct CollectionMember: Codable, Hashable, Sendable {
    let userID, collectionID: Int
    var canCreate: Bool
    var canUpdate: Bool
    var canDelete: Bool
    let createdAt, updatedAt: String
    let user: CollectionMemberUser

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case collectionID = "collectionId"
        case canCreate, canUpdate, canDelete, createdAt, updatedAt, user
    }
}

// MARK: - CollectionMemberUser
struct CollectionMemberUser: Codable, Hashable, Sendable {
    let username: String
    let name: String?
}

