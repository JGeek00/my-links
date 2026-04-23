import Foundation
import SwiftUI

@MainActor
@Observable
class TagManagerRepository {
    let apiClientRepository: ApiClientRepository
    
    init(apiClientRepository: ApiClientRepository) {
        self.apiClientRepository = apiClientRepository
    }
    
    var processing = false
    
    #if os(macOS)
    var linkPinnedToast = false
    #endif
    
    func createTag(name: String, setProcessing: ((Bool) -> Void)? = nil, onSuccess: ((Tag) -> Void)? = nil, onError: ((_ statusCode: Int?) -> Void)? = nil) async {
        guard let instance = apiClientRepository.instance else { return }
        let body = TagCreationRequest()
        body.tags.append(TagCreationItem(label: name))
        setProcessing?(true)
        let result = await instance.tags.createTag(body)
        setProcessing?(false)
        if let data = result.data?.response.first {
            onSuccess?(data)
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            onError?(result.statusCode)
        }
    }
    
    func editTag(id: Int, body: Tag, setProcessing: ((Bool) -> Void)? = nil, onSuccess: ((Tag) -> Void)? = nil, onError: ((_ statusCode: Int?) -> Void)? = nil) async {
        guard let instance = apiClientRepository.instance else { return }
        setProcessing?(true)
        let result = await instance.tags.editTag(tagId: id, body: body)
        setProcessing?(false)
        if let data = result.data?.response {
            onSuccess?(data)
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            onError?(result.statusCode)
        }
    }
    
    func deleteTag(id: Int, setProcessing: ((Bool) -> Void)? = nil, onSuccess: ((Tag) -> Void)? = nil, onError: (() -> Void)? = nil) async {
        guard let instance = apiClientRepository.instance else { return }
        setProcessing?(true)
        let result = await instance.tags.deleteTag(tagId: id)
        setProcessing?(false)
        if let response = result.data?.response {
            onSuccess?(response)
        }
        else {
            if result.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            onError?()
        }
    }
}
