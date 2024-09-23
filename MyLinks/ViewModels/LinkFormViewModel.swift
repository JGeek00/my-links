import Foundation
import SwiftUI

@MainActor
class LinkFormViewModel: ObservableObject {
    @Published var editingLink: Link? = nil
    
    @Published var url = ""
    @Published var name = ""
    @Published var collection = 0
    @Published var description = ""
    @Published var selectedTags: [String] = []
    @Published var localTags: [String] = []
    @Published var selectedFileUrl: URL? = nil
    
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
        
    func onSave(mode: Enums.LinkFormItem, onCompleted: @escaping (Link) -> Void) {
        let collections = CollectionsProvider.shared.data
        
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
        
        var body = LinkCreationRequest(
            url: url,
            name: name,
            description: description,
            tags: selectedTags.map() { TagCreation(name: $0) },
            collection: col != nil ? CollectionCreation(id: col!.id, name: col!.name, ownerId: col!.ownerId) : nil,
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
            
            body.type = mode == .url ? "url" : selectedFileUrl?.pathExtension.lowercased() == "pdf" ? "pdf" : "image"

            
            LinkManagerProvider.shared.createLink(link: body) { link in
                if mode == .file {
                    LinkManagerProvider.shared.uploadLinkFile(linkId: link.id!, fileUrl: self.selectedFileUrl!, fileType: self.selectedFileUrl!.pathExtension == "pdf" ? .pdf : .image) { _ in
                        DispatchQueue.main.async {
                            self.saving = false
                            Task { await TagsProvider.shared.loadData() }
                            Task { await CollectionsProvider.shared.loadData() }
                            Task { await DashboardViewModel.shared.loadData() }
                            Task {
                                await LinksViewModel.shared.loadData()
                                LinksViewModel.shared.scrollTopList.toggle()
                            }
                        }
                        onCompleted(link)
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
                    DispatchQueue.main.async {
                        self.saving = false
                        Task { await TagsProvider.shared.loadData() }
                        Task { await CollectionsProvider.shared.loadData() }
                        Task { await DashboardViewModel.shared.loadData() }
                        Task {
                            await LinksViewModel.shared.loadData()
                            LinksViewModel.shared.scrollTopList.toggle()
                        }
                    }
                    onCompleted(link)
                }
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
    
    func setSelectedFileUrl(fileUrl: URL) {
        self.selectedFileUrl = fileUrl
    }
}
