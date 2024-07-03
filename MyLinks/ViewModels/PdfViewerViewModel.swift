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
            if result.statusCode == 401 {
                ApiClientProvider.shared.destroy()
                return
            }
            DispatchQueue.main.async {
                self.error = true
                self.loading = false
            }
        }
    }
}
