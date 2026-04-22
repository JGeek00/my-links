import Foundation
import CoreData

@MainActor
@Observable
class ApiClientRepository {
    var instance: ApiClient? = nil
    
    init() {}
    
    func loadInstance(onNoInstance: @escaping () -> Void) {
        let fetchRequest: NSFetchRequest<ServerInstance> = ServerInstance.fetchRequest()
        do {
            let res = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            if res.isEmpty == true {
                onNoInstance()
            }
            else {
                if res[0].isSelfHosted == true {
                    guard let method = res[0].method else {
                        clearInstances()
                        return
                    }
                    guard let parsedMethod = Enums.ConnectionMethod(rawValue: method) else {
                        clearInstances()
                        return
                    }
                    guard let domain = res[0].domain else {
                        clearInstances()
                        return
                    }
                    guard let token = res[0].token else {
                        clearInstances()
                        return
                    }
                    let port = res[0].port != nil ? Int(res[0].port!) : nil
                    let client = ApiClient(instance: ServerApiInstance(url: serverUrl(method: parsedMethod, domain: domain, port: port, path: res[0].path), token: token, isSelfHosted: true))
                    DispatchQueue.main.async {
                        self.initialice(instance: client)
                    }
                }
                else {
                    guard let token = res[0].token else {
                        clearInstances()
                        return
                    }
                    let client = ApiClient(instance: ServerApiInstance(url: Config.linkwardenCloudUrl, token: token, isSelfHosted: false))
                    DispatchQueue.main.async {
                        self.initialice(instance: client)
                    }
                }
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func initialice(instance: ApiClient) {
        self.instance = instance
    }
    
    func destroy(sessionExpired: Bool? = nil) {
        clearInstances()
        self.instance = nil
        RepositoriesContainer.reset()
    }
}
