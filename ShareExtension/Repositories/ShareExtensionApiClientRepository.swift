import SwiftUI
import CoreData

@MainActor
@Observable
class ShareExtensionApiClientRepository {
    var instance: ApiClient? = nil
    var identityRecoveryRequired = false

    let clientIdentityStore: ClientIdentityStore

    init(clientIdentityStore: ClientIdentityStore = ClientIdentityStore()) {
        self.clientIdentityStore = clientIdentityStore
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
                let record = res[0]
                if record.isSelfHosted == true {
                    guard let method = record.method else {
                        return
                    }
                    guard let parsedMethod = Enums.ConnectionMethod(rawValue: method) else {
                        return
                    }
                    guard let domain = record.domain else {
                        return
                    }
                    guard let token = record.token else {
                        return
                    }
                    let port = record.port != nil ? Int(record.port!) : nil

                    if record.mtlsEnabled && !ClientIdentityStore.isMTLSAvailable {
                        identityRecoveryRequired = true
                        return
                    }

                    // Restore mTLS identity through shared Keychain access group
                    if record.mtlsEnabled {
                        let identityLoaded: Bool = {
                            guard let serverId = record.id else { return false }
                            let loadResult = clientIdentityStore.load(serverId: serverId)
                            guard case .success(let (pkcs12Data, password)) = loadResult else { return false }
                            let importResult = clientIdentityStore.importIdentity(
                                pkcs12Data: pkcs12Data,
                                password: password ?? ""
                            )
                            if case .success = importResult { return true }; return false
                        }()
                        // Don't create an incomplete client if the identity can't be restored
                        guard identityLoaded else {
                            identityRecoveryRequired = true
                            return
                        }
                    }

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

                    self.instance = ApiClient(
                        instance: ServerApiInstance(
                            url: serverUrl(method: parsedMethod, domain: domain, port: port, path: record.path),
                            token: token,
                            isSelfHosted: true
                        ),
                        clientIdentity: clientIdentity
                    )
                }
                else {
                    guard let token = record.token else {
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
