import Foundation
import SwiftUI

extension LocalizedStringKey {
    func localizedString() -> String {
        let mirror = Mirror(reflecting: self)
        let attributes = mirror.children.first { $0.label == "key" }?.value
        return attributes as? String ?? ""
    }
}
