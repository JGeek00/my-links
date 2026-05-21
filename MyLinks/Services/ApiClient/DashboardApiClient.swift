import Foundation

struct DashboardApiClient: Equatable, @unchecked Sendable {
    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func fetchDashboard() async -> StatusResponse<DashboardResponse> {
        return await apiClient.get(
            "/api/v2/dashboard",
            query: ["pinnedOnly": "true", "sort": "0"]
        )
    }
}
