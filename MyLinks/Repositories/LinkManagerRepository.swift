import Foundation
import SwiftUI

@MainActor
@Observable
class LinkManagerRepository {
    let apiClientRepository: ApiClientRepository
    
    init(apiClientRepository: ApiClientRepository) {
        self.apiClientRepository = apiClientRepository
    }
    
    var processing = false
    
    #if os(macOS)
    var linkPinnedToast = false
    #endif
    
    func createLink(link: LinkCreationRequest, onSuccess: @escaping (Link) -> Void, onError: @escaping (_ statusCode: Int?) -> Void) async {
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.links.createLink(link)
        if result.successful == true {
            onSuccess(result.data!.response!)
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            onError(result.statusCode)
        }
    }
    
    func uploadLinkFile(linkId: Int, fileUrl: URL, fileType: Enums.DownloadDocumentType, onSuccess: @escaping (FileResponse) -> Void, onError: @escaping (_ statusCode: Int?) -> Void) async {
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.links.uploadLinkFile(linkId: linkId, fileUrl: fileUrl, fileType: fileType)
        if result.successful == true {
            onSuccess(result.data!.response!)
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            onError(result.statusCode)
        }
    }
    
    func editLink(id: Int, body: LinkEditingRequest, onSuccess: @escaping (Link) -> Void, onError: @escaping (_ statusCode: Int?) -> Void) async {
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.links.editLink(linkId: id, body: body)
        if result.successful == true {
            onSuccess(result.data!.response!)
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            onError(result.statusCode)
        }
    }
    
    func deleteLink(id: Int, setProcessing: @escaping (Bool) -> Void, onSuccess: @escaping (DeletedLink) -> Void, onError: @escaping() -> Void) async {
        guard let instance = apiClientRepository.instance else { return }
        setProcessing(true)
        let result = await instance.links.deleteLink(linkId: id)
        if let response = result.data?.response {
            setProcessing(false)
            onSuccess(response)
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            onError()
            setProcessing(false)
        }
    }
    
    func pinUnpinLink(link: Link, action: Enums.PinUnpinAction, setProcessing: @escaping (Bool) -> Void, onSuccess: @escaping (Link) -> Void, onError: () -> Void) async {
        guard let instance = apiClientRepository.instance else { return }
        setProcessing(true)
        let body = LinkEditingRequest(
            id: link.id,
            url: link.url,
            name: link.name,
            description: link.description,
            tags: link.tags.map() { TagCreation(name: $0.name) },
            collection: CollectionCreation(id: link.collection.id, name: link.collection.name, ownerId: link.collection.ownerId),
            pinnedBy: action == .pin ? [PinnedByRequestEditing(id: 1)] : [],
            image: link.image,
            pdf: link.pdf
        )
        let result = await instance.links.editLink(linkId: link.id, body: body)
        if let data = result.data?.response {
            setProcessing(false)
            onSuccess(data)
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            onError()
            setProcessing(false)
        }
    }
}
