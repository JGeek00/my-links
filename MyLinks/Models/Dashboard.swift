import Foundation

// MARK: - DashboardV2Response
struct DashboardV2Response: Codable {
    let data: DataClass?
    let message: String?
}

// MARK: - DataClass
struct DataClass: Codable {
    let links: [Link]?
    let numberOfPinnedLinks: Int?
}
