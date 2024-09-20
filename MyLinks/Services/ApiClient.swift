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
        let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
        
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
    var url: String
    var token: String
    
    init(url: String, token: String) {
        self.url = url
        self.token = token
    }
    
    func fetchDashboardV2() async -> StatusResponse<DashboardV2Response> {
        let defaultErrorResponse = StatusResponse<DashboardV2Response>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v2/dashboard") else { return defaultErrorResponse }
        do {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.queryItems = [
              URLQueryItem(name: "pinnedOnly", value: "true"),
              URLQueryItem(name: "sort", value: "0"),
            ]
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(DashboardV2Response.self, from: data)
                return StatusResponse<DashboardV2Response>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<DashboardV2Response>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func fetchDashboard() async -> StatusResponse<LinksResponse> {
        let defaultErrorResponse = StatusResponse<LinksResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/dashboard") else { return defaultErrorResponse }
        do {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.queryItems = [
              URLQueryItem(name: "pinnedOnly", value: "true"),
              URLQueryItem(name: "sort", value: "0"),
            ]
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(LinksResponse.self, from: data)
                return StatusResponse<LinksResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<LinksResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func fetchCollections() async -> StatusResponse<CollectionsResponse> {
        let defaultErrorResponse = StatusResponse<CollectionsResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/collections") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(CollectionsResponse.self, from: data)
                return StatusResponse<CollectionsResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<CollectionsResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func fetchTags() async -> StatusResponse<TagsResponse> {
        let defaultErrorResponse = StatusResponse<TagsResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/tags") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(TagsResponse.self, from: data)
                return StatusResponse<TagsResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<TagsResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func createLink(_ body: LinkCreationRequest) async -> StatusResponse<LinkResponse> {
        let defaultErrorResponse = StatusResponse<LinkResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/links") else { return defaultErrorResponse }
        do {            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(LinkResponse.self, from: data)
                return StatusResponse<LinkResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<LinkResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func uploadLinkFile(linkId: Int, fileUrl: URL, fileType: Enums.DownloadDocumentType) async -> StatusResponse<FileDataResponse> {
        func fileFormatNumber() -> String {
            switch fileType {
            case .pdf:
                return "2"
            case .image:
                return "0"
            }
        }
        
        func getContentType() -> String {
            if fileUrl.pathExtension.lowercased() == "pdf" {
                return "application/pdf"
            }
            else if fileUrl.pathExtension.lowercased() == "png" {
                return "image/png"
            }
            else if fileUrl.pathExtension.lowercased() == "jpg" || fileUrl.pathExtension.lowercased() == "jpeg" {
                return "image/jpeg"
            }
            else {
                return ""
            }
        }
        
        let defaultErrorResponse = StatusResponse<FileDataResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/archives/\(linkId)?format=\(fileFormatNumber())") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            let boundary = UUID().uuidString
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
                    
            var body = Data()
            body += Data("--\(boundary)\r\n".utf8)
            body += Data("Content-Disposition: form-data; name=\"file\"".utf8)
            if let fileContent = try? Data(contentsOf: fileUrl) {
                body += Data("; filename=\"\(fileUrl.lastPathComponent)\"\r\n".utf8)
                body += Data("Content-Type: \(getContentType())\r\n".utf8)
                body += Data("\r\n".utf8)
                body += fileContent
                body += Data("\r\n".utf8)
            }
            body += Data("--\(boundary)--\r\n".utf8);
            request.httpBody = body
                        
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(FileDataResponse.self, from: data)
                return StatusResponse<FileDataResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<FileDataResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func editLink(linkId: Int, body: LinkCreationRequest) async -> StatusResponse<LinkResponse> {
        let defaultErrorResponse = StatusResponse<LinkResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/links/\(linkId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(LinkResponse.self, from: data)
                return StatusResponse<LinkResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<LinkResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func createCollection(_ body: CollectionCreationRequest) async -> StatusResponse<CollectionResponse> {
        let defaultErrorResponse = StatusResponse<CollectionResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/collections") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(CollectionResponse.self, from: data)
                return StatusResponse<CollectionResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<CollectionResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func editCollection(collectionId: Int, body: CollectionCreationRequest) async -> StatusResponse<CollectionResponse> {
        let defaultErrorResponse = StatusResponse<CollectionResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/collections/\(collectionId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(CollectionResponse.self, from: data)
                return StatusResponse<CollectionResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<CollectionResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func fetchLinks(
        cursor: Int? = nil, 
        collectionId: Int? = nil,
        tagId: Int? = nil,
        pinnedOnly: Bool? = nil,
        recentOnly: Bool? = nil,
        searchQueryString: String? = nil,
        searchByName: Bool? = true,
        sort: Int? = nil
    ) async -> StatusResponse<LinksResponse> {
        let defaultErrorResponse = StatusResponse<LinksResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/links") else { return defaultErrorResponse }
        do {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            var queryItems: [URLQueryItem] = []
            if cursor != nil {
                queryItems.append(URLQueryItem(name: "cursor", value: "\(cursor!)"))
            }
            if collectionId != nil {
                queryItems.append(URLQueryItem(name: "collectionId", value: "\(collectionId!)"))
            }
            if tagId != nil {
                queryItems.append(URLQueryItem(name: "tagId", value: "\(tagId!)"))
            }
            if pinnedOnly != nil {
                queryItems.append(URLQueryItem(name: "pinnedOnly", value: "\(pinnedOnly!)"))
            }
            if recentOnly != nil {
                queryItems.append(URLQueryItem(name: "recentOnly", value: "\(recentOnly!)"))
            }
            if searchQueryString != nil {
                queryItems.append(URLQueryItem(name: "searchQueryString", value: "\(searchQueryString!)"))
            }
            if searchByName != nil {
                queryItems.append(URLQueryItem(name: "searchByName", value: "\(searchByName!)"))
            }
            if sort != nil {
                queryItems.append(URLQueryItem(name: "sort", value: "\(sort!)"))
            }
            components.queryItems = queryItems
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(LinksResponse.self, from: data)
                return StatusResponse<LinksResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<LinksResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func deleteLink(linkId: Int) async -> StatusResponse<LinkResponse> {
        let defaultErrorResponse = StatusResponse<LinkResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/links/\(linkId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(LinkResponse.self, from: data)
                return StatusResponse<LinkResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<LinkResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func deleteCollection(collectionId: Int) async -> StatusResponse<Bool> {
        let defaultErrorResponse = StatusResponse<Bool>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/collections/\(collectionId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<Bool>(successful: true, statusCode: response.statusCode, data: true)
            }
            else {
                return StatusResponse<Bool>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func fetchReader(linkId: Int) async -> StatusResponse<ReaderResponse> {
        let defaultErrorResponse = StatusResponse<ReaderResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/archives/\(linkId)?format=3") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(ReaderResponse.self, from: data)
                return StatusResponse<ReaderResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<ReaderResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func fetchWebpageHtml(linkId: Int) async -> StatusResponse<String> {
        let defaultErrorResponse = StatusResponse<String>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/archives/\(linkId)?format=4") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<String>(successful: true, statusCode: response.statusCode, data: String(decoding: data, as: UTF8.self))
            }
            else {
                return StatusResponse<String>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let e {
            print(e.localizedDescription)
            return defaultErrorResponse
        }
    }
    
    func fetchPdf(linkId: Int) async -> StatusResponse<Data> {
        let defaultErrorResponse = StatusResponse<Data>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/archives/\(linkId)?format=2") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("application/pdf", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<Data>(successful: true, statusCode: response.statusCode, data: data)
            }
            else {
                return StatusResponse<Data>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func fetchImage(linkId: Int) async -> StatusResponse<Data> {
        let defaultErrorResponse = StatusResponse<Data>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/archives/\(linkId)?format=1") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("application/png", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<Data>(successful: true, statusCode: response.statusCode, data: data)
            }
            else {
                return StatusResponse<Data>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
}
