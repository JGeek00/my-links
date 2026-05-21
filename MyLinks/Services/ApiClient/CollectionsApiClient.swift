import Foundation

struct CollectionsApiClient: Equatable, @unchecked Sendable {
    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func fetchCollections() async -> StatusResponse<CollectionsResponse> {
        return await apiClient.get("/api/v1/collections")
    }

    func createCollection(_ body: CollectionCreationRequest) async -> StatusResponse<CollectionResponse> {
        return await apiClient.post("/api/v1/collections", body: body)
    }

    func editCollection(collectionId: Int, body: CollectionCreationRequest) async -> StatusResponse<CollectionResponse> {
        return await apiClient.put("/api/v1/collections/\(collectionId)", body: body)
    }

    func deleteCollection(collectionId: Int) async -> StatusResponse<Bool> {
        return await apiClient.delete("/api/v1/collections/\(collectionId)")
    }
}
