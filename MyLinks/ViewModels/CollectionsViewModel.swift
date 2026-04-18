import Foundation
import SwiftUI

@MainActor
@Observable
class CollectionsViewModel {
    let collectionsRepository: CollectionsRepository
    
    init(collectionsRepository: CollectionsRepository) {
        self.collectionsRepository = collectionsRepository
    }
    
    convenience init() {
        self.init(collectionsRepository: RepositoriesContainer.shared.collectionsRepository)
    }
        
    var data: [Collection] = []
    var loading = true
    var error = false
    
    var deleting = false
    var deleteError = false
    
    func loadData(setLoading: Bool = false) async {
        await collectionsRepository.loadData(setLoading: setLoading)
        self.data = collectionsRepository.data
        self.loading = collectionsRepository.loading
        self.error = collectionsRepository.error
    }
}
