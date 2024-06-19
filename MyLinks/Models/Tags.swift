import Foundation

// MARK: - Tags
struct Tags: Codable {
    let response: [Tag]?
}

// MARK: - Tag
struct Tag: Codable, Hashable {
    let id: Int?
    let name: String?
    let ownerId: Int?
    let createdAt, updatedAt: String?
    let _count: TagCount?
}

// MARK: - TagCount
struct TagCount: Codable, Hashable {
    let links: Int?
}
