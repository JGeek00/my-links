import Foundation

struct FilesApiClient: Equatable, @unchecked Sendable {
    let apiClient: ApiClient

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    func fetchReader(linkId: Int) async -> StatusResponse<ReaderResponse> {
        return await apiClient.get("/api/v1/archives/\(linkId)", query: ["format": "3"])
    }

    func fetchWebpageHtml(linkId: Int) async -> StatusResponse<String> {
        return await apiClient.getString("/api/v1/archives/\(linkId)", query: ["format": "4"])
    }

    func fetchPdf(linkId: Int) async -> StatusResponse<Data> {
        return await apiClient.getData("/api/v1/archives/\(linkId)", query: ["format": "2"], contentType: .pdf)
    }

    func fetchImage(linkId: Int, isFile: Bool = false) async -> StatusResponse<Data> {
        let format = isFile ? "0" : "1"
        return await apiClient.getData("/api/v1/archives/\(linkId)", query: ["format": format], contentType: .png)
    }
}
