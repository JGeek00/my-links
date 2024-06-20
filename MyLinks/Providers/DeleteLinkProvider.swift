import Foundation

class DeleteLinkProvider: ObservableObject {
    static let shared = DeleteLinkProvider()
    
    @Published var deleting = false
    @Published var deleteError = false
    
    func deleteLink(id: Int, fromCollectionOrTagLinkView: Bool = false) {
        guard let instance = ApiClientProvider.shared.instance else { return }
        self.deleting = true
        Task {
            let result = await instance.deleteLink(linkId: id)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.deleting = false
                    self.deleteError = false
                    if DashboardViewModel.shared.data != nil {
                        Task { await DashboardViewModel.shared.loadData() }
                        Task { await LinksViewModel.shared.loadData() }
                        if fromCollectionOrTagLinkView == true {
                            Task { await CollectionOrTagsLinksViewModel.shared.loadData() }
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.deleting = false
                    self.deleteError = true
                }
            }
        }
    }
}
