import Foundation
import PDFKit

class PdfViewerViewModel: ObservableObject {
    @Published var pdfData: PDFDocument? = nil
    @Published var data: Data? = nil
    @Published var loading = true
    @Published var error = false
    
    @Published var downloadedFilePath: URL? = nil
    @Published var saveDocumentSheet = false
    
    @Published var savingErrorAlert = false
    @Published var savingErrorMessage = ""
    
    init(link: Link) {
        Task { await loadData(linkId: link.id!) }
    }
    
    func loadData(linkId: Int, setLoading: Bool = false) async {
        if setLoading == true {
            DispatchQueue.main.sync {
                self.loading = true
            }
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.fetchPdf(linkId: linkId)
        if result.successful == true {
            DispatchQueue.main.async {
                self.data = result.data!
                self.pdfData = PDFDocument(data: result.data!)
                self.loading = false
                self.error = false
            }
        }
        else {
            DispatchQueue.main.async {
                self.error = true
                self.loading = false
            }
        }
    }
    
    func saveDocumentToStorage(linkId: Int) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            self.savingErrorMessage = String(localized: "Unable to access document directory")
            self.savingErrorAlert = true
            return
        }
        guard let data = data else { return }
        let filePath = documentDirectory.appendingPathComponent("\(UUID().uuidString).pdf")
        do {
            try data.write(to: filePath)
            self.downloadedFilePath = filePath
            self.saveDocumentSheet = true
        } catch {
            self.savingErrorMessage = String(localized: "An error occured when saving the file")
            self.savingErrorAlert = true
        }
    }
}
