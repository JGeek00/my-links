import Foundation

class ApiClient {
    var url: String
    var token: String
    
    init(url: String, token: String) {
        self.url = url
        self.token = token
    }
    
    func fetchDashboard() async -> StatusResponse<Dashboard> {
        let defaultErrorResponse = StatusResponse<Dashboard>(successful: false, statusCode: nil, data: nil)
        
        guard let url = URL(string: "\(self.url)/api/v1/dashboard") else { return defaultErrorResponse }
        do {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            
            var request = URLRequest(url: components.url!)
            
            request.addValue("Bearer \(self.token)", forHTTPHeaderField: "Authorization")
            
            let (data, r) = try await URLSession.shared.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let formatted = try JSONDecoder().decode(Dashboard.self, from: data)
                return StatusResponse<Dashboard>(successful: true, statusCode: response.statusCode, data: formatted)
            }
            else {
                return StatusResponse<Dashboard>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch let error {
            return defaultErrorResponse
        }
    }
}
