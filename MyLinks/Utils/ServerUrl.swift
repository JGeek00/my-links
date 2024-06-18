import Foundation

func serverUrl(method: Enums.ConnectionMethod, domain: String, port: Int?, path: String?) -> String {
    return "\(String(describing: method.rawValue))://\(String(describing: domain))\(port != nil ? ":\(String(describing: port!))" : "")\(path != nil ? String(describing: path!) : "")"
}
