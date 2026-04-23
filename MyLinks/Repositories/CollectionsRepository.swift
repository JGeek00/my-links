import Foundation
import SwiftUI

@MainActor
@Observable
class CollectionsRepository {
    let apiClientRepository: ApiClientRepository
    
    init(apiClientRepository: ApiClientRepository) {
        self.apiClientRepository = apiClientRepository
    }
        
    var data: [Collection] = []
    var loading = true
    var error = false
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.collections.fetchCollections()
        if let data = result.data?.response {
            DispatchQueue.main.async {
                if result.data?.response != nil {
                    self.data = data.sorted() { $0.name < $1.name }
                }
                else {
                    self.data = []
                }
                self.loading = false
                self.error = false
            }
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            DispatchQueue.main.async {
                self.loading = false
                self.error = true
            }
        }
    }
    
    func deleteCollection(id: Int, setDeleting: @escaping (Bool) -> Void, setSuccess: @escaping () -> Void, setError: @escaping (Int?) -> Void) async {
        guard let instance = apiClientRepository.instance else { return }
        setDeleting(true)
        let result = await instance.collections.deleteCollection(collectionId: id)
        if result.successful == true {
            DispatchQueue.main.async {
                setDeleting(false)
                setSuccess()
            }
            Task { await self.loadData() }
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            DispatchQueue.main.async {
                setDeleting(false)
                setError(result.statusCode)
            }
        }
    }
    
    func editCollection(collectionId: Int, body: CollectionCreationRequest, onSuccess: @escaping (Collection) -> Void, onError: @escaping (Int?) -> Void) async {
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.collections.editCollection(collectionId: collectionId, body: body)
        if let data = result.data?.response {
            onSuccess(data)
            await loadData()
        }
        else {
            if result.statusCode == 401 {
               apiClientRepository.destroy()
                return
            }
            onError(result.statusCode)
        }
    }
    
    func createCollection(body: CollectionCreationRequest, onSuccess: @escaping (Collection) -> Void, onError: @escaping (Int?) -> Void) async {
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.collections.createCollection(body)
        if let data = result.data?.response {
            onSuccess(data)
            await loadData()
        }
        else {
            if result.statusCode == 401 {
               apiClientRepository.destroy()
                return
            }
            onError(result.statusCode)
        }
    }
    
    func updateCollectionLocal(newCollection: Collection) {
        self.data = self.data.map() { item in
            if item.id == newCollection.id {
                return newCollection
            }
            else {
                return item
            }
        }
    }
}
