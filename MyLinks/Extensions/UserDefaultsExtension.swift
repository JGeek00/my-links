import Foundation

public extension UserDefaults {
    static let shared = UserDefaults(suiteName: Config.groupId)!
}
