import Foundation
import SwiftUI

class LinkFormViewModel: ObservableObject {
    static let shared = LinkFormViewModel()
    
    @Published var sheetOpen = false
    
    @Published var editingLink: Link? = nil
    
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
    
    // This flag is used on the LinksFilteredView to reload the data after editing
    // On LinksFilteredView there's an onChange that reloads the data when this flag value changes
    @Published var finishedEditingFlag = false
    
    func onSave() {
        let collections = CollectionsProvider.shared.data
        
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
            collection: CollectionCreation(id: col.id, name: col.name, ownerId: col.ownerId),
            pinnedBy: editingLink != nil ? editingLink!.pinnedBy!.map() { PinnedByRequest(id: $0.id!) } : []
        )
    
        self.saving = true
        
        guard let instance = ApiClientProvider.shared.instance else { return }
        Task {
            let result = editingLink != nil ? await instance.editLink(linkId: editingLink!.id!, body: body) : await instance.createLink(body)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.saving = false
                    self.sheetOpen = false
                    Task { await TagsProvider.shared.loadData() }
                    Task { await CollectionsProvider.shared.loadData() }
                    Task { await DashboardViewModel.shared.loadData() }
                    Task { await LinksViewModel.shared.loadData() }
                    self.finishedEditingFlag.toggle()
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
        self.editingLink = nil
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
