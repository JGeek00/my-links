import Foundation
import SwiftUI

class CollectionFormViewModel: ObservableObject {
    static let shared = CollectionFormViewModel()
    
    @Published var sheetOpen = false
    
    @Published var editingId: Int? = nil
    @Published var name = ""
    @Published var description = ""
    @Published var color: Color = .accentColor
    
    @Published var saving = false
    
    @Published var nameRequiredAlert = false
    @Published var savingErrorMessage = ""
    @Published var savingErrorAlert = false
    
    func onSave() {
        if name == "" {
            self.nameRequiredAlert = true
            return
        }
        
        let data = CollectionCreationRequest(
            name: name,
            description: description,
            color: color.toHex(),
            members: []
        )
        
        guard let instance = ApiClientProvider.shared.instance else { return }
        self.saving = true
        Task {
            let result = editingId != nil ? await instance.editCollection(collectionId: editingId!, body: data) : await instance.createCollection(data)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.saving = false
                    self.sheetOpen = false
                    Task { await CollectionsProvider.shared.loadData() }
                }
            }
            else {
                guard let statusCode = result.statusCode else {
                    DispatchQueue.main.async {
                        self.saving = false
                        self.savingErrorMessage = LocalizedStringKey("Cannot reach the server. Check your Internet connection.").localizedString()
                        self.savingErrorAlert = true
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.saving = false
                    self.savingErrorMessage = LocalizedStringKey("Error \(statusCode).").localizedString()
                    self.savingErrorAlert = true
                }
            }
        }
    }
    
    func reset() {
        self.sheetOpen = false
        self.name = ""
        self.description = ""
        self.color = .accentColor
        self.saving = false
        self.savingErrorMessage = ""
    }
}
