import Foundation
import CoreData

class MenuBarFormViewModel: ObservableObject {
    @Published var apiClient: ApiClient? = nil
    
    @Published var loading = true
    @Published var error = false
    @Published var collections: [Collection] = []
    @Published var tags: [Tag] = []
    
    @Published var url = ""
    @Published var name = ""
    @Published var description = ""
    @Published var collection = 0
    @Published var selectedTags: [String] = []
    @Published var localTags: [String] = []
    
    @Published var validationErrorAlert = false
    @Published var validationErrorMessage = ""
    
    @Published var saving = false
    @Published var savingErrorMessage = ""
    @Published var savingErrorAlert = false
    
    @Published var linkCreated = false
    
    init() {
        if let instance = getInstance() {
            apiClient = instance
            fetchData(instance: instance)
        }
    }
    
    func fetchData(instance: ApiClient) {
        if loading == false {
            DispatchQueue.main.async {
                self.loading = true
            }
        }
        Task {
            let (collectionsResult, tagsResult) = await (instance.fetchCollections(), instance.fetchTags())
            if collectionsResult.successful == true && tagsResult.successful == true {
                DispatchQueue.main.async {
                    self.loading = false
                    self.error = false
                    self.collections = collectionsResult.data!.response!
                    self.collection = collectionsResult.data!.response!.first?.id ?? 0
                    self.tags = tagsResult.data!.response!
                }
            }
            else {
                DispatchQueue.main.async {
                    self.loading = false
                    self.error = true
                }
            }
        }
    }
    
    func getInstance() -> ApiClient? {
        let fetchRequest: NSFetchRequest<ServerInstance> = ServerInstance.fetchRequest()
        do {
            let res = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            if !res.isEmpty {
                if res[0].isSelfHosted == true {
                    guard let method = res[0].method else {
                        clearInstances()
                        return nil
                    }
                    guard let parsedMethod = Enums.ConnectionMethod(rawValue: method) else {
                        clearInstances()
                        return nil
                    }
                    guard let domain = res[0].domain else {
                        clearInstances()
                        return nil
                    }
                    guard let token = res[0].token else {
                        clearInstances()
                        return nil
                    }
                    let port = res[0].port != nil ? Int(res[0].port!) : nil
                    return ApiClient(url: serverUrl(method: parsedMethod, domain: domain, port: port, path: res[0].path), token: token)
                }
                else {
                    guard let token = res[0].token else {
                        clearInstances()
                        return nil
                    }
                    return ApiClient(url: Config.linkwardenCloudUrl, token: token)
                }
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return nil
        }
        return nil
    }
    
    func createLink() {
        guard let instance = apiClient else { return }
        
        if NSPredicate(format: "SELF MATCHES %@", Regexps.url).evaluate(with: url) == false {
            self.validationErrorMessage = "The introduced URL is not valid."
            self.validationErrorAlert = true
            return
        }
        
        let c = collections.first() { $0.id == self.collection }
        let collectionCreation = c != nil ? CollectionCreation(id: c!.id!, name: c!.name!, ownerId: c!.ownerId!) : nil
        let link = LinkCreationRequest(url: url, name: name, description: description, tags: selectedTags.map() { TagCreation(name: $0) }, collection: collectionCreation, pinnedBy: nil)
        
        Task {
            DispatchQueue.main.sync {
                self.saving = true
            }
            let result = await instance.createLink(link)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.saving = false
                    self.reset()
                    self.linkCreated = true
                }
            }
            else {
                guard let statusCode = result.statusCode else {
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
    
    func reset() {
        self.url = ""
        self.name = ""
        self.description = ""
        self.collection = collections.first?.id ?? 0
        self.selectedTags = []
        self.localTags = []
    }
}
