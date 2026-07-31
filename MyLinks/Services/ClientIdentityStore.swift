import Foundation
import Security

// ponytail: concrete error enum over NSError mapping; add typed recovery hints if form reuse grows
enum ClientIdentityError: Error, LocalizedError {
    case unreadableFile
    case unsupportedFormat
    case missingPrivateKey
    case invalidPassword
    case missingPassword
    case expired
    case notYetValid
    case importFailed(underlying: Error)
    case keychainSaveFailed(OSStatus)
    case keychainLoadFailed(OSStatus)
    case keychainDeleteFailed(OSStatus)
    case identityNotFound

    var errorDescription: String? {
        switch self {
        case .unreadableFile: return String(localized: "The client certificate file could not be read.")
        case .unsupportedFormat: return String(localized: "The selected client certificate file is not a valid PKCS#12 identity.")
        case .missingPrivateKey: return String(localized: "The client certificate file does not contain a matching private key.")
        case .invalidPassword: return String(localized: "The client certificate password is incorrect.")
        case .missingPassword: return String(localized: "The client certificate requires a password.")
        case .expired: return String(localized: "The client certificate has expired.")
        case .notYetValid: return String(localized: "The client certificate is not yet valid.")
        case .importFailed: return String(localized: "The client certificate could not be imported.")
        case .keychainSaveFailed: return String(localized: "The client certificate could not be saved to the secure store.")
        case .keychainLoadFailed: return String(localized: "The client certificate could not be loaded from the secure store.")
        case .keychainDeleteFailed: return String(localized: "The client certificate could not be removed from the secure store.")
        case .identityNotFound: return String(localized: "The stored client certificate was not found.")
        }
    }
}

// ponytail: SecIdentity/SecCertificate are CF types; safe across threads for our usage
struct ClientIdentity: @unchecked Sendable {
    let identity: SecIdentity
    let certificates: [SecCertificate]
}

final class ClientIdentityStore {
    private static let keychainService = "com.jgeek00.MyLinks.mtls"
    private static let passwordKeychainService = "com.jgeek00.MyLinks.mtls.password"

