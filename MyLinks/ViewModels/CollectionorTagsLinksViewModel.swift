import Foundation

class CollectionorTagsLinksViewModel: ObservableObject {    
    @Published var data: Links? = nil
    @Published var loading = true
    @Published var error = false

    func loadData(collectionId: Int? = nil, tagId: Int? = nil, setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let dashboardResult = await instance.fetchLinks(collectionId: collectionId, tagId: tagId)
        if dashboardResult.successful == true {
            DispatchQueue.main.async {
                self.data = dashboardResult.data!
                self.loading = false
                self.error = false
            }
        }
        else {
            DispatchQueue.main.async {
                self.loading = false
                self.error = true
            }
        }
    }
}
