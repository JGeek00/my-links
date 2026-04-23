import SwiftUI

struct DocumentDownloaderView: View {
    @State private var documentDownloaderViewModel: DocumentDownloaderViewModel
    
    init(linkId: Int, documentType: Enums.DownloadDocumentType, onClose: @escaping () -> Void) {
        _documentDownloaderViewModel = State(initialValue: DocumentDownloaderViewModel(linkId: linkId, documentType: documentType, onClose: onClose))
    }
    
    var body: some View {
        VStack {
            ProgressView()
            Spacer()
                .frame(height: 24)
            Group {
                switch documentDownloaderViewModel.documentType {
                case .pdf:
                    Text("Downloading PDF...")
                case .image:
                    Text("Downloading image...")
                }
            }
            .font(.system(size: 20))
            .fontWeight(.medium)
        }
        .padding(24)
        .task {
            await documentDownloaderViewModel.downloadDocument()
        }
    }
}
