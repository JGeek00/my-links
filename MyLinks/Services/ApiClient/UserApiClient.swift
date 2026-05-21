import Foundation

struct UserApiClient: Equatable, @unchecked Sendable {
    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func fetchUsers() async -> StatusResponse<UserDataResponse> {
        return await apiClient.get("/api/v1/users/me")
    }
}
