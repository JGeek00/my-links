import Foundation

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

class ApiClient: Equatable, @unchecked Sendable {
    private let instance: ServerApiInstance

   lazy var links: LinksApiClient = LinksApiClient(apiClient: self)
    lazy var collections: CollectionsApiClient = CollectionsApiClient(apiClient: self)
    lazy var tags: TagsApiClient = TagsApiClient(apiClient: self)
    lazy var dashboard: DashboardApiClient = DashboardApiClient(apiClient: self)
    lazy var files: FilesApiClient = FilesApiClient(apiClient: self)
    lazy var users: UserApiClient = UserApiClient(apiClient: self)

    init(instance: ServerApiInstance) {
        self.instance = instance
    }

    func getInstanceUrl() -> String {
        return instance.url
    }

    func getIsSelfHosted() -> Bool {
        return instance.isSelfHosted
    }

    static func == (lhs: ApiClient, rhs: ApiClient) -> Bool {
        lhs === rhs
    }

    // MARK: - Private helpers

    private func buildRequest(
        path: String,
        method: String,
        query: [String: String]? = nil,
        body: Data? = nil,
        contentType: Enums.ContentType
    ) -> URLRequest {
        let fullPath = instance.url + path
        guard let url = URL(string: fullPath) else {
            fatalError("Invalid URL: \(fullPath)")
        }

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        if let query = query, !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        var request = URLRequest(url: components.url!)
        request.httpMethod = method
        request.addValue("Bearer \(instance.token)", forHTTPHeaderField: "Authorization")
        request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }

        return request
    }

    private func executeRequest<T: Decodable>(_ request: URLRequest, as responseType: T.Type) async -> StatusResponse<T> {
        let defaultErrorResponse = StatusResponse<T>(successful: false, statusCode: nil, data: nil)

        do {
            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)

            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return StatusResponse<T>(successful: true, statusCode: response.statusCode, data: decoded)
            }
            else {
                return StatusResponse<T>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }

    // MARK: - GET

    func get<T: Decodable>(
        _ path: String,
        query: [String: String]? = nil,
        contentType: Enums.ContentType = .json
    ) async -> StatusResponse<T> {
        let request = buildRequest(path: path, method: "GET", query: query, contentType: contentType)
        return await executeRequest(request, as: T.self)
    }

    // MARK: - POST with body

    func post<T: Decodable, B: Encodable>(
        _ path: String,
        body: B,
        contentType: Enums.ContentType = .json
    ) async -> StatusResponse<T> {
        let bodyData = try? CustomJSONEncoder().encode(body)
        let request = buildRequest(path: path, method: "POST", body: bodyData, contentType: contentType)
        return await executeRequest(request, as: T.self)
    }

    // MARK: - POST without body

    func post<T: Decodable>(
        _ path: String,
        contentType: Enums.ContentType = .json
    ) async -> StatusResponse<T> {
        let request = buildRequest(path: path, method: "POST", contentType: contentType)
        return await executeRequest(request, as: T.self)
    }

    // MARK: - PUT with body

    func put<T: Decodable, B: Encodable>(
        _ path: String,
        body: B,
        contentType: Enums.ContentType = .json
    ) async -> StatusResponse<T> {
        let bodyData = try? CustomJSONEncoder().encode(body)
        let request = buildRequest(path: path, method: "PUT", body: bodyData, contentType: contentType)
        return await executeRequest(request, as: T.self)
    }

    // MARK: - PUT without body

    func put<T: Decodable>(
        _ path: String,
        contentType: Enums.ContentType = .json
    ) async -> StatusResponse<T> {
        let request = buildRequest(path: path, method: "PUT", contentType: contentType)
        return await executeRequest(request, as: T.self)
    }

    // MARK: - DELETE

    func delete<T: Decodable>(
        _ path: String,
        query: [String: String]? = nil
    ) async -> StatusResponse<T> {
        let request = buildRequest(path: path, method: "DELETE", query: query, contentType: .json)
        return await executeRequest(request, as: T.self)
    }

    // MARK: - Raw Data response

    func getData(
        _ path: String,
        query: [String: String]? = nil,
        contentType: Enums.ContentType = .json
    ) async -> StatusResponse<Data> {
        let defaultErrorResponse = StatusResponse<Data>(successful: false, statusCode: nil, data: nil)
        let request = buildRequest(path: path, method: "GET", query: query, contentType: contentType)

        do {
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

    // MARK: - String response

    func getString(
        _ path: String,
        query: [String: String]? = nil,
        contentType: Enums.ContentType = .json
    ) async -> StatusResponse<String> {
        let defaultErrorResponse = StatusResponse<String>(successful: false, statusCode: nil, data: nil)
        let request = buildRequest(path: path, method: "GET", query: query, contentType: contentType)

        do {
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

    // MARK: - Multipart file upload

    func postMultipart<T: Decodable>(
        _ path: String,
        fileUrl: URL,
        query: [String: String]? = nil
    ) async -> StatusResponse<T> {
        let defaultErrorResponse = StatusResponse<T>(successful: false, statusCode: nil, data: nil)

        func getFileContentType() -> String {
            let ext = fileUrl.pathExtension.lowercased()
            switch ext {
            case "pdf": return "application/pdf"
            case "png": return "image/png"
            case "jpg", "jpeg": return "image/jpeg"
            default: return ""
            }
        }

        guard let url = URL(string: instance.url + path) else { return defaultErrorResponse }

        do {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            if let query = query, !query.isEmpty {
                components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
            }

            let boundary = UUID().uuidString

            var request = URLRequest(url: components.url!)
            request.httpMethod = "POST"
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.addValue("Bearer \(instance.token)", forHTTPHeaderField: "Authorization")

            var body = Data()
            body += Data("--\(boundary)\r\n".utf8)
            body += Data("Content-Disposition: form-data; name=\"file\"".utf8)
            if let fileContent = try? Data(contentsOf: fileUrl) {
                body += Data("; filename=\"\(fileUrl.lastPathComponent)\"\r\n".utf8)
                body += Data("Content-Type: \(getFileContentType())\r\n".utf8)
                body += Data("\r\n".utf8)
                body += fileContent
                body += Data("\r\n".utf8)
            }
            body += Data("--\(boundary)--\r\n".utf8)
            request.httpBody = body

            let sessionConfig = URLSessionConfiguration.default
            let session = await URLSession(configuration: sessionConfig, delegate: SSLIgnoringDelegate(), delegateQueue: nil)

            let (data, r) = try await session.data(for: request)
            guard let response = r as? HTTPURLResponse else { return defaultErrorResponse }
            if response.statusCode < 400 {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return StatusResponse<T>(successful: true, statusCode: response.statusCode, data: decoded)
            }
            else {
                return StatusResponse<T>(successful: false, statusCode: response.statusCode, rawBody: String(data: data, encoding: .utf8))
            }
        } catch {
            return defaultErrorResponse
        }
    }
}
