import Foundation

class ReaderViewModel: ObservableObject {
    @Published var data: ReaderResponse? = nil
    @Published var loading = true
    @Published var error = false
    
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
        let result = await instance.fetchReader(linkId: linkId)
        if result.successful == true {
            DispatchQueue.main.async {
                self.data = result.data!
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
