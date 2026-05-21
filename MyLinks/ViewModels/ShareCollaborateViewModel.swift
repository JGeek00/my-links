
import Foundation
import SwiftUI

@MainActor
@Observable
class ShareCollaborateViewModel {
    @ObservationIgnored private let collection: Collection
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let toastRepository: ToastRepository

    init(collection: Collection, apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, collectionsRepository: CollectionsRepository = RepositoriesContainer.shared.collectionsRepository, toastRepository: ToastRepository = RepositoriesContainer.shared.toastRepository) {
        self.collection = collection
        
        self.apiClientRepository = apiClientRepository
        self.collectionsRepository = collectionsRepository
        self.toastRepository = toastRepository
        
        self.makeCollectionPublic = collection.isPublic ?? false
    }
    
    var makeCollectionPublic: Bool = false
    var publicUrl: String {
        (self.apiClientRepository.instance?.getInstanceUrl() ?? "") + "/public/collections/\(self.collection.id)"
    }
    
    var saving: Bool = false
    var savingErrorMessage = ""
    var savingErrorAlert = false
    
    func copyPublicUrlClipboard() {
        UIPasteboard.general.string = publicUrl
        toastRepository.showToast(icon: "doc.on.doc", title: String(localized: "Copied to clipboard"))
    }
    
    func save(onCompleted: @escaping (Collection) -> Void) {
        let data = CollectionCreationRequest(
            id: collection.id,
            name: collection.name,
            members: [],
            isPublic: makeCollectionPublic,
        )
        Task {
            await collectionsRepository.editCollection(collectionId: collection.id, body: data) { processing in
                self.saving = processing
            } onSuccess: { collection in
                onCompleted(collection)
            } onError: { statusCode in
                if let statusCode = statusCode {
                    self.savingErrorMessage = "Error \(statusCode)."
                    self.savingErrorAlert = true
                }
                else {
                    self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                    self.savingErrorAlert = true
                }
            }
        }
    }
}
