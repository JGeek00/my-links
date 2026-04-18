import Foundation
import PDFKit
import SwiftUI

@MainActor
@Observable
class PdfViewerViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    let linkId: Int
    
    init(apiClientRepisotory: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, linkId: Int) {
        self.apiClientRepository = apiClientRepisotory
        self.linkId = linkId
    }
    
    var pdfData: PDFDocument? = nil
    var data: Data? = nil
    var loading = true
    var error = false
    
    var downloadedFilePath: URL? = nil
    var saveDocumentSheet = false
    
    var savingErrorAlert = false
    var savingErrorMessage = ""
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.files.fetchPdf(linkId: linkId)
        if result.successful == true {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.data = result.data!
                    self.pdfData = PDFDocument(data: result.data!)
                    self.loading = false
                    self.error = false
                }
            }
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.error = true
                    self.loading = false
                }
            }
        }
    }
}
