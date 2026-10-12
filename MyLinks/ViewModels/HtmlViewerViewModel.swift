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
    
    func loadData(setLoading: Bool = false, forceRefresh: Bool = false) async {
        // Layout-driven `.task` re-runs use the cache; explicit reloads bypass it.
        if forceRefresh == false {
            switch mode {
            case .reader:
                if let cached = HTMLContentCache.shared.readerData(linkId: link.id) {
                    withAnimation(.default) {
                        self.readerData = cached
                        self.loading = false
                        self.error = false
                    }
                    return
                }
                if readerData != nil {
                    withAnimation(.default) {
                        self.loading = false
                        self.error = false
                    }
                    return
                }
            case .webpage:
                if let cached = HTMLContentCache.shared.webpageHtml(linkId: link.id) {
                    withAnimation(.default) {
                        self.htmlData = cached
                        self.loading = false
                        self.error = false
                    }
                    return
                }
                if htmlData != nil {
                    withAnimation(.default) {
                        self.loading = false
                        self.error = false
                    }
                    return
                }
            }
        }
        if setLoading == true || forceRefresh == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        switch mode {
        case .reader:
            let result = await instance.files.fetchReader(linkId: link.id)
            if result.successful == true {
                let data = result.data!
                HTMLContentCache.shared.storeReader(data, linkId: self.link.id)
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self.readerData = data
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
                let html = result.data!
                HTMLContentCache.shared.storeWebpage(html, linkId: self.link.id)
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self.htmlData = html
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
