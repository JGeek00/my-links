import SwiftUI
import UIKit
import WebKit

struct EmbeddedBrowserWebView: UIViewRepresentable {
    var viewModel: EmbeddedBrowserViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        context.coordinator.startObserving(webView: webView)
        viewModel.webView = webView
        if let url = viewModel.initialURL {
            webView.load(URLRequest(url: url))
        } else {
            viewModel.failInvalidURL()
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate {
        private let viewModel: EmbeddedBrowserViewModel
        private var progressObservation: NSKeyValueObservation?
        private var scrollObservation: NSKeyValueObservation?
        private var lastOffsetY: CGFloat = 0
        private var pendingShowDistance: CGFloat = 0
        private let showBarUpwardThreshold: CGFloat = 120
        private let maxShowDistancePerEvent: CGFloat = 32

        init(viewModel: EmbeddedBrowserViewModel) {
            self.viewModel = viewModel
        }

        func startObserving(webView: WKWebView) {
            progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
                guard let self, let value = change.newValue else { return }
                Task { @MainActor in
                    self.viewModel.didUpdateProgress(value)
                }
            }
            scrollObservation = webView.scrollView.observe(\.contentOffset, options: [.new]) { [weak self, weak webView] _, change in
                guard let self, let webView, let y = change.newValue?.y else { return }
                let scrollView = webView.scrollView
                guard scrollView.contentSize.height > scrollView.bounds.height else { return }
                if y <= -scrollView.adjustedContentInset.top {
                    self.lastOffsetY = y
                    self.pendingShowDistance = 0
                    Task { @MainActor in
                        self.viewModel.setBottomBarHidden(false)
                    }
                    return
                }
                let delta = y - self.lastOffsetY
                self.lastOffsetY = y
                if delta > 0 {
                    self.pendingShowDistance = 0
                    guard delta > 8 else { return }
                    Task { @MainActor in
                        self.viewModel.setBottomBarHidden(true)
                    }
                } else if delta < 0 {
                    // ponytail: hysteresis — reveal only after sustained upward scroll,
                    // capping each event so a layout jump can't trigger it
                    self.pendingShowDistance += min(-delta, self.maxShowDistancePerEvent)
                    guard self.pendingShowDistance >= self.showBarUpwardThreshold else { return }
                    self.pendingShowDistance = 0
                    Task { @MainActor in
                        self.viewModel.setBottomBarHidden(false)
                    }
                }
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            lastOffsetY = webView.scrollView.contentOffset.y
            pendingShowDistance = 0
            Task { @MainActor in
                self.viewModel.didStartLoading()
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            Task { @MainActor in
                self.viewModel.didFinish(
                    url: webView.url,
                    canGoBack: webView.canGoBack,
                    canGoForward: webView.canGoForward
                )
            }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            guard isCancelled(error) == false else { return }
            Task { @MainActor in
                self.viewModel.didFail(canGoBack: webView.canGoBack, canGoForward: webView.canGoForward)
            }
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            guard isCancelled(error) == false else { return }
            Task { @MainActor in
                self.viewModel.didFail(canGoBack: webView.canGoBack, canGoForward: webView.canGoForward)
            }
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            if let scheme = url.scheme, scheme == "http" || scheme == "https" {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
                UIApplication.shared.open(url)
            }
        }

        private func isCancelled(_ error: Error) -> Bool {
            (error as NSError).code == NSURLErrorCancelled
        }
    }
}
