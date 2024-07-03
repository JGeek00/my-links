import SwiftUI
import RichText

struct ReaderModeViewer: View {
    var link: Link
    var onClose: () -> Void
    
    @StateObject private var readerViewModel: ReaderViewModel
    
    init(link: Link, onClose: @escaping () -> Void) {
        self.link = link
        self.onClose = onClose
        _readerViewModel = StateObject(wrappedValue: ReaderViewModel())
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if readerViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if readerViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the reader view. Check your Internet connection and try again later.")
                        Button {
                            Task { await readerViewModel.loadData(linkId: link.id!, setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    RichText(html: readerViewModel.data!.content!)
                        .padding()
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
                        Task { await readerViewModel.loadData(linkId: link.id!, setLoading: true) }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(readerViewModel.data == nil || readerViewModel.loading == true)
                }
            }
        }
        .onAppear {
            Task { await readerViewModel.loadData(linkId: link.id!) }
        }
    }
}
