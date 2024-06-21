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
    @Published var finishedEditingLink: Link? = nil
        
    func onSave() {
        let collections = CollectionsProvider.shared.data
        
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
            collection: col != nil ? CollectionCreation(id: col!.id, name: col!.name, ownerId: col!.ownerId) : Config.defaultCollection,
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
                    if self.editingLink != nil {
                        LinksViewModel.shared.updateLinkData(link: result.data!.response!)
                        self.finishedEditingLink = result.data!.response!
                    }
                    else {
                        Task {
                            await LinksViewModel.shared.loadData()
                            LinksViewModel.shared.scrollTopList.toggle()
                        }
                    }
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
