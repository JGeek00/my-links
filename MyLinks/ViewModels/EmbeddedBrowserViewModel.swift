import Foundation
import WebKit

// MARK: - EmbeddedBrowserViewModel
@MainActor
@Observable
final class EmbeddedBrowserViewModel {
    let link: Link

    var progress: Double = 0
    var isLoading: Bool = false
    var showProgress: Bool = true
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var loadFailed: Bool = false
    var bottomBarHidden: Bool = false

    @ObservationIgnored weak var webView: WKWebView?
    @ObservationIgnored private var hideProgressTask: Task<Void, Never>?

    var domain: String? {
        initialURL?.host
    }

    var initialURL: URL? {
        Self.validatedURL(from: link)
    }

    init(link: Link) {
        self.link = link
    }

    // MARK: - Validation

    static func validatedURL(from link: Link) -> URL? {
        guard let string = link.url,
            let url = URL(string: string),
            let scheme = url.scheme,
            scheme == "http" || scheme == "https",
            url.host != nil
        else { return nil }
        return url
    }

    // MARK: - Navigation intents

    func goBack() {
        webView?.goBack()
    }

    func goForward() {
        webView?.goForward()
    }

    func reload() {
        if webView?.url != nil {
            webView?.reload()
        } else if let url = initialURL {
            isLoading = true
            loadFailed = false
            progress = 0
            showProgress = true
            webView?.load(URLRequest(url: url))
        } else {
            failInvalidURL()
        }
    }

    // MARK: - Bottom bar visibility (Safari-like collapse)

    func setBottomBarHidden(_ hidden: Bool) {
        if bottomBarHidden != hidden {
            bottomBarHidden = hidden
        }
    }

    // MARK: - Loading callbacks (Coordinator)

    func didStartLoading() {
        isLoading = true
        loadFailed = false
        bottomBarHidden = false
        progress = 0
        hideProgressTask?.cancel()
        showProgress = true
    }

    func didUpdateProgress(_ value: Double) {
        progress = value
    }

    func didFinish(canGoBack: Bool, canGoForward: Bool) {
        isLoading = false
        loadFailed = false
        bottomBarHidden = false
        progress = 1
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
        // ponytail: keep the full bar visible briefly so completion reads, then fade it
        hideProgressTask?.cancel()
        hideProgressTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            self.showProgress = false
        }
    }

    func didFail(canGoBack: Bool, canGoForward: Bool) {
        isLoading = false
        loadFailed = true
        bottomBarHidden = false
        hideProgressTask?.cancel()
        showProgress = false
        self.canGoBack = canGoBack
        self.canGoForward = canGoForward
    }

    func failInvalidURL() {
        isLoading = false
        loadFailed = true
        hideProgressTask?.cancel()
        showProgress = false
    }
}
