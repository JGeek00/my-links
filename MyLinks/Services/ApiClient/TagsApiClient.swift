import Foundation

struct TagsApiClient: Equatable {
    let instance: ServerApiInstance
    
    init(instance: ServerApiInstance) {
        self.instance = instance
    }
    
    func fetchTags(page: Int? = nil, sort: Int? = nil, search: String? = nil) async -> StatusResponse<TagsResponse> {
        let defaultErrorResponse = StatusResponse<TagsResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/tags") else { return defaultErrorResponse }
        do {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

            var queryItems = components.queryItems ?? []
            if let page = page {
                queryItems.append(URLQueryItem(name: "cursor", value: String(page)))
            }
            if let sort = sort {
                queryItems.append(URLQueryItem(name: "sort", value: String(sort)))
            }
            if let search = search {
                queryItems.append(URLQueryItem(name: "search", value: search))
            }
            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }

            var request = URLRequest(url: components.url!)

            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")

            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
    
    func createTag(_ body: TagCreationRequest) async -> StatusResponse<CreateTagResponse> {
        let defaultErrorResponse = StatusResponse<CreateTagResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/tags") else { return defaultErrorResponse }
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
                let formatted = try JSONDecoder().decode(CreateTagResponse.self, from: data)
                return StatusResponse<CreateTagResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<CreateTagResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func deleteTag(tagId: Int) async -> StatusResponse<UpdateTagResponse> {
        let defaultErrorResponse = StatusResponse<UpdateTagResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/tags/\(tagId)") else { return defaultErrorResponse }
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
                let formatted = try JSONDecoder().decode(UpdateTagResponse.self, from: data)
                return StatusResponse<UpdateTagResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<UpdateTagResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func editTag(tagId: Int, body: Tag) async -> StatusResponse<UpdateTagResponse> {
        let defaultErrorResponse = StatusResponse<UpdateTagResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/tags/\(tagId)") else { return defaultErrorResponse }
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
                let formatted = try JSONDecoder().decode(UpdateTagResponse.self, from: data)
                return StatusResponse<UpdateTagResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<UpdateTagResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
}

