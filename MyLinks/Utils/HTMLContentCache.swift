import Foundation

/// Fetched HTML/reader content by `link.id`, so a recreated `HTMLViewer`
/// doesn't refetch. `loadData(forceRefresh: true)` bypasses the cache.
@MainActor
final class HTMLContentCache {
    static let shared = HTMLContentCache()

    private var reader: [Int: ReaderResponse] = [:]
    private var webpage: [Int: String] = [:]

    func readerData(linkId: Int) -> ReaderResponse? {
        reader[linkId]
    }

    func webpageHtml(linkId: Int) -> String? {
        webpage[linkId]
    }

    func storeReader(_ data: ReaderResponse, linkId: Int) {
        reader[linkId] = data
    }

    func storeWebpage(_ html: String, linkId: Int) {
        webpage[linkId] = html
    }

    func remove(linkId: Int) {
        reader.removeValue(forKey: linkId)
        webpage.removeValue(forKey: linkId)
    }

    func removeAll() {
        reader.removeAll()
        webpage.removeAll()
    }
}
