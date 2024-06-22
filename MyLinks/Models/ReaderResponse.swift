import Foundation

// MARK: - ReaderResponse
struct ReaderResponse: Codable {
    let title: String?
    let byline, dir, lang: String?
    let content, textContent: String?
    let length: Int?
    let excerpt: String?
    let siteName: String?
}
