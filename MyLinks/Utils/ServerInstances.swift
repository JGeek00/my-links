import Foundation
import CoreData

@discardableResult
func clearInstances() -> Bool {
    var keychainCleanupFailed = false
    do {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<ServerInstance> = ServerInstance.fetchRequest()
        let res = try context.fetch(fetchRequest)
        for item in res {
            // Clean up any associated Keychain identity before deleting the record
            if let instanceId = item.id {
                let store = ClientIdentityStore()
                if case .failure = store.delete(serverId: instanceId) {
                    keychainCleanupFailed = true
                    continue
                }
            }
            context.delete(item)
        }
        if keychainCleanupFailed {
            context.rollback()
            print("One or more mTLS Keychain records could not be deleted")
            return false
        }
        try context.save()
        return true
    } catch {
        print("Cannot delete instances")
        return false
    }
}
