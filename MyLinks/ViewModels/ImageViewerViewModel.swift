import Foundation
import SwiftUI

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
        Task { await self.loadData(linkId: link.id!) }
    }
    
    func loadData(linkId: Int, setLoading: Bool = false) async {
        if setLoading == true {
            DispatchQueue.main.sync {
                self.loading = true
            }
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.fetchImage(linkId: linkId)
        if result.successful == true {
            DispatchQueue.main.async {
                self.data = result.data!
                self.imageData = UIImage(data: result.data!)
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
}
