import SwiftUI

struct EmbeddedBrowserView: View {
    @State private var viewModel: EmbeddedBrowserViewModel

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    init(link: Link) {
        _viewModel = State(initialValue: EmbeddedBrowserViewModel(link: link))
    }

    private var isRegular: Bool {
        horizontalSizeClass == .regular
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
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Group {
                    if viewModel.isLoading {
                        ProgressView(value: viewModel.progress, total: 1)
                            .accessibilityLabel("Loading progress")
                    } else if let domain = viewModel.domain {
                        Text(domain)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .frame(width: 160)
                .transition(.opacity)
                .animation(.default, value: viewModel.isLoading)
            }
            if isRegular {
                ToolbarItemGroup(placement: .topBarLeading) {
                    backForwardButtons(viewModel: viewModel)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    reloadButton(viewModel: viewModel)
                }
            } else {
                if viewModel.bottomBarHidden == false {
                    ToolbarItemGroup(placement: .bottomBar) {
                        backForwardButtons(viewModel: viewModel)
                        Spacer()
                        reloadButton(viewModel: viewModel)
                    }
                }
            }
        }
        .animation(.default, value: viewModel.bottomBarHidden)
    }

    // MARK: - Toolbar buttons

    @ViewBuilder
    private func backForwardButtons(viewModel: EmbeddedBrowserViewModel) -> some View {
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
    private func reloadButton(viewModel: EmbeddedBrowserViewModel) -> some View {
        Button {
            viewModel.reload()
        } label: {
            Label("Reload", systemImage: "arrow.counterclockwise")
        }
        .disabled(viewModel.initialURL == nil)
    }
}
