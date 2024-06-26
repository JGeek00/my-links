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
    
    func onSave(onCompleted: @escaping (Collection) -> Void) async {
        if name == "" {
            DispatchQueue.main.sync {
                self.nameRequiredAlert = true
            }
            return
        }
        
        let data = CollectionCreationRequest(
            name: name,
            description: description,
            color: color.toHex(),
            members: []
        )
        
        guard let instance = ApiClientProvider.shared.instance else { return }
        
        DispatchQueue.main.sync {
            self.saving = true
        }
        
        if let editingCollection = editingCollection {
            let result = await instance.editCollection(collectionId: editingCollection.id!, body: data)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.saving = false
                    CollectionsProvider.shared.updateCollectionLocal(newCollection: result.data!.response!)
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
                DispatchQueue.main.async {
                    self.saving = false
                    self.savingErrorMessage = "Error \(statusCode)."
                    self.savingErrorAlert = true
                }
            }
        }
        else {
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
                DispatchQueue.main.async {
                    self.saving = false
                    self.savingErrorMessage = "Error \(statusCode)."
                    self.savingErrorAlert = true
                }
            }
        }
    }
}
