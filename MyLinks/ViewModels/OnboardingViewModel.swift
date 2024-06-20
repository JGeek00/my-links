import Foundation
import CoreData
import SwiftUI

class OnboardingViewModel: ObservableObject {
    static let shared = OnboardingViewModel()
    
    @Published var showOnboarding = false
    
    @Published var selectedTab = 0
    @Published var hostingMode: Enums.Hosting? = nil
    
    @Published var token = ""
    @Published var connectionMethod = Enums.ConnectionMethod.http
    @Published var ipDomain = ""
    @Published var port = ""
    @Published var path = ""
    
    @Published var invalidValuesAlert = false
    @Published var invalidValuesMessage = ""
    
    @Published var connectionErrorAlert = false
    @Published var connectionErrorMessage = ""
    
    @Published var connecting = false
    
    func checkInstance() {
        let fetchRequest: NSFetchRequest<ServerInstance> = ServerInstance.fetchRequest()
        do {
            let res = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            if res.isEmpty == true {
                showOnboarding = true
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
                    let client = ApiClient(url: serverUrl(method: parsedMethod, domain: domain, port: port, path: res[0].path), token: token)
                    DispatchQueue.main.async {
                        ApiClientProvider.shared.initialice(instance: client)
                    }
                }
                else {
                    guard let token = res[0].token else {
                        clearInstances()
                        return
                    }
                    let client = ApiClient(url: serverUrl(method: .https, domain: "linkwarden.app", port: nil, path: nil), token: token)
                    DispatchQueue.main.async {
                        ApiClientProvider.shared.initialice(instance: client)
                    }
                }
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func reset() {
        selectedTab = 0
        hostingMode = nil
        token = ""
        connectionMethod = .http
        ipDomain = ""
        port = ""
        path = ""
        invalidValuesAlert = false
        invalidValuesMessage = ""
        connectionErrorAlert = false
        connectionErrorMessage = ""
        connecting = false
    }
    
    func validateIpDomain(value: String) -> Bool {
        let domainValid = NSPredicate(format: "SELF MATCHES %@", Regexps.domain).evaluate(with: value)
        let ipValid = NSPredicate(format: "SELF MATCHES %@", Regexps.ipAddress).evaluate(with: value)
        if domainValid || ipValid {
            return true
        }
        else {
            return false
        }
    }
    
    func validatePort(value: String) -> Bool {
        if value == "" {
            return true
        }
        let parsed = Int(value)
        if parsed == nil {
            return false
        }
        if parsed! <= 65535 {
            return true
        }
        else {
            return false
        }
    }
    
    func validatePath(value: String) -> Bool {
        if value == "" {
            return true
        }
        let valid = NSPredicate(format: "SELF MATCHES %@", Regexps.path).evaluate(with: value)
        if valid {
            return true
        }
        else {
            return false
        }
    }
    
    func onConnect() {
        if hostingMode == .selfhosted {
            let validIpDomain = validateIpDomain(value: ipDomain)
            if validIpDomain == false {
                invalidValuesMessage = String(localized: "Invalid IP or domain.")
                invalidValuesAlert.toggle()
                return
            }
            
            let validPort = validatePort(value: port)
            if validPort == false {
                invalidValuesMessage = String(localized: "Invalid port.")
                invalidValuesAlert.toggle()
                return
            }
            
            let validPath = validatePath(value: path)
            if validPath == false {
                invalidValuesMessage = String(localized: "Invalid path.")
                invalidValuesAlert.toggle()
                return
            }
        }
        
        if token == "" {
            invalidValuesMessage = String(localized: "Authentication token is required.")
            invalidValuesAlert.toggle()
            return
        }
        
        self.connecting = true
        Task {
            let instance = ApiClient(url: serverUrl(method: connectionMethod, domain: ipDomain, port: port != "" ? Int(port) : nil, path: path != "" ? path : nil), token: token)
            let result = await instance.fetchDashboard()
            DispatchQueue.main.async {
                self.connecting = false
            }
            guard let statusCode = result.statusCode else {
                DispatchQueue.main.async {
                    self.connectionErrorMessage = String(localized: "Cannot establish a connection with the server. If you are using HTTPS, check if your certificate is valid.")
                    self.connectionErrorAlert.toggle()
                }
                return
            }
            if statusCode < 300 {
                // success
                let saved = self.saveInstance()
                if saved == true {
                    DispatchQueue.main.async {
                        ApiClientProvider.shared.initialice(instance: instance)
                        self.showOnboarding = false
                    }
                }
            }
            else if statusCode == 401 {
                DispatchQueue.main.async {
                    self.connectionErrorMessage = String(localized: "Authentication error. Check your authentication token.")
                    self.connectionErrorAlert.toggle()
                }
            }
            else {
                DispatchQueue.main.async {
                    self.connectionErrorMessage = "Error \(statusCode)."
                    self.connectionErrorAlert.toggle()
                }
            }
        }
    }
    
    func saveInstance() -> Bool {
        let managedContext = PersistenceController.shared.container.viewContext
        let newInstance = ServerInstance(context: managedContext)
        newInstance.id = UUID()
        newInstance.method = connectionMethod.rawValue
        newInstance.domain = ipDomain
        newInstance.port = port != "" ? port : nil
        newInstance.path = path != "" ? path : nil
        newInstance.token = token
        newInstance.isSelfHosted = hostingMode == .selfhosted
        
        do {
            try managedContext.save()
            return true
        } catch {
            print("Failed to save object: \(error)")
            return false
        }
    }
}
