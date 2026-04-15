import Foundation

// MARK: - DeleteTagResponse
struct DeleteTagResponse: Codable, Hashable {
    let response: [DeleteTagResponse_Tag]
}

// MARK: - DeleteTagResponse_Tag
struct DeleteTagResponse_Tag: Codable, Hashable {
    let id: Int
    let name: String
    let ownerID: Int
    let aiGenerated: Bool
    let createdAt, updatedAt: String
    let count: DeleteTagResponse_Tag_Count

    enum CodingKeys: String, CodingKey {
        case id, name
        case ownerID = "ownerId"
        case aiGenerated, createdAt, updatedAt
        case count = "_count"
    }
}

// MARK: - DeleteTagResponse_Tag_Count
struct DeleteTagResponse_Tag_Count: Codable, Hashable {
    let links: Int
}

