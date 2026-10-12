import SwiftUI

struct EmbeddedBrowserView: View {
    @State private var viewModel: EmbeddedBrowserViewModel
    /// When false, the scroll-driven toolbar collapse is disabled.
    let collapsibleToolbar: Bool

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(link: Link, collapsibleToolbar: Bool = true) {
        _viewModel = State(initialValue: EmbeddedBrowserViewModel(link: link))
        self.collapsibleToolbar = collapsibleToolbar
    }

    private var isRegular: Bool {
        horizontalSizeClass == .regular
    }

    private var isToolbarVisible: Bool {
        // Foldables never collapse, open or closed.
        FoldableDevice.shared.isFoldable || collapsibleToolbar == false || viewModel.bottomBarHidden == false
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        Group {
            if viewModel.loadFailed {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the page. Check your Internet connection and try again later.")
                    Button {
                        viewModel.reload()
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
            } else {
                EmbeddedBrowserWebView(viewModel: viewModel)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack {
                    if viewModel.showProgress {
                        ProgressView(value: viewModel.progress, total: 1)
                            .accessibilityLabel("Loading progress")
                            .transition(.opacity)
                    }
                    if let domain = viewModel.domain {
                        Text(domain)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .padding(.top, 6)
                    }
                }
                .frame(width: 160)
                .transition(.opacity)
                .animation(.default, value: viewModel.showProgress)
            }
            if isRegular {
                ToolbarItemGroup(placement: .topBarLeading) {
                    backForwardButtons()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    reloadButton()
                }
            } else {
                if isToolbarVisible {
                    ToolbarItemGroup(placement: .bottomBar) {
                        backForwardButtons()
                        Spacer()
                        reloadButton()
                    }
                }
            }
        }
        .animation(.default, value: viewModel.bottomBarHidden)
    }

    // MARK: - Toolbar buttons

    @ViewBuilder
    private func backForwardButtons() -> some View {
        Button {
            viewModel.goBack()
        } label: {
            Label("Back", systemImage: "chevron.left")
        }
        .disabled(viewModel.canGoBack == false)
        Button {
            viewModel.goForward()
        } label: {
            Label("Forward", systemImage: "chevron.right")
        }
        .disabled(viewModel.canGoForward == false)
    }

    @ViewBuilder
    private func reloadButton() -> some View {
        Button {
            viewModel.reload()
        } label: {
            Label("Reload", systemImage: "arrow.counterclockwise")
        }
        .disabled(viewModel.initialURL == nil)
    }
}
