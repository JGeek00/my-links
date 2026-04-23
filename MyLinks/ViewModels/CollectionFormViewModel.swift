import Foundation
import SwiftUI

@MainActor
@Observable
class CollectionFormViewModel {
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let progressIndicatorRepository: ProgressIndicatorRepository
    
    var parentCollection: Collection? = nil
    var editingCollection: Collection? = nil
    var name = ""
    var description = ""
    var color: Color = .accentColor
    
    var saving = false
    
    var nameRequiredAlert = false
    var savingErrorMessage = ""
    var savingErrorAlert = false
    
    var closeConfirmation = false
    
    
    init(collectionId: Int? = nil, action: Enums.CollectionFormAction) {
        // collectionId is not passed -> new collection without parent
        // collectionId is passed + action is create -> new collection with parent collectionId
        // collectionId is passed + action is edit -> edit collection with id collectionId
        
        self.collectionsRepository = RepositoriesContainer.shared.collectionsRepository
        self.progressIndicatorRepository = RepositoriesContainer.shared.progressIndicatorRepository
        
        self.initialFlow(collectionId: collectionId, action: action)
    }
    
    init(collectionsRepository: CollectionsRepository, progressIndicatorRepository: ProgressIndicatorRepository, collectionId: Int? = nil, action: Enums.CollectionFormAction) {
        self.collectionsRepository = collectionsRepository
        self.progressIndicatorRepository = progressIndicatorRepository
        
        self.initialFlow(collectionId: collectionId, action: action)
    }
    
    fileprivate func initialFlow(collectionId: Int? = nil, action: Enums.CollectionFormAction = .create) {
        switch action {
        case .create:
            if let collectionId = collectionId {
                // new collection with parent collection
                if let collection = collectionsRepository.data.first(where: { $0.id == collectionId }) {
                    self.parentCollection = collection
                }
            }
            // else new collection without parent collection
        case .edit:
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
    }
    
    func onSave(onCompleted: @escaping (Collection) -> Void) {
        if name == "" {
            self.nameRequiredAlert = true
            return
        }
        
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
                await collectionsRepository.editCollection(collectionId: editingCollection.id, body: data) { processing in
                    self.saving = processing
                } onSuccess: { collection in
                    onCompleted(collection)
                } onError: { statusCode in
                    if let statusCode = statusCode {
                        self.savingErrorMessage = "Error \(statusCode)."
                        self.savingErrorAlert = true
                    }
                    else {
                        self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                        self.savingErrorAlert = true
                    }
                }
            }
            else {
                let data = CollectionCreationRequest(
                    name: name,
                    description: description,
                    color: color.toHex(),
                    members: [],
                    parentId: parentCollection?.id,
                    parent: nil
                )
                await collectionsRepository.createCollection(body: data) { processing in
                    self.saving = processing
                } onSuccess: { collection in
                    var newCollection = collection
                    if collection.parentID != self.parentCollection?.id {
                        newCollection.parentID = self.parentCollection?.id
                        newCollection.parent = Parent(id: self.parentCollection?.id, name: self.parentCollection?.name)
                    }
                    onCompleted(newCollection)
                } onError: { statusCode in
                    if let statusCode = statusCode {
                        self.savingErrorMessage = "Error \(statusCode)."
                        self.savingErrorAlert = true
                    }
                    else {
                        self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                        self.savingErrorAlert = true
                    }
                }
            }
        }
    }
}
