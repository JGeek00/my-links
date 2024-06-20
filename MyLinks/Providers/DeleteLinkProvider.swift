import Foundation

class DeleteLinkProvider: ObservableObject {
    static let shared = DeleteLinkProvider()
    
    @Published var deleting = false
    @Published var deleteError = false
    
    func deleteLink(id: Int) async -> Bool {
        guard let instance = ApiClientProvider.shared.instance else { return false }
        DispatchQueue.main.async {
            self.deleting = true
        }
        let result = await instance.deleteLink(linkId: id)
        if result.successful == true {
            DispatchQueue.main.async {
                self.deleting = false
                self.deleteError = false
                if DashboardViewModel.shared.data != nil {
                    Task { await DashboardViewModel.shared.loadData() }
                    Task { await LinksViewModel.shared.loadData() }
                    Task { await CollectionsProvider.shared.loadData() }
                    Task { await TagsProvider.shared.loadData() }
                }
            }
            return true
        }
        else {
            DispatchQueue.main.async {
                self.deleting = false
                self.deleteError = true
            }
            return false
        }
    }
}
