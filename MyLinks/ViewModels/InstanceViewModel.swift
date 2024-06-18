import Foundation
import CoreData

class InstanceViewModel: ObservableObject {
    @Published var showOnboarding = false
    
    func checkInstance() {
        let fetchRequest: NSFetchRequest<Instance> = Instance.fetchRequest()
        do {
            let res = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            if res.isEmpty {
                showOnboarding = true
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
}
