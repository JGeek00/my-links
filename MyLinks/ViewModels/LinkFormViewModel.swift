import Foundation
import SwiftUI

class LinkFormViewModel: ObservableObject {
    static let shared = LinkFormViewModel()
    
    @Published var sheetOpen = false
    
    @Published var editingId: Int? = nil
    
    @Published var url = ""
    @Published var name = ""
    @Published var collection = 0
    @Published var description = ""
    @Published var selectedTags: [String] = []
    @Published var localTags: [String] = []
    
    @Published var validationErrorAlert = false
    @Published var validationErrorMessage = ""
    
    @Published var saving = false
    @Published var savingErrorMessage = ""
    @Published var savingErrorAlert = false
    
    func onSave() {
        guard let collections = CollectionsProvider.shared.data?.response else { return }
        
        if NSPredicate(format: "SELF MATCHES %@", Regexps.url).evaluate(with: url) == false {
            self.validationErrorMessage = "The introduced URL is not valid."
            self.validationErrorAlert = true
            return
        }
        
        let col = collections.first(where: { $0.id == collection }) ?? collections[0]
        
        let body = LinkCreationRequest(
            url: url,
            name: name != "" ? name : nil,
            description: description != "" ? description : nil,
            tags: selectedTags.map() { TagCreation(name: $0) },
            collection: CollectionCreation(id: col.id, name: col.name, ownerId: col.ownerId)
        )
    
        self.saving = true
        
        guard let instance = ApiClientProvider.shared.instance else { return }
        Task {
            let result = editingId != nil ? await instance.editLink(linkId: editingId!, body: body) : await instance.createLink(body)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.saving = false
                    self.sheetOpen = false
                    Task { await TagsProvider.shared.loadData() }
                    Task { await CollectionsProvider.shared.loadData() }
                    Task { await DashboardViewModel.shared.loadData() }
                    Task { await LinksViewModel.shared.loadData() }
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
                    self.savingErrorMessage = "Error \(statusCode)."
                    self.savingErrorAlert = true
                }
            }
        }
    }
    
    func reset() {
        self.editingId = nil
        self.url = ""
        self.name = ""
        self.collection = 0
        self.description = ""
        self.selectedTags = []
        self.localTags = []
        self.validationErrorAlert = false
        self.validationErrorMessage = ""
    }
}
