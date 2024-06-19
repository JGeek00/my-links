import Foundation

// MARK: - Tags
struct Tags: Codable {
    let response: [TagResponse]?
}

// MARK: - Response
struct TagResponse: Codable, Hashable {
    let id: Int?
    let name: String?
    let ownerID: Int?
    let createdAt, updatedAt: String?
    let count: TagCount?
}

// MARK: - TagCount
struct TagCount: Codable, Hashable {
    let links: Int?
}
