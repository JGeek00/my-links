import Foundation

// MARK: - CreateTagResponse
struct CreateTagResponse: Codable, Hashable {
    let response: [CreateTagResponse_Tag]
}

// MARK: - CreateTagResponse_Tag
struct CreateTagResponse_Tag: Codable, Hashable {
    let id: Int
    let name: String
    let ownerID: Int
    let aiGenerated: Bool
    let createdAt, updatedAt: String
    let count: CreateTagResponse_Tag_Count

    enum CodingKeys: String, CodingKey {
        case id, name
        case ownerID = "ownerId"
        case aiGenerated, createdAt, updatedAt
        case count = "_count"
    }
}

// MARK: - CreateTagResponse_Tag_Count
struct CreateTagResponse_Tag_Count: Codable, Hashable {
    let links: Int
}

