import Foundation

// MARK: - TagsResponse
struct TagsResponse: Codable, Hashable {
    let data: TagsResponse_DataClass?
    let success: Bool
    let message: String
}

// MARK: - TagsResponse_DataClass
struct TagsResponse_DataClass: Codable, Hashable {
    let tags: [TagsResponse_DataClass_Tag]
    let nextCursor: Int?
}

// MARK: - TagsResponse_DataClass_Tag
struct TagsResponse_DataClass_Tag: Codable, Hashable {
    let id: Int
    let name: String
    let ownerID: Int
    let aiGenerated: Bool
    let createdAt, updatedAt: String
    let count: TagsResponse_Tag_Count

    enum CodingKeys: String, CodingKey {
        case id, name
        case ownerID = "ownerId"
        case aiGenerated, createdAt, updatedAt
        case count = "_count"
    }
}

// MARK: - TagsResponse_Tag_Count
struct TagsResponse_Tag_Count: Codable, Hashable {
    let links: Int
}
