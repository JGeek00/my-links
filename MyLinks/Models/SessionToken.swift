import Foundation

// MARK: - SessionTokenRequest
class SessionTokenRequest: Codable {
    let username: String
    let password: String
    let sessionName: String
    
    init(username: String, password: String, sessionName: String) {
        self.username = username
        self.password = password
        self.sessionName = sessionName
    }
}

// MARK: - SessionTokenResponse
struct SessionToken: Codable {
    let response: SessionTokenResponse?
}

// MARK: - SessionTokenResponse
struct SessionTokenResponse: Codable {
    let token: String?
}
