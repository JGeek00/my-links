import Foundation
import CoreData

func clearInstances() {
    do {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<ServerInstance> = ServerInstance.fetchRequest()
        let res = try context.fetch(fetchRequest)
        for item in res {
            context.delete(item)
        }
        try context.save()
    } catch {
        print("Cannot delete instances")
    }
}
