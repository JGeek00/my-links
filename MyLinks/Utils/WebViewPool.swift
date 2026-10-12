import Foundation
import WebKit

/// Reuses `WKWebView` instances keyed by `link.id`: the pooled view survives
/// layout swaps (which destroy the SwiftUI subtree), preserving the live page.
@MainActor
final class WebViewPool {
    static let shared = WebViewPool(maxEntries: 8)

    private let maxEntries: Int
    private var cache: [Int: Entry] = [:]
    private var order: [Int] = []

    private struct Entry {
        let webView: WKWebView
        /// URL the view was created for. Only a seed mismatch reloads (edited
        /// link); user in-page navigation moves `webView.url` but keeps the seed.
        let seedURL: URL?
    }

    init(maxEntries: Int) {
        self.maxEntries = max(1, maxEntries)
    }

    func acquire(for linkId: Int, seedURL: URL?) -> WKWebView {
        if let entry = cache[linkId] {
            touch(linkId: linkId)
            return entry.webView
        }
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        cache[linkId] = Entry(webView: webView, seedURL: seedURL)
        order.append(linkId)
        evictIfNeeded()
        return webView
    }

    func seedURL(for linkId: Int) -> URL? {
        cache[linkId]?.seedURL
    }

    func remove(linkId: Int) {
        guard let entry = cache.removeValue(forKey: linkId) else { return }
        order.removeAll { $0 == linkId }
        entry.webView.stopLoading()
        entry.webView.navigationDelegate = nil
    }

    func removeAll() {
        for entry in cache.values {
            entry.webView.stopLoading()
            entry.webView.navigationDelegate = nil
        }
        cache.removeAll()
        order.removeAll()
    }

    private func touch(linkId: Int) {
        order.removeAll { $0 == linkId }
        order.append(linkId)
    }

    private func evictIfNeeded() {
        while order.count > maxEntries, let oldest = order.first {
            order.removeFirst()
            if let entry = cache.removeValue(forKey: oldest) {
                entry.webView.stopLoading()
                entry.webView.navigationDelegate = nil
            }
        }
    }
}
