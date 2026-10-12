import Foundation

/// Whether this device is foldable. A closed Duo reports no division, so one
/// observation proves foldability forever (persisted for closed-state launches).
@MainActor
@Observable
final class FoldableDevice {
    static let shared = FoldableDevice()

    var isFoldable: Bool {
        didSet {
            UserDefaults.shared.set(isFoldable, forKey: StorageKeys.isFoldableDevice)
        }
    }

    init() {
        self.isFoldable = UserDefaults.shared.bool(forKey: StorageKeys.isFoldableDevice)
    }

    func noteFoldObserved() {
        if isFoldable == false {
            isFoldable = true
        }
    }
}
