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
        
    var data: [Collection] = []
    var loading = true
    var error = false
    
    var deleteError = false
    
    func loadData(setLoading: Bool = false) async {
        await collectionsRepository.loadData(setLoading: setLoading)
        self.data = collectionsRepository.data
        self.loading = collectionsRepository.loading
        self.error = collectionsRepository.error
    }
    
    func handleCollectionCreated(collection: Collection) {
        var newData = self.data + [collection]
        newData = newData.sorted() { $0.name.lowercased() < $1.name.lowercased() }
        self.data = newData
    }
    
    func handleDeleteCollection(collectionId: Int) {
        Task {
            await collectionsRepository.deleteCollection(id: collectionId) { del in
                DispatchQueue.main.async { self.progressIndicatorRepository.presenting = del }
            } setSuccess: {
                DispatchQueue.main.async {
                    self.data = self.data.filter() { $0.id != collectionId }
                }
            } setError: { _ in
                DispatchQueue.main.async {
                    self.deleteError = true
                }
            }
        }
    }
    
    func handleEditCollection(collection: Collection) {
        self.data = self.data.map() { item in
            if item.id == collection.id {
                return collection
            }
            else {
                return item
            }
        }
    }
}
