import Foundation

// MARK: - DashboardV2Response
struct DashboardV2Response: Codable, Sendable {
    let data: DataClass?
    let message: String?
}

// MARK: - DataClass
struct DataClass: Codable, Sendable {
    let links: [Link]?
    let numberOfPinnedLinks: Int?
}
