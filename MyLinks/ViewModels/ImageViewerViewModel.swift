import Foundation
import SwiftUI

@MainActor
@Observable
class ImageViewerViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let link: Link
  
    init(link: Link) {
        self.apiClientRepository = RepositoriesContainer.shared.apiClientRepository
        self.link = link
    }
    
    init(apiClientRepository: ApiClientRepository, link: Link) {
        self.apiClientRepository = apiClientRepository
        self.link = link
    }
    
    var data: Data? = nil
    var imageData: UIImage? = nil
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
        let result = await instance.files.fetchImage(linkId: link.id)
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
