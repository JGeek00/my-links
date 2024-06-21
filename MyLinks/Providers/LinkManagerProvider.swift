import Foundation
import SwiftUI

class LinkManagerProvider: ObservableObject {
    static let shared = LinkManagerProvider()
    
    @Published var processing = false
    @Published var errorAlert = false
    @Published var errorMessage = ""
    
    func deleteLink(id: Int, onComplete: @escaping (Link) -> Void) async {
        guard let instance = ApiClientProvider.shared.instance else { return }
        DispatchQueue.main.async {
            self.processing = true
        }
        let result = await instance.deleteLink(linkId: id)
        if result.successful == true {
            DispatchQueue.main.async {
                self.processing = false
                self.errorMessage = ""
                self.errorAlert = false
                if !DashboardViewModel.shared.data.isEmpty {
                    Task { await DashboardViewModel.shared.loadData() }
                    Task { await CollectionsProvider.shared.loadData() }
                    Task { await TagsProvider.shared.loadData() }
                }
                LinksViewModel.shared.removeLinkData(linkId: result.data!.response!.id!)
                onComplete(result.data!.response!)
            }
        }
        else {
            DispatchQueue.main.async {
                self.processing = false
                self.errorMessage = String(localized: "The link could not be deleted due to an error.")
                self.errorAlert = true
            }
        }
    }
    
    func pinUnpinLink(link: Link, onCompleted: @escaping (Link) -> Void) async {
        guard let instance = ApiClientProvider.shared.instance else { return }
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
                if !DashboardViewModel.shared.data.isEmpty {
                    Task { await DashboardViewModel.shared.loadData() }
                    Task { await CollectionsProvider.shared.loadData() }
                    Task { await TagsProvider.shared.loadData() }
                }
                LinksViewModel.shared.updateLinkData(link: result.data!.response!)
                onCompleted(result.data!.response!)
            }
        }
        else {
            DispatchQueue.main.async {
                self.processing = false
                if link.pinnedBy!.isEmpty {
                    self.errorMessage = String(localized: "The link could not be pinned due to an error.")
                }
                else {
                    self.errorMessage = String(localized: "The link could not be unpinned due to an error.")
                }
                self.errorAlert = true
            }
        }
    }
}
