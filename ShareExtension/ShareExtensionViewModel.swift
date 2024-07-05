import Foundation
import CoreData

class ShareExtensionViewModel: ObservableObject {
    @Published var apiClient: ApiClient? = nil
    
    @Published var invalidUrl = false
    
    @Published var url = ""
    @Published var name = ""
    @Published var description = ""
    @Published var collection = 0
    @Published var selectedTags: [String] = []
    
    @Published var collections: [Collection] = []
    @Published var tags: [Tag] = []
    @Published var localTags: [String] = []
    
    @Published var loading = true
    @Published var loadError = false
    
    @Published var saving = false
    @Published var saveError = false
    
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
                        self.apiClient = ApiClient(url: serverUrl(method: parsedMethod, domain: domain, port: port, path: res[0].path), token: token)
                    }
                }
                else {
                    guard let token = res[0].token else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.apiClient = ApiClient(url: Config.linkwardenCloudUrl, token: token)
                    }
                }
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func loadData() async {
        guard let instance = apiClient else { return }
        let (collectionsResult, tagsResult) = await (instance.fetchCollections(), instance.fetchTags())
        if collectionsResult.successful == true && tagsResult.successful == true {
            DispatchQueue.main.async {
                let collectionsFiltered = collectionsResult.data!.response!.filter() { $0.id != nil && $0.name != nil && $0.createdAt != nil }
                let sorted = collectionsFiltered.sorted() { $0.name! < $1.name! }
                if let first = sorted.first {
                    self.collection = first.id ?? 0
                }
                self.collections = sorted
                let tagsFiltered = tagsResult.data!.response!.filter() { $0.id != nil && $0.name != nil }
                self.tags = tagsFiltered.sorted() { $0.name! < $1.name! }
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
            pinnedBy: []
        )
        
        DispatchQueue.main.async {
            self.saving = true
        }
        
        Task {
            let result = await instance.createLink(body)
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
}
