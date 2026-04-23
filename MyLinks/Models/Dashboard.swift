import Foundation

// MARK: - DashboardResponse
struct DashboardResponse: Codable, Sendable, Equatable {
    let data: DashboardResponse_Data?
    let message: String
}

// MARK: - DashboardResponse_Data
struct DashboardResponse_Data: Codable, Sendable, Equatable {
    var links: [Link]
    let numberOfPinnedLinks: Int
    let numberOfTags: Int
}
