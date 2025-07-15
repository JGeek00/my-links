import Foundation
import SwiftUI

@MainActor
class CollectionsProvider: ObservableObject {
    static let shared = CollectionsProvider()
        
    @Published var data: [Collection] = []
    @Published var loading = true
    @Published var error = false
    
    @Published var deleting = false
    @Published var deleteError = false
    
    init() {}
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.fetchCollections()
        if result.successful == true {
            DispatchQueue.main.async {
                if result.data?.response != nil {
                    let filtered = result.data!.response!.filter() { $0.id != nil && $0.name != nil && $0.createdAt != nil }
                    self.data = filtered.sorted() { $0.name! < $1.name! }
                }
                else {
                    self.data = []
                }
                self.loading = false
                self.error = false
            }
        }
        else {
            if result.statusCode == 401 {
                ApiClientProvider.shared.destroy()
                return
            }
            DispatchQueue.main.async {
                self.loading = false
                self.error = true
            }
        }
    }
    
    func deleteCollection(id: Int) {
        guard let instance = ApiClientProvider.shared.instance else { return }
        self.deleting = true
        Task {
            let result = await instance.deleteCollection(collectionId: id)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.deleting = false
                    self.deleteError = false
                    Task { await self.loadData() }
                    if !LinksViewModel.shared.data.isEmpty {
                        Task {
                            await LinksViewModel.shared.loadData()
                            LinksViewModel.shared.scrollTopList.toggle()
                        }
                    }
                    if !DashboardViewModel.shared.data.isEmpty {
                        Task { await DashboardViewModel.shared.loadData() }
                    }
                }
            }
            else {
                if result.statusCode == 401 {
                    ApiClientProvider.shared.destroy()
                    return
                }
                DispatchQueue.main.async {
                    self.deleting = false
                    self.deleteError = true
                }
            }
        }
    }
    
    func updateCollectionLocal(newCollection: Collection) {
        self.data = self.data.map() { item in
            if item.id == newCollection.id {
                return newCollection
            }
            else {
                return item
            }
        }
    }
    
    func reset() {
        self.data = []
        self.loading = true
        self.error = false
        self.deleting = false
        self.deleteError = false
    }
}
