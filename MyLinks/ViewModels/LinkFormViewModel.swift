import Foundation
import SwiftUI

class LinkFormViewModel: ObservableObject {    
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
    
    init(link: Link? = nil) {
        let filtered = CollectionsProvider.shared.data.filter() { $0.name != nil && $0.id != nil }
        collection = link?.collection?.id ?? filtered.first?.id ?? 0
        
        guard let link = link else { return }
        editingLink = link
        url = link.url ?? ""
        name = link.name ?? ""
        description = link.description ?? ""
        selectedTags = link.tags?.map() { $0.name! } ?? []
    }
        
    func onSave(onCompleted: @escaping (Link) -> Void) {
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
        
        if editingLink != nil {
            LinkManagerProvider.shared.editLink(id: editingLink!.id!, body: body) { link in
                DispatchQueue.main.async {
                    self.saving = false
                }
                onCompleted(link)
            } onError: { statusCode in
                guard let statusCode = statusCode else {
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
            LinkManagerProvider.shared.createLink(link: body) { link in
                DispatchQueue.main.async {
                    self.saving = false
                }
                onCompleted(link)
            } onError: { statusCode in
                guard let statusCode = statusCode else {
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
