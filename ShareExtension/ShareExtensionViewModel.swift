import Foundation
import CoreData
import SwiftUI

@MainActor
@Observable
class ShareExtensionViewModel {
    var apiClient: ApiClient? = nil
    
    var invalidUrl = false
    
    var url = ""
    var name = ""
    var description = ""
    var collection = 0
    var selectedTags: [String] = []
    
    var collections: [Collection] = []
    var tags: [TagsResponse_DataClass_Tag] = []
    var localTags: [String] = []
    
    var loading = true
    var loadError = false
    
    var saving = false
    var saveError = false
    
    init(url: String) {
        self.url = url
        
        if NSPredicate(format: "SELF MATCHES %@", Regexps.url).evaluate(with: url) == false {
            DispatchQueue.main.async {
                self.invalidUrl = true
            }
            return
        }
        else {
            checkInstance()
        }
    }
    
    private func checkInstance() {
        let fetchRequest: NSFetchRequest<ServerInstance> = ServerInstance.fetchRequest()
        do {
            let res = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            if res.isEmpty == true {
                return
            }
            else {
                if res[0].isSelfHosted == true {
                    guard let method = res[0].method else {
                        return
                    }
                    guard let parsedMethod = Enums.ConnectionMethod(rawValue: method) else {
                        return
                    }
                    guard let domain = res[0].domain else {
                        return
                    }
                    guard let token = res[0].token else {
                        return
                    }
                    let port = res[0].port != nil ? Int(res[0].port!) : nil
                    DispatchQueue.main.async {
                        self.apiClient = ApiClient(instance: ServerApiInstance(url: serverUrl(method: parsedMethod, domain: domain, port: port, path: res[0].path), token: token, isSelfHosted: true))
                    }
                }
                else {
                    guard let token = res[0].token else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.apiClient = ApiClient(instance: ServerApiInstance(url: Config.linkwardenCloudUrl, token: token, isSelfHosted: false))
                    }
                }
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func loadData() async {
        guard let instance = apiClient else { return }
        let collectionsResult = await instance.collections.fetchCollections()
        if let data = collectionsResult.data?.response {
            DispatchQueue.main.async {
                let sorted = data.sorted() { $0.name < $1.name }
                if let first = sorted.first {
                    self.collection = first.id
                }
                self.collections = sorted
                self.loading = false
                self.loadError = false
            }
        }
        else {
            DispatchQueue.main.async {
                self.loadError = true
                self.loading = false
            }
        }
    }
    
    func onSave(success: @escaping () -> Void) {
        guard let instance = apiClient else { return }
        
        let col = collections.first(where: { $0.id == collection })
        
        let body = LinkCreationRequest(
            url: url,
            name: name,
            description: description,
            tags: selectedTags.map() { TagCreation(name: $0) },
            collection: col != nil ? CollectionCreation(id: col!.id, name: col!.name, ownerId: col!.ownerId) : nil,
            pinnedBy: [],
            image: nil,
            pdf: nil,
        )
        
        DispatchQueue.main.async {
            self.saving = true
        }
        
        Task {
            let result = await instance.links.createLink(body)
            if result.successful == true {
                success()
            }
            else {
                DispatchQueue.main.async {
                    self.saving = false
                    self.saveError = true
                }
            }
        }
    }
    
   func getCollectionName() -> String? {
        let col = collections.first(where: { $0.id == collection })
        return col?.name
    }
}
