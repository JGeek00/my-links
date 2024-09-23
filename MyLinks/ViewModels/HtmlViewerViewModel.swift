import Foundation

@MainActor
class HTMLViewerViewModel: ObservableObject {
    let link: Link
    let mode: Enums.HTMLViewerMode
    
    init(link: Link, mode: Enums.HTMLViewerMode) {
        self.link = link
        self.mode = mode
    }
    
    @Published var readerData: ReaderResponse? = nil
    @Published var htmlData: String? = nil
    @Published var loading = true
    @Published var error = false
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        switch mode {
        case .reader:
            let result = await instance.fetchReader(linkId: link.id!)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.readerData = result.data!
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
        case .webpage:
            let result = await instance.fetchWebpageHtml(linkId: link.id!)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.htmlData = result.data!
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
}
