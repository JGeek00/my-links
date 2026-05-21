import Foundation

struct TagsApiClient: Equatable, @unchecked Sendable {
    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func fetchTags(page: Int? = nil, sort: Int? = nil, search: String? = nil) async -> StatusResponse<TagsResponse> {
        var query: [String: String] = [:]
        if let page { query["cursor"] = String(page) }
        if let sort { query["sort"] = String(sort) }
        if let search { query["search"] = search }
        return await apiClient.get("/api/v1/tags", query: query.isEmpty ? nil : query)
    }

    func createTag(_ body: TagCreationRequest) async -> StatusResponse<CreateTagResponse> {
        return await apiClient.post("/api/v1/tags", body: body)
    }

    func deleteTag(tagId: Int) async -> StatusResponse<UpdateTagResponse> {
        return await apiClient.delete("/api/v1/tags/\(tagId)")
    }

    func editTag(tagId: Int, body: Tag) async -> StatusResponse<UpdateTagResponse> {
        return await apiClient.put("/api/v1/tags/\(tagId)", body: body)
    }
}
