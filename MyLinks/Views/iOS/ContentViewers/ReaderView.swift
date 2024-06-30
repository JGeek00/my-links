import SwiftUI
import RichText

struct ReaderView: View {
    var link: Link
    var onClose: () -> Void
    
    @StateObject private var readerViewModel: ReaderViewModel
    
    init(link: Link, onClose: @escaping () -> Void) {
        self.link = link
        self.onClose = onClose
        _readerViewModel = StateObject(wrappedValue: ReaderViewModel(link: link))
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
            .background(Color.listBackground)
            .navigationTitle(link.name! != "" ? link.name! : link.description! != "" ? link.description! : link.url!)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await readerViewModel.loadData(linkId: link.id!, setLoading: true) }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .disabled(readerViewModel.data == nil || readerViewModel.loading == true)
                }
            }
        }
    }
}
