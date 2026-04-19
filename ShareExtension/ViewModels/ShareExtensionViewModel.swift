import Foundation
import CoreData
import SwiftUI

@MainActor
@Observable
class ShareExtensionViewModel {
    @ObservationIgnored private let apiClientRepository: ShareExtensionApiClientRepository
    
    var invalidUrl = false
    
    var serverInstanceAvailable: Bool {
        get { return apiClientRepository.instance != nil }
    }
    
    var url = ""
    var name = ""
    var description = ""
    var collection = 0
    var selectedTags: [String] = []
    
    var collections: [Collection] = []
    
    var loading = true
    var loadError = false
    
    var saving = false
    var saveError = false
    
    init(url: String) {
        self.apiClientRepository = ShareExtensionRepositoriesContainer.shared.apiClientRepository
        self.url = url
        
        self.postInit()
    }
    
    init(apiClientRepository: ShareExtensionApiClientRepository, url: String) {
        self.apiClientRepository = apiClientRepository
        self.url = url
        
        self.postInit()
    }
    
    private func postInit() {
        if NSPredicate(format: "SELF MATCHES %@", Regexps.url).evaluate(with: url) == false {
            DispatchQueue.main.async {
                self.invalidUrl = true
            }
        }
    }
    
    func loadData() async {
        guard let instance = apiClientRepository.instance else { return }
        let collectionsResult = await instance.collections.fetchCollections()
        if let data = collectionsResult.data?.response {
            DispatchQueue.main.async {
                let sorted = data.sorted() { $0.name < $1.name }
                if let first = sorted.first {
                    self.collection = first.id
                }
                self.collections = sorted
                self.loading = false
                self.loadError = false
            }
        }
        else {
            DispatchQueue.main.async {
                self.loadError = true
                self.loading = false
            }
        }
    }
    
    func onSave(success: @escaping () -> Void) {
        guard let instance = apiClientRepository.instance else { return }
        
        let col = collections.first(where: { $0.id == collection })
        
        let body = LinkCreationRequest(
            url: url,
            name: name,
            description: description,
            tags: selectedTags.map() { TagCreation(name: $0) },
            collection: col != nil ? CollectionCreation(id: col!.id, name: col!.name, ownerId: col!.ownerId) : nil,
            pinnedBy: [],
            image: nil,
            pdf: nil,
        )
        
        DispatchQueue.main.async {
            self.saving = true
        }
        
        Task {
            let result = await instance.links.createLink(body)
            if result.successful == true {
                success()
            }
            else {
                DispatchQueue.main.async {
                    self.saving = false
                    self.saveError = true
                }
            }
        }
    }
    
   func getCollectionName() -> String? {
        let col = collections.first(where: { $0.id == collection })
        return col?.name
    }
}
