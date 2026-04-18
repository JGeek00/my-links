import Foundation
import PDFKit

func getSessionToken(baseUrl: String, body: SessionTokenRequest) async -> StatusResponse<SessionToken> {
    let defaultErrorResponse = StatusResponse<SessionToken>(successful: false, statusCode: nil, data: nil)
    
    guard let url = URL(string: "\(baseUrl)/api/v1/session") else { return defaultErrorResponse }
    do {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try CustomJSONEncoder().encode(body)
        
        let sessionConfig = URLSessionConfiguration.default
        let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
        
        let (data, r) = try await session.data(for: request)
        guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
        if response.statusCode < 400 {
            let formatted = try JSONDecoder().decode(SessionToken.self, from: data)
            return StatusResponse<SessionToken>(successful: true, statusCode: response.statusCode, data: formatted)
        }
        else {
            return StatusResponse<SessionToken>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
        }
    } catch {
        return defaultErrorResponse
    }
}

struct ApiClient: Equatable {
    private let instance: ServerApiInstance
    
    let links: LinksApiClient
    let collections: CollectionsApiClient
    let tags: TagsApiClient
    let dashboard: DashboardApiClient
    let files: FilesApiClient
    
    init(instance: ServerApiInstance) {
        self.instance = instance
        self.links = LinksApiClient(instance: instance)
        self.collections = CollectionsApiClient(instance: instance)
        self.tags = TagsApiClient(instance: instance)
        self.dashboard = DashboardApiClient(instance: instance)
        self.files = FilesApiClient(instance: instance)
    }
    
    func getInstanceUrl() -> String {
        return instance.url
    }
    
    func getIsSelfHosted() -> Bool {
        return instance.isSelfHosted
    }
}
