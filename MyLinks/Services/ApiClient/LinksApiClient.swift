import Foundation

struct LinksApiClient: Equatable, @unchecked Sendable {
    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func createLink(_ body: LinkCreationRequest) async -> StatusResponse<LinkResponse> {
        return await apiClient.post("/api/v1/links", body: body)
    }

    func uploadLinkFile(linkId: Int, fileUrl: URL, fileType: Enums.DownloadDocumentType) async -> StatusResponse<FileDataResponse> {
        let format = switch fileType {
        case .pdf: "2"
        case .image: "0"
        }
        return await apiClient.postMultipart(
            "/api/v1/archives/\(linkId)",
            fileUrl: fileUrl,
            query: ["format": format]
        )
    }

    func editLink(linkId: Int, body: LinkEditingRequest) async -> StatusResponse<LinkResponse> {
        return await apiClient.put("/api/v1/links/\(linkId)", body: body)
    }

    func searchLiks(
        cursor: Int? = nil,
        collectionId: Int? = nil,
        tagId: Int? = nil,
        pinnedOnly: Bool? = nil,
        recentOnly: Bool? = nil,
        searchQueryString: String? = nil,
        searchByName: Bool? = true,
        sort: Int? = nil,
    ) async -> StatusResponse<SearchLinksResponse> {
        var query: [String: String] = [:]
        if let cursor { query["cursor"] = String(cursor) }
        if let collectionId { query["collectionId"] = String(collectionId) }
        if let tagId { query["tagId"] = String(tagId) }
        if let pinnedOnly { query["pinnedOnly"] = String(pinnedOnly) }
        if let recentOnly { query["recentOnly"] = String(recentOnly) }
        if let searchQueryString { query["searchQueryString"] = searchQueryString }
        if let searchByName { query["searchByName"] = String(searchByName) }
        if let sort { query["sort"] = String(sort) }
        return await apiClient.get("/api/v1/search", query: query.isEmpty ? nil : query)
    }

    func fetchLinks(
        cursor: Int? = nil,
        collectionId: Int? = nil,
        tagId: Int? = nil,
        pinnedOnly: Bool? = nil,
        recentOnly: Bool? = nil,
        searchQueryString: String? = nil,
        searchByName: Bool? = true,
        sort: Int? = nil,
    ) async -> StatusResponse<LinksResponse> {
        var query: [String: String] = [:]
        if let cursor { query["cursor"] = String(cursor) }
        if let collectionId { query["collectionId"] = String(collectionId) }
        if let tagId { query["tagId"] = String(tagId) }
        if let pinnedOnly { query["pinnedOnly"] = String(pinnedOnly) }
        if let recentOnly { query["recentOnly"] = String(recentOnly) }
        if let searchQueryString { query["searchQueryString"] = searchQueryString }
        if let searchByName { query["searchByName"] = String(searchByName) }
        if let sort { query["sort"] = String(sort) }
        return await apiClient.get("/api/v1/links", query: query.isEmpty ? nil : query)
    }

    func deleteLink(linkId: Int) async -> StatusResponse<DeletedLinkResponse> {
        return await apiClient.delete("/api/v1/links/\(linkId)")
    }
}
