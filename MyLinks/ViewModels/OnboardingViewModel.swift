import Foundation
import CoreData
import SwiftUI

@MainActor
@Observable
class OnboardingViewModel {
    @ObservationIgnored let apiClientRepository: ApiClientRepository
    @ObservationIgnored let clientIdentityStore: ClientIdentityStore

    init(
        apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository,
        clientIdentityStore: ClientIdentityStore = ClientIdentityStore()
    ) {
        self.apiClientRepository = apiClientRepository
        self.clientIdentityStore = clientIdentityStore
    }

    var selectedTab = 0
    var hostingMode: Enums.Hosting = .cloud {
        didSet { checkMtlsCompatibility() }
    }

    var connectionMethod = Enums.ConnectionMethod.http {
        didSet { checkMtlsCompatibility() }
    }
    var ipDomain = ""
    var port = ""
    var path = ""

    var authMethod = Enums.AuthMethod.userPass
    var username = ""
    var password = ""
    var token = ""

    var invalidValuesAlert = false
    var invalidValuesMessage = ""
    var connectionErrorAlert = false
    var connectionErrorMessage = ""
    var connecting = false

    // MARK: - mTLS state

    var mtlsEnabled = false
    var mtlsFileData: Data? = nil
    var mtlsFileName: String? = nil
    var mtlsPassword = ""
    var isMtlsAvailable: Bool { ClientIdentityStore.isMTLSAvailable }
    @ObservationIgnored var activeClientIdentity: ClientIdentity? = nil

    /// Clears mTLS fields when the switch or the connection mode becomes incompatible.
    func resetMtls() {
        mtlsEnabled = false
        clearMtlsFile()
    }

    func clearMtlsFile() {
        mtlsFileData = nil
        mtlsFileName = nil
        mtlsPassword = ""
        activeClientIdentity = nil
    }

    /// Called when hosting mode or connection method changes to an incompatible one.
    func checkMtlsCompatibility() {
        if !isMtlsAvailable || hostingMode != .selfhosted || connectionMethod != .https {
            if mtlsEnabled || mtlsFileData != nil {
                resetMtls()
            }
        }
    }

    func reset() {
        selectedTab = 0
        hostingMode = .cloud
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
        username = ""
        password = ""
        authMethod = .userPass
        resetMtls()
    }

    func validateIpDomain(value: String) -> Bool {
        let domainValid = NSPredicate(format: "SELF MATCHES %@", Regexps.domain).evaluate(with: value)
        let ipValid = NSPredicate(format: "SELF MATCHES %@", Regexps.ipAddress).evaluate(with: value)
        return domainValid || ipValid
    }

    func validatePort(value: String) -> Bool {
        guard !value.isEmpty else { return true }
        guard let parsed = Int(value) else { return false }
        return parsed <= 65535
    }

    func validatePath(value: String) -> Bool {
        guard !value.isEmpty else { return true }
        return NSPredicate(format: "SELF MATCHES %@", Regexps.path).evaluate(with: value)
    }
}
