import Foundation

// MARK: - Tags
struct TagsResponse: Codable {
    let response: [Tag]?
}

// MARK: - Tag
struct Tag: Codable, Hashable, Sendable {
    let aiGenerated: Bool?
    let aiTag: Bool?
    let archiveAsMonolith: Bool?
    let archiveAsPDF: Bool?
    let archiveAsReadable: Bool?
    let archiveAsScreenshot: Bool?
    let archiveAsWaybackMachine: Bool?
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
