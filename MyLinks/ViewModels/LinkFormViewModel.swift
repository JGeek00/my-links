import Foundation
import SwiftUI

@MainActor
@Observable
class LinkFormViewModel {
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let linkManagerRepository: LinkManagerRepository
    
    var availableCollections: [Collection]
        
    var editingLink: Link? = nil
    
    var url = ""
    var name = ""
    var collection = 0
    var description = ""
    var selectedTags: [String] = []
    var localTags: [String] = []
    var selectedFileUrl: URL? = nil
    
    var validationErrorAlert = false
    var validationErrorMessage = ""
    
    var saving = false
    var savingErrorMessage = ""
    var savingErrorAlert = false
    
    init(collectionsRepository: CollectionsRepository = RepositoriesContainer.shared.collectionsRepository, linkManagerRepository: LinkManagerRepository = RepositoriesContainer.shared.linkManagerRepository, link: Link? = nil, defaultCollectionId: Int? = nil) {
        self.collectionsRepository = collectionsRepository
        self.linkManagerRepository = linkManagerRepository
        
        self.availableCollections = collectionsRepository.data
        
        if let defaultCollectionId = defaultCollectionId {
            collection = collectionsRepository.data.first(where: { collection in
                collection.id == defaultCollectionId
            })?.id ?? 0
        }
               
        if let link = link {
            editingLink = link
            url = link.url ?? ""
            name = link.name
            description = link.description
            collection = link.collection.id
            selectedTags = link.tags.map() { $0.name }
        }
        else if defaultCollectionId != nil {
            collection = defaultCollectionId!
        }
    }
        
    func onSave(mode: Enums.LinkFormItem, onSuccess: @escaping (Link) -> Void, onError: @escaping (Int?) -> Void) {
        let collections = collectionsRepository.data
        
        if editingLink == nil {
            switch mode {
            case .url:
                if NSPredicate(format: "SELF MATCHES %@", Regexps.url).evaluate(with: url) == false {
                    self.validationErrorMessage = String(localized: "The introduced URL is not valid.")
                    self.validationErrorAlert = true
                    return
                }
            case .file:
                if selectedFileUrl == nil {
                    self.validationErrorMessage = String(localized: "No file selected.")
                    self.validationErrorAlert = true
                    return
                }
            }
        }
        
        let col = collections.first(where: { $0.id == collection })
    
        Task {
            self.saving = true
            
            if editingLink != nil {
                var body = LinkEditingRequest(
                    url: url != "" ? url : nil,
                    name: name,
                    description: description,
                    type: mode == .url ? "url" : selectedFileUrl?.pathExtension.lowercased() == "pdf" ? "pdf" : "image",
                    tags: selectedTags.map() { TagCreation(name: $0) },
                    collection: col != nil ? CollectionCreation(id: col!.id, name: col!.name, ownerId: col!.ownerId) : nil,
                    pinnedBy: editingLink != nil ? editingLink!.pinnedBy.map() { PinnedByRequestEditing(id: $0.id) } : [],
                    image: self.editingLink?.image,
                    pdf: self.editingLink?.pdf,
                )
                
                body.id = editingLink?.id
                await linkManagerRepository.editLink(id: editingLink!.id, body: body) { link in
                    DispatchQueue.main.async {
                        self.saving = false
                    }
                    onSuccess(link)
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
                var body = LinkCreationRequest(
                    url: url != "" ? url : nil,
                    name: name,
                    description: description,
                    type: mode == .url ? "url" : selectedFileUrl?.pathExtension.lowercased() == "pdf" ? "pdf" : "image",
                    tags: selectedTags.map() { TagCreation(name: $0) },
                    collection: col != nil ? CollectionCreation(id: col!.id, name: col!.name, ownerId: col!.ownerId) : nil,
                    pinnedBy: editingLink != nil ? editingLink!.pinnedBy.map() { PinnedByRequest(id: $0.id) } : [],
                    image: self.editingLink?.image,
                    pdf: self.editingLink?.pdf,
                )
                
                if mode == .file && selectedFileUrl == nil {
                    self.validationErrorMessage = String(localized: "No file selected.")
                    self.validationErrorAlert = true
                    self.saving = false
                    return
                }
                if let file = selectedFileUrl {
                    if file.pathExtension.lowercased() != "pdf" && file.pathExtension.lowercased() != "png" && file.pathExtension.lowercased() != "jpg" && file.pathExtension.lowercased() != "jpeg" {
                        self.validationErrorMessage = String(localized: "The selected file has an unsupported format")
                        self.validationErrorAlert = true
                        self.saving = false
                        return
                    }
                }
                
                if mode == .file && body.name == "" {
                    body.name = selectedFileUrl?.lastPathComponent
                }
                
               await linkManagerRepository.createLink(link: body) { link in
                   Task {
                       if mode == .file {
                           await self.linkManagerRepository.uploadLinkFile(linkId: link.id, fileUrl: self.selectedFileUrl!, fileType: self.selectedFileUrl!.pathExtension == "pdf" ? .pdf : .image) { _ in
                               onSuccess(link)
                           } onError: { statusCode in
                               guard let _ = statusCode else {
                                   DispatchQueue.main.async {
                                       self.saving = false
                                       self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                                       self.savingErrorAlert = true
                                   }
                                   return
                               }
                               DispatchQueue.main.async {
                                   self.saving = false
                                   self.savingErrorMessage = String(localized: "The selected file could not be uploaded.")
                                   self.savingErrorAlert = true
                               }
                           }
                       }
                       else {
                           onSuccess(link)
                       }
                   }
                } onError: { statusCode in
                    onError(statusCode)
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
    
    func setSelectedFileUrl(fileUrl: URL) {
        self.selectedFileUrl = fileUrl
    }
    
    func getCollectionName() -> String? {
        let col = availableCollections.first(where: { $0.id == collection })
        return col?.name
    }
}
