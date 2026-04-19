import Foundation

struct FilesApiClient: Equatable {
    let instance: ServerApiInstance
    
    init(instance: ServerApiInstance) {
        self.instance = instance
    }
    
    func fetchReader(linkId: Int) async -> StatusResponse<ReaderResponse> {
        let defaultErrorResponse = StatusResponse<ReaderResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/archives/\(linkId)?format=3") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/archives/\(linkId)?format=4") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                return StatusResponse<String>(successful: true, statusCode: response.statusCode, data: String(decoding: data, as: UTF8.self))
            }
            else {
                return StatusResponse<String>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
    
    func fetchPdf(linkId: Int) async -> StatusResponse<Data> {
        let defaultErrorResponse = StatusResponse<Data>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/archives/\(linkId)?format=2") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("application/pdf", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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
        
        guard let url = URL(string: "\(self.instance.url)/api/v1/archives/\(linkId)?format=1") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            request.httpMethod = "GET"
            request.addValue("application/png", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
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

