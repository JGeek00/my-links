import Foundation

// MARK: - TagsResponse
struct TagsResponse: Codable, Hashable {
    let data: TagsResponse_DataClass?
    let success: Bool
    let message: String
}

// MARK: - TagsResponse_DataClass
struct TagsResponse_DataClass: Codable, Hashable {
    let tags: [Tag]
    let nextCursor: Int?
}

// MARK: - Tag
struct Tag: Codable, Hashable {
    let id: Int
    var name: String
    let ownerID: Int
    let aiGenerated: Bool
    let createdAt, updatedAt: String
    let count: Tag_Count?

    enum CodingKeys: String, CodingKey {
        case id, name
        case ownerID = "ownerId"
        case aiGenerated, createdAt, updatedAt
        case count = "_count"
    }
}

// MARK: - Tag_Count
struct Tag_Count: Codable, Hashable {
    let links: Int
}
