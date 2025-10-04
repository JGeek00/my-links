import SwiftUI

struct DocumentDownloaderView: View {
    var linkId: Int
    var documentType: Enums.DownloadDocumentType
    var onClose: () -> Void
    
    init(linkId: Int, documentType: Enums.DownloadDocumentType, onClose: @escaping () -> Void) {
        self.linkId = linkId
        self.documentType = documentType
        self.onClose = onClose
    }
    
    private func downloadDocument() async {
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = switch documentType {
        case .pdf:
            await instance.fetchPdf(linkId: linkId)
        case .image:
            await instance.fetchImage(linkId: linkId)
        }
        if result.successful == true {
            if let saveUrl = getSaveDir() {
                do {
                    try result.data!.write(to: saveUrl)
                    DispatchQueue.main.async {
                        switch documentType {
                        case .pdf:
                            ToastProvider.shared.showToast(icon: "checkmark", title: String(localized: "PDF file saved"))
                        case .image:
                            ToastProvider.shared.showToast(icon: "checkmark", title: String(localized: "Image saved"))
                        }
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        switch documentType {
                        case .pdf:
                            ToastProvider.shared.showToast(icon: "xmark", title: String(localized: "Error when saving the PDF file"))
                        case .image:
                            ToastProvider.shared.showToast(icon: "xmark", title: String(localized: "Error when saving the image"))
                        }
                    }
                }
                onClose()
            }
            else {
                onClose()
            }
        }
        else {
            if result.statusCode == 401 {
                ApiClientProvider.shared.destroy()
                return
            }
        }
    }
    
    private func getSaveDir() -> URL? {
        let savePanel = NSSavePanel()
        switch documentType {
        case .pdf:
            savePanel.allowedContentTypes = [.pdf]
        case .image:
            savePanel.allowedContentTypes = [.png]
        }
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        switch documentType {
        case .pdf:
            savePanel.title = String(localized: "Save the PDF document")
            savePanel.message = String(localized: "Choose a folder and a name to store the PDF.")
        case .image:
            savePanel.title = String(localized: "Save the image")
            savePanel.message = String(localized: "Choose a folder and a name to store the image.")
        }
        savePanel.nameFieldLabel = String(localized: "Name:")
        
        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }
    
    var body: some View {
        VStack {
            ProgressView()
            Spacer()
                .frame(height: 24)
            Group {
                switch documentType {
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
        .onAppear {
            Task { await downloadDocument() }
        }
    }
}
