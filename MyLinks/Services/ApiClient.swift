import Foundation

class ApiClient {
    var url: String
    var token: String
    
    init(url: String, token: String) {
        self.url = url
        self.token = token
    }
    
    func fetchDashboard() async -> StatusResponse<Links> {
        let defaultErrorResponse = StatusResponse<Links>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/dashboard") else { return defaultErrorResponse }
        do {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.queryItems = [
              URLQueryItem(name: "pinnedOnly", value: "true"),
              URLQueryItem(name: "sort", value: "0"),
            ]
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(Links.self, from: data)
                return StatusResponse<Links>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<Links>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
    
    func fetchCollections() async -> StatusResponse<Collections> {
        let defaultErrorResponse = StatusResponse<Collections>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/collections") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(Collections.self, from: data)
                return StatusResponse<Collections>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<Collections>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
    
    func fetchTags() async -> StatusResponse<Tags> {
        let defaultErrorResponse = StatusResponse<Tags>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/tags") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(Tags.self, from: data)
                return StatusResponse<Tags>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<Tags>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
    
    func createLink(_ body: LinkCreationRequest) async -> StatusResponse<Bool> {
        let defaultErrorResponse = StatusResponse<Bool>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/links") else { return defaultErrorResponse }
        do {            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<Bool>(successful: true, statusCode: response.statusCode, data: true)
            }
            else {
                return StatusResponse<Bool>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
    
    func editLink(linkId: Int, body: LinkCreationRequest) async -> StatusResponse<Bool> {
        let defaultErrorResponse = StatusResponse<Bool>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/links/\(linkId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<Bool>(successful: true, statusCode: response.statusCode, data: true)
            }
            else {
                return StatusResponse<Bool>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
    
    func createCollection(_ body: CollectionCreationRequest) async -> StatusResponse<Bool> {
        let defaultErrorResponse = StatusResponse<Bool>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/collections") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<Bool>(successful: true, statusCode: response.statusCode, data: true)
            }
            else {
                return StatusResponse<Bool>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
    
    func editCollection(collectionId: Int, body: CollectionCreationRequest) async -> StatusResponse<Bool> {
        let defaultErrorResponse = StatusResponse<Bool>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/collections/\(collectionId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            request.httpBody = try CustomJSONEncoder().encode(body)
            
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<Bool>(successful: true, statusCode: response.statusCode, data: true)
            }
            else {
                return StatusResponse<Bool>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
    
    func fetchLinks() async -> StatusResponse<Links> {
        let defaultErrorResponse = StatusResponse<Links>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/links") else { return defaultErrorResponse }
        do {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.queryItems = [
              URLQueryItem(name: "sort", value: "0"),
            ]
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")

            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(Links.self, from: data)
                return StatusResponse<Links>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<Links>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
    
    func deleteLink(linkId: Int) async -> StatusResponse<Bool> {
        let defaultErrorResponse = StatusResponse<Bool>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/links/\(linkId)") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "DELETE"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<Bool>(successful: true, statusCode: response.statusCode, data: true)
            }
            else {
                return StatusResponse<Bool>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
}
