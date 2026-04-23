import Foundation
import SwiftUI

@MainActor
@Observable
class HTMLViewerViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored let link: Link
    @ObservationIgnored let mode: Enums.HTMLViewerMode
    
    init(apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, link: Link, mode: Enums.HTMLViewerMode) {
        self.apiClientRepository = apiClientRepository
        self.link = link
        self.mode = mode
    }
    
    var readerData: ReaderResponse? = nil
    var htmlData: String? = nil
    var loading = true
    var error = false
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        switch mode {
        case .reader:
            let result = await instance.files.fetchReader(linkId: link.id)
            if result.successful == true {
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self.readerData = result.data!
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
        case .webpage:
            let result = await instance.files.fetchWebpageHtml(linkId: link.id)
            if result.successful == true {
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self.htmlData = result.data!
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
}
