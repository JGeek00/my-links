import Foundation
import SwiftUI

@MainActor
@Observable
class CollectionFormViewModel {
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    
    var editingCollection: Collection? = nil
    var name = ""
    var description = ""
    var color: Color = .accentColor
    
    var saving = false
    
    var nameRequiredAlert = false
    var savingErrorMessage = ""
    var savingErrorAlert = false
    
    init(collectionsRepository: CollectionsRepository = RepositoriesContainer.shared.collectionsRepository, collectionId: Int? = nil) {
        self.collectionsRepository = collectionsRepository
        
        guard let collectionId = collectionId else { return }
        let collection = collectionsRepository.data.first(where: { $0.id == collectionId })
        if let collection = collection {
            self.editingCollection = collection
            self.name = collection.name
            self.description = collection.description ?? ""
            if let color = collection.color {
                self.color = Color(hex: color)
            }
        }
    }
    
    func onSave(parentId: Int? = nil, onCompleted: @escaping (Collection) -> Void) {
        if name == "" {
            self.nameRequiredAlert = true
            return
        }
                
        self.saving = true
        
        Task {
            if let editingCollection = editingCollection {
                let data = CollectionCreationRequest(
                    id: editingCollection.id,
                    name: name,
                    description: description,
                    color: color.toHex(),
                    members: [],
                    parentId: editingCollection.parent?.id,
                    parent: Parent(id: editingCollection.parent?.id, name: editingCollection.parent?.name)
                )
                await collectionsRepository.editCollection(collectionId: editingCollection.id, body: data) { collection in
                    
                } onError: { statusCode in
                    if let statusCode = statusCode {
                        DispatchQueue.main.async {
                            self.saving = false
                            self.savingErrorMessage = "Error \(statusCode)."
                            self.savingErrorAlert = true
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.saving = false
                            self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                            self.savingErrorAlert = true
                        }
                    }
                }
            }
            else {
                let data = CollectionCreationRequest(
                    name: name,
                    description: description,
                    color: color.toHex(),
                    members: [],
                    parentId: parentId,
                    parent: nil
                )
                await collectionsRepository.createCollection(body: data) { collection in
                    
                } onError: { statusCode in
                    if let statusCode = statusCode {
                        DispatchQueue.main.async {
                            self.saving = false
                            self.savingErrorMessage = "Error \(statusCode)."
                            self.savingErrorAlert = true
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.saving = false
                            self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                            self.savingErrorAlert = true
                        }
                    }
                }
            }
        }
    }
}
