import Foundation

struct DashboardApiClient: Equatable {
    let instance: ServerApiInstance
    
    init(instance: ServerApiInstance) {
        self.instance = instance
    }
    
    func fetchDashboard() async -> StatusResponse<DashboardResponse> {
        let defaultErrorResponse = StatusResponse<DashboardResponse>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.instance.url)/api/v2/dashboard") else { return defaultErrorResponse }
        do {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            components.queryItems = [
              URLQueryItem(name: "pinnedOnly", value: "true"),
              URLQueryItem(name: "sort", value: "0"),
            ]
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.instance.token)", forHTTPHeaderField: "Authorization")

            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)
            
            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(DashboardResponse.self, from: data)
                return StatusResponse<DashboardResponse>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<DashboardResponse>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
}

