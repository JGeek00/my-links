import Foundation

final class SSLIgnoringDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {
    let clientIdentity: ClientIdentity?

    init(clientIdentity: ClientIdentity? = nil) {
        self.clientIdentity = clientIdentity
    }

    nonisolated func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace

        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
            if let identity = self.clientIdentity {
                let credential = URLCredential(
                    identity: identity.identity,
                    certificates: identity.certificates,
                    persistence: .forSession
                )
                completionHandler(.useCredential, credential)
                return
            }
        }

        if protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let serverTrust = protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
            return
        }

        completionHandler(.performDefaultHandling, nil)
    }
}
