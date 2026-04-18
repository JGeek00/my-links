import Foundation
import SwiftUI

@MainActor
class ImageViewerViewModel: ObservableObject {
    @Published var data: Data? = nil
    @Published var imageData: UIImage? = nil
    @Published var loading = true
    @Published var error = false
    
    @Published var downloadedFilePath: URL? = nil
    @Published var saveDocumentSheet = false
    
    @Published var savingErrorAlert = false
    @Published var savingErrorMessage = ""
    
    init(link: Link) {
        Task { await self.loadData(linkId: link.id) }
    }
    
    func loadData(linkId: Int, setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.files.fetchImage(linkId: linkId)
        if result.successful == true {
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.data = result.data!
                    self.imageData = UIImage(data: result.data!)
                    self.loading = false
                    self.error = false
                }
            }
        }
        else {
            if result.statusCode == 401 {
                ApiClientProvider.shared.destroy()
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
