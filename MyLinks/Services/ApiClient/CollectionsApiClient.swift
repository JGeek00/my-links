import Foundation

struct CollectionsApiClient: Equatable {
    let instance: ServerApiInstance
    
    init(instance: ServerApiInstance) {
        self.instance = instance
    }
    
    func fetchCollections() async -> StatusResponse<CollectionsResponse> {
        let defaultErrorResponse = StatusResponse<CollectionsResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/collections") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
    
    func createCollection(_ body: CollectionCreationRequest) async -> StatusResponse<CollectionResponse> {
        let defaultErrorResponse = StatusResponse<CollectionResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/collections") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/collections/\(collectionId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
    
    func deleteCollection(collectionId: Int) async -> StatusResponse<Bool> {
        let defaultErrorResponse = StatusResponse<Bool>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/collections/\(collectionId)") else { return defaultErrorResponse }
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
                return StatusResponse<Bool>(successful: true, statusCode: response.statusCode, data: true)
            }
            else {
                return StatusResponse<Bool>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
}

