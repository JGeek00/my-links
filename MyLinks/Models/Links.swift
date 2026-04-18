import Foundation

// MARK: - LinksResponse
struct LinksResponse: Codable {
    let response: [Link]?
}

// MARK: - SearchResponse
struct SearchLinksResponse: Codable {
    let data: SearchLinks?
    let success: Bool
    let message: String
}

// MARK: - SearchLinks
struct SearchLinks: Codable {
    let links: [Link]?
}

// MARK: - LinkResponse
struct LinkResponse: Codable {
    let response: Link?
}

// MARK: - Link
struct Link: Codable, Hashable {
    let id: Int
    let type: LinkType
    let name, description: String
    let url: String?
    let preview, image, pdf, monolith: String?
    let readable, lastPreserved: String?
    let importDate: String?
    let createdAt, updatedAt: String
    let tags: [TagInfo]
    let collection: LinkCollection
    let pinnedBy: [PinnedBy]
}

// MARK: - LinkCollection
struct LinkCollection: Codable, Hashable {
    let id: Int
    let name: String
    let description, color: String?
    let parentId: Int?
    let isPublic: Bool
    let ownerId: Int
    let createdAt, updatedAt: String
}

// MARK: - PinnedBy
struct PinnedBy: Codable, Hashable {
    let id: Int
}

// MARK: - TagInfo
struct TagInfo: Codable, Hashable {
    let id: Int
    let name: String
    let ownerId: Int
    let createdAt, updatedAt: String
}

enum LinkType: String, Codable, Hashable {
    case url
    case pdf
    case image
}
