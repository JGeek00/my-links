import SwiftUI
import RichText

struct HTMLViewer: View {
    var link: Link
    var mode: Enums.HTMLViewerMode
    var onClose: () -> Void
    
    @State private var htmlViewerViewModel: HTMLViewerViewModel
    
    init(link: Link, mode: Enums.HTMLViewerMode, onClose: @escaping () -> Void) {
        self.link = link
        self.mode = mode
        self.onClose = onClose
        _htmlViewerViewModel = State(initialValue: HTMLViewerViewModel(link: link, mode: mode))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if htmlViewerViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                }
                else if htmlViewerViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the content. Check your Internet connection and try again later.")
                        Button {
                            Task { await htmlViewerViewModel.loadData(setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                    .transition(.opacity)
                }
                else {
                    switch mode {
                    case .reader:
                        if let content = htmlViewerViewModel.readerData?.content {
                            RichText(html: content)
                                .placeholder {
                                    ProgressView()
                                }
                                .padding()
                        }
                        else {
                            ContentUnavailableView {
                                Label("Error", systemImage: "exclamationmark.circle")
                            } description: {
                                Text("Content not available. Try again later.")
                            }
                            .transition(.opacity)
                        }
                    case .webpage:
                        if let content = htmlViewerViewModel.htmlData {
                            RichText(html: content)
                                .placeholder {
                                    ProgressView()
                                }
                        }
                        else {
                            ContentUnavailableView {
                                Label("Error", systemImage: "exclamationmark.circle")
                            } description: {
                                Text("Content not available. Try again later.")
                            }
                            .transition(.opacity)
                        }
                    }
                }
            }
            .background(Color.listBackground)
            .navigationTitle(link.name != "" ? link.name : link.description != "" ? link.description : link.url ?? String(localized: "HTML viewer"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        onClose()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await htmlViewerViewModel.loadData(setLoading: true) }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled((htmlViewerViewModel.htmlData == nil && htmlViewerViewModel.readerData == nil) || htmlViewerViewModel.loading == true)
                }
            }
        }
        .task {
            await htmlViewerViewModel.loadData()
        }
    }
}
