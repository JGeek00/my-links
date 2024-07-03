import Foundation
import SwiftUI

class CollectionFormViewModel: ObservableObject {
    @Published var editingCollection: Collection? = nil
    @Published var name = ""
    @Published var description = ""
    @Published var color: Color = .accentColor
    
    @Published var saving = false
    
    @Published var nameRequiredAlert = false
    @Published var savingErrorMessage = ""
    @Published var savingErrorAlert = false
    
    init(collection: Collection? = nil) {
        guard let collection = collection else { return }
        self.editingCollection = collection
        self.name = collection.name ?? ""
        self.description = collection.description ?? ""
        if let color = collection.color {
            self.color = Color(hex: color)
        }
    }
    
    func onSave(parentId: Int? = nil, onCompleted: @escaping (Collection) -> Void) async {
        if name == "" {
            DispatchQueue.main.sync {
                self.nameRequiredAlert = true
            }
            return
        }
        
        guard let instance = ApiClientProvider.shared.instance else { return }
        
        DispatchQueue.main.sync {
            self.saving = true
        }
        
        if let editingCollection = editingCollection {
            let data = CollectionCreationRequest(
                name: name,
                description: description,
                color: color.toHex(),
                members: [],
                parentId: editingCollection.parent?.id,
                parent: Parent(id: editingCollection.parent?.id, name: editingCollection.parent?.name)
            )
            let result = await instance.editCollection(collectionId: editingCollection.id!, body: data)
            if result.successful == true {
                DispatchQueue.main.async {
                    var new = result.data!.response!
                    new.parent = data.parent
                    new.parentID = data.parentId
                    
                    self.saving = false
                    CollectionsProvider.shared.updateCollectionLocal(newCollection: new)
                    onCompleted(new)
                }
            }
            else {
                guard let statusCode = result.statusCode else {
                    DispatchQueue.main.async {
                        self.saving = false
                        self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                        self.savingErrorAlert = true
                    }
                    return
                }
                if statusCode == 401 {
                    ApiClientProvider.shared.destroy()
                    return
                }
                DispatchQueue.main.async {
                    self.saving = false
                    self.savingErrorMessage = "Error \(statusCode)."
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
                parentId: parentId,
                parent: nil
            )
            let result = await instance.createCollection(data)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.saving = false
                    Task { await CollectionsProvider.shared.loadData() }
                    onCompleted(result.data!.response!)
                }
            }
            else {
                guard let statusCode = result.statusCode else {
                    DispatchQueue.main.async {
                        self.saving = false
                        self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                        self.savingErrorAlert = true
                    }
                    return
                }
                if statusCode == 401 {
                    ApiClientProvider.shared.destroy()
                    return
                }
                DispatchQueue.main.async {
                    self.saving = false
                    self.savingErrorMessage = "Error \(statusCode)."
                    self.savingErrorAlert = true
                }
            }
        }
    }
}
