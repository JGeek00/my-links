import SwiftUI

@MainActor
@Observable
class DocumentDownloaderViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let toastRepository: ToastRepository
    
    let linkId: Int
    let documentType: Enums.DownloadDocumentType
    let onClose: () -> Void
    
    init(linkId: Int, documentType: Enums.DownloadDocumentType, onClose: @escaping () -> Void, apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, toastRepository: ToastRepository = RepositoriesContainer.shared.toastRepository) {
        self.apiClientRepository = apiClientRepository
        self.toastRepository = toastRepository
        self.linkId = linkId
        self.documentType = documentType
        self.onClose = onClose
    }
    
    func downloadDocument() async {
        guard let instance = apiClientRepository.instance else { return }
        let result = switch documentType {
        case .pdf:
            await instance.files.fetchPdf(linkId: linkId)
        case .image:
            await instance.files.fetchImage(linkId: linkId)
        }
        if result.successful == true {
            if let saveUrl = getSaveDir() {
                do {
                    try result.data!.write(to: saveUrl)
                    DispatchQueue.main.async {
                        switch self.documentType {
                        case .pdf:
                            self.toastRepository.showToast(icon: "checkmark", title: String(localized: "PDF file saved"))
                        case .image:
                            self.toastRepository.showToast(icon: "checkmark", title: String(localized: "Image saved"))
                        }
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        switch self.documentType {
                        case .pdf:
                            self.toastRepository.showToast(icon: "xmark", title: String(localized: "Error when saving the PDF file"))
                        case .image:
                            self.toastRepository.showToast(icon: "xmark", title: String(localized: "Error when saving the image"))
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
                apiClientRepository.destroy()
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
}
