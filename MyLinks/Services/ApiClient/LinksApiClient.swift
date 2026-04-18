import Foundation

struct LinksApiClient: Equatable {
    let instance: ServerApiInstance
    
    init(instance: ServerApiInstance) {
        self.instance = instance
    }
    
    func createLink(_ body: LinkCreationRequest) async -> StatusResponse<LinkResponse> {
        let defaultErrorResponse = StatusResponse<LinkResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/links") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            let body = try CustomJSONEncoder().encode(body)
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = body
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/archives/\(linkId)?format=\(fileFormatNumber())") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            let boundary = UUID().uuidString
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
                    
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
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
    
    func editLink(linkId: Int, body: LinkEditingRequest) async -> StatusResponse<LinkResponse> {
        let defaultErrorResponse = StatusResponse<LinkResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/links/\(linkId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            let body = try CustomJSONEncoder().encode(body)
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = body

            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)

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
        let defaultErrorResponse = StatusResponse<SearchLinksResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/search") else { return defaultErrorResponse }
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
            
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")

            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(SearchLinksResponse.self, from: data)
                return StatusResponse<SearchLinksResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<SearchLinksResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
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
        sort: Int? = nil,
    ) async -> StatusResponse<LinksResponse> {
        let defaultErrorResponse = StatusResponse<LinksResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/links") else { return defaultErrorResponse }
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
            
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")

            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/links/\(linkId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
}

