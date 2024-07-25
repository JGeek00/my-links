import SwiftUI
import RichText

struct HTMLViewer: View {
    var link: Link
    var mode: Enums.HTMLViewerMode
    var onClose: () -> Void
    
    @StateObject private var htmlViewerViewModel: HTMLViewerViewModel
    
    init(link: Link, mode: Enums.HTMLViewerMode, onClose: @escaping () -> Void) {
        self.link = link
        self.mode = mode
        self.onClose = onClose
        _htmlViewerViewModel = StateObject(wrappedValue: HTMLViewerViewModel(link: link, mode: mode))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if htmlViewerViewModel.loading == true {
                    Group {
                        ProgressView()
                            .padding(48)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                else if htmlViewerViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the reader view. Check your Internet connection and try again later.")
                        Button {
                            Task { await htmlViewerViewModel.loadData(setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    switch mode {
                    case .reader:
                        if let content = htmlViewerViewModel.readerData?.content {
                            RichText(html: content)
                                .placeholder {
                                    ProgressView()
                                        .padding(36)
                                }
                                .padding()
                        }
                        else {
                            ContentUnavailableView {
                                Label("Error", systemImage: "exclamationmark.circle")
                            } description: {
                                Text("Content not available. Try again later.")
                            }
                        }
                    case .webpage:
                        if let content = htmlViewerViewModel.htmlData {
                            RichText(html: content)
                                .placeholder {
                                    Group {
                                        ProgressView()
                                            .padding(48)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                }
                        }
                        else {
                            ContentUnavailableView {
                                Label("Error", systemImage: "exclamationmark.circle")
                            } description: {
                                Text("Content not available. Try again later.")
                            }
                        }
                    }
                }
            }
            .navigationTitle(link.name! != "" ? link.name! : link.description! != "" ? link.description! : link.url!)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onClose()
                    } label: {
                        Text("Close")
                    }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        Task { await htmlViewerViewModel.loadData(setLoading: true) }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled((htmlViewerViewModel.htmlData == nil && htmlViewerViewModel.readerData?.content == nil) || htmlViewerViewModel.loading == true)
                }
            }
        }
        .frame(minWidth: 300, idealWidth: 800, minHeight: 300, idealHeight: 600)
        .onAppear {
            Task { await htmlViewerViewModel.loadData() }
        }
    }
}
