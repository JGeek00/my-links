import Foundation

// MARK: - FileDataResponse
struct FileDataResponse: Codable {
    let response: FileResponse?
}

// MARK: - FileResponse
struct FileResponse: Codable {
    let file: [FileData]?
}

// MARK: - FileData
struct FileData: Codable {
    let size: Int?
    let filepath, newFilename, mimetype, mtime: String?
    let originalFilename: String?
}
