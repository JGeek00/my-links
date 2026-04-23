import Foundation
import SwiftUI

@MainActor
@Observable
class CollectionsViewModel {
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let progressIndicatorRepository: ProgressIndicatorRepository
    
    init(collectionsRepository: CollectionsRepository = RepositoriesContainer.shared.collectionsRepository, progressIndicatorRepository: ProgressIndicatorRepository = RepositoriesContainer.shared.progressIndicatorRepository) {
        self.collectionsRepository = collectionsRepository
        self.progressIndicatorRepository = progressIndicatorRepository
    }
        
    var data: [Collection] {
        get { collectionsRepository.data }
        set { collectionsRepository.data = newValue }
    }
    var loading: Bool {
        get { collectionsRepository.loading }
    }
    var error: Bool {
        get { collectionsRepository.error }
    }
    
    var deleteError = false
    
    func loadData(setLoading: Bool = false) async {
        await collectionsRepository.loadData(setLoading: setLoading)
    }
    
    func handleCollectionCreated(collection: Collection) {
        Task { await self.loadData(setLoading: false) }
    }
    
    func handleDeleteCollection(collectionId: Int) {
        Task {
            await collectionsRepository.deleteCollection(id: collectionId) { del in
                self.progressIndicatorRepository.presenting = del
            }
        }
    }
}
