import Foundation
import SwiftUI

class LinkManagerProvider: ObservableObject {
    static let shared = LinkManagerProvider()
    
    @Published var processing = false
    @Published var errorAlert = false
    @Published var errorMessage = ""
    
    func deleteLink(id: Int) async -> Bool {
        guard let instance = ApiClientProvider.shared.instance else { return false }
        DispatchQueue.main.async {
            self.processing = true
        }
        let result = await instance.deleteLink(linkId: id)
        if result.successful == true {
            DispatchQueue.main.async {
                self.processing = false
                self.errorMessage = ""
                self.errorAlert = false
                if DashboardViewModel.shared.data != nil {
                    Task { await DashboardViewModel.shared.loadData() }
                    Task { await LinksViewModel.shared.loadData() }
                    Task { await CollectionsProvider.shared.loadData() }
                    Task { await TagsProvider.shared.loadData() }
                }
            }
            return true
        }
        else {
            DispatchQueue.main.async {
                self.processing = false
                self.errorMessage = LocalizedStringKey("The link could not be deleted due to an error.").localizedString()
                self.errorAlert = true
            }
            return false
        }
    }
    
    func pinUnpinLink(link: Link) async -> Bool {
        guard let instance = ApiClientProvider.shared.instance else { return false }
        DispatchQueue.main.async {
            self.processing = true
        }
        let body = LinkCreationRequest(
            url: link.url!,
            name: link.name!,
            description: link.description!,
            tags: link.tags!.map() { TagCreation(name: $0.name!) },
            collection: CollectionCreation(id: link.collection!.id!, name: link.collection!.name!, ownerId: link.collection!.ownerId!),
            pinnedBy: link.pinnedBy!.isEmpty ? [PinnedByRequest(id: 1)] : []
        )
        let result = await instance.editLink(linkId: link.id!, body: body)
        if result.successful == true {
            DispatchQueue.main.async {
                self.processing = false
                self.errorMessage = ""
                self.errorAlert = false
                if DashboardViewModel.shared.data != nil {
                    Task { await DashboardViewModel.shared.loadData() }
                    Task { await LinksViewModel.shared.loadData() }
                    Task { await CollectionsProvider.shared.loadData() }
                    Task { await TagsProvider.shared.loadData() }
                }
            }
            return true
        }
        else {
            DispatchQueue.main.async {
                self.processing = false
                if link.pinnedBy!.isEmpty {
                    self.errorMessage = LocalizedStringKey("The link could not be pinned due to an error.").localizedString()
                }
                else {
                    self.errorMessage = LocalizedStringKey("The link could not be unpinned due to an error.").localizedString()
                }
                self.errorAlert = true
            }
            return false
        }
    }
}
