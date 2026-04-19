import SwiftUI
import CoreData

@MainActor
@Observable
class ShareExtensionApiClientRepository {
    var instance: ApiClient? = nil
    
    init() {
        initInstance()
    }
    
    private func initInstance() {
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
                    self.instance = ApiClient(instance: ServerApiInstance(url: serverUrl(method: parsedMethod, domain: domain, port: port, path: res[0].path), token: token, isSelfHosted: true))
                }
                else {
                    guard let token = res[0].token else {
                        return
                    }
                    self.instance = ApiClient(instance: ServerApiInstance(url: Config.linkwardenCloudUrl, token: token, isSelfHosted: false))
                }
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}
