import Foundation

class CollectionOrTagsLinksViewModel: ObservableObject {
    static let shared = CollectionOrTagsLinksViewModel()
    
    @Published var input: CollectionOrTagLinksRequest? = nil
    
    @Published var data: Links? = nil
    @Published var loading = true
    @Published var error = false

    func loadData(setLoading: Bool = false) async {
        if input == nil || (input?.collectionId == nil && input?.tagId == nil) {
            return
        }
        
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let dashboardResult = await instance.fetchLinks(collectionId: input?.collectionId, tagId: input?.tagId)
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
