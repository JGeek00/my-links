import Foundation
import CoreData
import SwiftUI

@MainActor
@Observable
class MenuBarFormViewModel {
    @ObservationIgnored private let apiClientRepository: MenuBarApiClientRepository
    
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
    
    var validationErrorMessage = ""
    var validationErrorAlert = false
    
    var saving = false
    var savingErrorAlert = false
    var linkCreatedAlert = false
    
    init(apiClientRepository: MenuBarApiClientRepository =  MenuBarRepositoriesContainer.shared.apiClientRepository) {
        self.apiClientRepository = apiClientRepository
        
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
    
    func onSave() {
        guard let instance = apiClientRepository.instance else { return }
        
        if NSPredicate(format: "SELF MATCHES %@", Regexps.url).evaluate(with: url) == false {
            self.validationErrorMessage = "The introduced URL is not valid."
            self.validationErrorAlert = true
            return
        }
        
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
                DispatchQueue.main.async {
                    self.linkCreatedAlert = true
                }
            }
            else {
                DispatchQueue.main.async {
                    self.saving = false
                    self.savingErrorAlert = true
                }
            }
        }
    }
    
   func getCollectionName() -> String? {
        let col = collections.first(where: { $0.id == collection })
        return col?.name
    }
}
