import Foundation

extension OnboardingViewModel {
    func onConnect(finishOnboarding: @escaping () -> Void) {
        if hostingMode == .selfhosted {
            guard validateIpDomain(value: ipDomain) else {
                invalidValuesMessage = String(localized: "Invalid IP or domain.")
                invalidValuesAlert.toggle()
                return
            }
            guard validatePort(value: port) else {
                invalidValuesMessage = String(localized: "Invalid port.")
                invalidValuesAlert.toggle()
                return
            }
            guard validatePath(value: path) else {
                invalidValuesMessage = String(localized: "Invalid path.")
                invalidValuesAlert.toggle()
                return
            }
        }

        switch authMethod {
        case .userPass where username.isEmpty || password.isEmpty:
            invalidValuesMessage = String(localized: "Username and password are required.")
            invalidValuesAlert.toggle()
            return
        case .token where token.isEmpty:
            invalidValuesMessage = String(localized: "Authentication token is required.")
            invalidValuesAlert.toggle()
            return
        default:
            break
        }

        if mtlsEnabled && !isMtlsAvailable {
            resetMtls()
        }

        if mtlsEnabled {
            guard let fileData = mtlsFileData else {
                invalidValuesMessage = String(localized: "A client certificate file is required.")
                invalidValuesAlert.toggle()
                return
            }
            switch clientIdentityStore.importIdentity(pkcs12Data: fileData, password: mtlsPassword) {
            case .success(let identity):
                activeClientIdentity = identity
            case .failure(let error):
                invalidValuesMessage = error.localizedDescription
                invalidValuesAlert.toggle()
                return
            }
        } else {
            activeClientIdentity = nil
        }

        let identity = activeClientIdentity
        connecting = true
        Task {
            var thisToken = token
            if authMethod == .userPass {
                let reqBody = SessionTokenRequest(username: username, password: password, sessionName: getDeviceInfo())
                let tokenResponse = await getSessionToken(
                    baseUrl: hostingMode == .selfhosted
                        ? serverUrl(method: connectionMethod, domain: ipDomain, port: port != "" ? Int(port) : nil, path: path != "" ? path : nil)
                        : Config.linkwardenCloudUrl,
                    body: reqBody,
                    clientIdentity: identity
                )
                guard tokenResponse.successful,
                      let serverToken = tokenResponse.data?.response?.token else {
                    connecting = false
                    connectionErrorMessage = tokenResponse.statusCode == nil
                        ? String(localized: "Cannot establish a connection with the server. If you are using HTTPS, check that your client certificate is valid.")
                        : String(localized: "Authentication error. Invalid username or password.")
                    connectionErrorAlert.toggle()
                    return
                }
                thisToken = serverToken
            }

            let instance = hostingMode == .selfhosted
                ? ApiClient(
                    instance: ServerApiInstance(
                        url: serverUrl(method: connectionMethod, domain: ipDomain, port: port != "" ? Int(port) : nil, path: path != "" ? path : nil),
                        token: thisToken,
                        isSelfHosted: true
                    ),
                    clientIdentity: identity
                )
                : ApiClient(
                    instance: ServerApiInstance(url: Config.linkwardenCloudUrl, token: thisToken, isSelfHosted: false),
                    clientIdentity: nil
                )
            let result = await instance.dashboard.fetchDashboard()
            connecting = false
            guard let statusCode = result.statusCode else {
                connectionErrorMessage = String(localized: "Cannot establish a connection with the server. If you are using HTTPS, check that your client certificate is valid.")
                connectionErrorAlert.toggle()
                return
            }

            if statusCode < 300 {
                if saveInstance(token: thisToken) {
                    apiClientRepository.initialice(instance: instance)
                    finishOnboarding()
                }
            } else if statusCode == 401 {
                connectionErrorMessage = String(localized: "Authentication error. Check your authentication token.")
                connectionErrorAlert.toggle()
            } else {
                connectionErrorMessage = "Error \(statusCode)."
                connectionErrorAlert.toggle()
            }
        }
    }

    func saveInstance(token: String? = nil) -> Bool {
        let managedContext = PersistenceController.shared.container.viewContext
        let newInstance = ServerInstance(context: managedContext)
        newInstance.id = UUID()
        newInstance.method = connectionMethod.rawValue
        newInstance.domain = ipDomain
        newInstance.port = port != "" ? port : nil
        newInstance.path = path != "" ? path : nil
        newInstance.token = token ?? self.token
        newInstance.isSelfHosted = hostingMode == .selfhosted
        newInstance.mtlsEnabled = mtlsEnabled

        do {
            try managedContext.save()
        } catch {
            print("Failed to save Core Data: \(error)")
            return false
        }

        guard mtlsEnabled, let serverId = newInstance.id, let fileData = mtlsFileData else {
            return true
        }
        switch clientIdentityStore.save(serverId: serverId, pkcs12Data: fileData, password: mtlsPassword) {
        case .success:
            return true
        case .failure:
            managedContext.delete(newInstance)
            try? managedContext.save()
            connectionErrorMessage = String(localized: "The client certificate could not be saved to the secure store.")
            connectionErrorAlert.toggle()
            return false
        }
    }
}