    /// macOS 14 imports PKCS#12 identities into the default Keychain. The mTLS UI is
    /// therefore unavailable there unless a safe equivalent import path is implemented.
    static var isMTLSAvailable: Bool {
#if os(macOS)
        if #available(macOS 15.0, *) {
            return true
        }
        return false
#else
        // iOS keeps SecPKCS12Import results in process memory by default.
        return true
#endif
    }

    // MARK: - Import & validate

    func importIdentity(pkcs12Data: Data, password: String) -> Result<ClientIdentity, ClientIdentityError> {
        var options: [CFString: Any] = [
            kSecImportExportPassphrase: password
        ]
        // kSecImportToMemoryOnly is explicit on newer OS versions. iOS 17 is already memory-only;
        // macOS 14 is gated by isMTLSAvailable to avoid default-Keychain imports.
        if #available(iOS 18, macOS 15, *) {
            options[kSecImportToMemoryOnly] = true
        }

        var rawItems: CFArray?
        let status = SecPKCS12Import(pkcs12Data as CFData, options as CFDictionary, &rawItems)

        guard status == errSecSuccess, let items = rawItems as? [[CFString: Any]], let first = items.first else {
            return .failure(mapImportError(status: status, password: password))
        }

        guard let identity = first[kSecImportItemIdentity] as! SecIdentity? else {
            return .failure(.missingPrivateKey)
        }

        let chain = first[kSecImportItemCertChain] as? [SecCertificate] ?? []

        var leafCertificate: SecCertificate?
        SecIdentityCopyCertificate(identity, &leafCertificate)
        if let cert = leafCertificate {
            if let result = checkValidity(cert: cert) {
                return .failure(result)
            }
        }

        return .success(ClientIdentity(identity: identity, certificates: chain))
    }

    // MARK: - Keychain persistence

    func save(serverId: UUID, pkcs12Data: Data, password: String) -> Result<Void, ClientIdentityError> {
        let accountKey = keychainAccountKey(for: serverId)
        _ = delete(serverId: serverId) // clear stale

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: accountKey,
            kSecAttrService: Self.keychainService,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecUseDataProtectionKeychain: true,
            kSecValueData: pkcs12Data as CFData
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            return .failure(.keychainSaveFailed(status))
        }

        if !password.isEmpty {
            let passwordQuery: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: accountKey,
                kSecAttrService: Self.passwordKeychainService,
                kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                kSecUseDataProtectionKeychain: true,
                kSecValueData: password.data(using: .utf8)! as CFData
            ]
            let passwordStatus = SecItemAdd(passwordQuery as CFDictionary, nil)
            guard passwordStatus == errSecSuccess else {
                _ = delete(serverId: serverId)
                return .failure(.keychainSaveFailed(passwordStatus))
            }
        }

        return .success(())
    }

    func load(serverId: UUID) -> Result<(pkcs12Data: Data, password: String?), ClientIdentityError> {
        let accountKey = keychainAccountKey(for: serverId)

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: accountKey,
            kSecAttrService: Self.keychainService,
            kSecUseDataProtectionKeychain: true,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return .failure(status == errSecItemNotFound ? .identityNotFound : .keychainLoadFailed(status))
        }

        let passwordQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: accountKey,
            kSecAttrService: Self.passwordKeychainService,
            kSecUseDataProtectionKeychain: true,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var passwordResult: CFTypeRef?
        let passwordStatus = SecItemCopyMatching(passwordQuery as CFDictionary, &passwordResult)
        var password: String? = nil
        if passwordStatus == errSecSuccess {
            guard let passwordData = passwordResult as? Data,
                  let decodedPassword = String(data: passwordData, encoding: .utf8) else {
                return .failure(.keychainLoadFailed(passwordStatus))
            }
            password = decodedPassword
        } else if passwordStatus != errSecItemNotFound {
            return .failure(.keychainLoadFailed(passwordStatus))
        }

        return .success((data, password))
    }

    func delete(serverId: UUID) -> Result<Void, ClientIdentityError> {
        let accountKey = keychainAccountKey(for: serverId)

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: accountKey,
            kSecAttrService: Self.keychainService,
            kSecUseDataProtectionKeychain: true
        ]

        var passwordQuery = query
        passwordQuery[kSecAttrService] = Self.passwordKeychainService
        let status = SecItemDelete(query as CFDictionary)
        let passwordStatus = SecItemDelete(passwordQuery as CFDictionary)
        if (status == errSecSuccess || status == errSecItemNotFound),
           passwordStatus == errSecSuccess || passwordStatus == errSecItemNotFound {
            return .success(())
        }
        return .failure(.keychainDeleteFailed(status != errSecSuccess && status != errSecItemNotFound ? status : passwordStatus))
    }

    // MARK: - Helpers

    private func keychainAccountKey(for serverId: UUID) -> String {
        return "mtls-\(serverId.uuidString)"
    }

    private func mapImportError(status: OSStatus, password: String) -> ClientIdentityError {
        switch status {
        case errSecAuthFailed:
            return password.isEmpty ? .missingPassword : .invalidPassword
        case errSecDecode:
            return .unsupportedFormat
        default:
            return .importFailed(underlying: NSError(domain: NSOSStatusErrorDomain, code: Int(status)))
        }
    }

    private func checkValidity(cert: SecCertificate) -> ClientIdentityError? {
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        let trustStatus = SecTrustCreateWithCertificates([cert] as CFArray, policy, &trust)
        guard trustStatus == errSecSuccess, let t = trust else { return nil }

        var result: CFError?
        let valid = SecTrustEvaluateWithError(t, &result)

        if !valid, let error = result as? NSError {
            switch error.code {
            case Int(errSecCertificateExpired), -67874:
                return .expired
            case Int(errSecCertificateNotValidYet), -67875:
                return .notYetValid
            default:
                break
            }
        }
        return nil
    }
}
