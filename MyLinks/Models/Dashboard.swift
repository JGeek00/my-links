import Foundation

// MARK: - Dashboard
struct Dashboard: Codable {
    let response: [DashboardResponse]?
}

// MARK: - DashboardResponse
struct DashboardResponse: Codable {
    let id: Int?
    let name, type, description: String?
    let collectionID: Int?
    let url: String?
    let textContent, preview, image, pdf: String?
    let readable, lastPreserved: String?
    let importDate: String?
    let createdAt, updatedAt: String?
    let tags: [Tag]?
    let collection: Collection?
    let pinnedBy: [PinnedBy]?
}

// MARK: - Collection
struct Collection: Codable {
    let id: Int?
    let name, description, color: String?
    let parentID: Int?
    let isPublic: Bool?
    let ownerID: Int?
    let createdAt, updatedAt: String?
}

// MARK: - PinnedBy
struct PinnedBy: Codable {
    let id: Int?
}

// MARK: - Tag
struct Tag: Codable {
    let id: Int?
    let name: String?
    let ownerID: String?
    let createdAt, updatedAt: String?
}
