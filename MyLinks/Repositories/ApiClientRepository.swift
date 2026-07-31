import Foundation
import CoreData

@MainActor
@Observable
class ApiClientRepository {
    var instance: ApiClient? = nil

    let clientIdentityStore: ClientIdentityStore

    init(clientIdentityStore: ClientIdentityStore = ClientIdentityStore()) {
        self.clientIdentityStore = clientIdentityStore
    }

    func loadInstance(onNoInstance: @escaping () -> Void) {
        let fetchRequest: NSFetchRequest<ServerInstance> = ServerInstance.fetchRequest()
        do {
            let res = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            if res.isEmpty == true {
                onNoInstance()
            }
            else {
                let record = res[0]
                if record.isSelfHosted == true {
                    guard let method = record.method else {
                        clearInstances()
                        return
                    }
                    guard let parsedMethod = Enums.ConnectionMethod(rawValue: method) else {
                        clearInstances()
                        return
                    }
                    guard let domain = record.domain else {
                        clearInstances()
                        return
                    }
                    guard let token = record.token else {
                        clearInstances()
                        return
                    }
                    let port = record.port != nil ? Int(record.port!) : nil

                    if record.mtlsEnabled && !ClientIdentityStore.isMTLSAvailable {
                        clearInstances()
                        DispatchQueue.main.async { onNoInstance() }
                        return
                    }

                    // Restore mTLS identity
                    if record.mtlsEnabled {
                        let identityLoaded: Bool = {
                            guard let serverId = record.id else { return false }
                            let loadResult = clientIdentityStore.load(serverId: serverId)
                            switch loadResult {
                            case .success(let (pkcs12Data, password)):
                                let importResult = clientIdentityStore.importIdentity(
                                    pkcs12Data: pkcs12Data,
                                    password: password ?? ""
                                )
                                if case .success = importResult { return true }; return false
                            case .failure:
                                return false
                            }
                        }()
                        // Identity is required and couldn't be restored → route to recovery
                        guard identityLoaded else {
                            clearInstances()
                            DispatchQueue.main.async { onNoInstance() }
                            return
                        }
                    }

                    // Load identity again cleanly for the ApiClient (we already validated it above)
                    let clientIdentity: ClientIdentity? = {
                        guard record.mtlsEnabled, let serverId = record.id else { return nil }
                        let loadResult = clientIdentityStore.load(serverId: serverId)
                        guard case .success(let (pkcs12Data, password)) = loadResult else { return nil }
                        let importResult = clientIdentityStore.importIdentity(
                            pkcs12Data: pkcs12Data,
                            password: password ?? ""
                        )
                        guard case .success(let identity) = importResult else { return nil }
                        return identity
                    }()

                    let client = ApiClient(
                        instance: ServerApiInstance(
                            url: serverUrl(method: parsedMethod, domain: domain, port: port, path: record.path),
                            token: token,
                            isSelfHosted: true
                        ),
                        clientIdentity: clientIdentity
                    )
                    DispatchQueue.main.async {
                        self.initialice(instance: client)
                    }
                }
                else {
                    guard let token = record.token else {
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
