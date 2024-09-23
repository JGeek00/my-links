import Foundation
import SwiftUI

@MainActor
class DashboardViewModel: ObservableObject {
    static let shared = DashboardViewModel()
    
    @Published var data: [Link] = []
    @Published var pinnedLinks: Int? = nil
    @Published var loading = true
    @Published var error = false
    
    @Published var path = NavigationPath()
    
    init() {}
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
            self.data = []
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.fetchDashboardV2()
        if result.successful == true {
            DispatchQueue.main.async {
                self.data = result.data?.data?.links ?? []
                self.pinnedLinks = result.data?.data?.numberOfPinnedLinks
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.default) {
                        self.loading = false
                        self.error = false
                    }
                }
            }
        }
        else {
            if result.statusCode == 401 {
                ApiClientProvider.shared.destroy()
                return
            }
            else if result.statusCode != nil {
                let result2 = await instance.fetchDashboard()
                if result2.successful == true {
                    DispatchQueue.main.async {
                        self.data = result2.data?.response ?? []
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.default) {
                                self.loading = false
                                self.error = false
                            }
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        withAnimation(.default) {
                            self.loading = false
                            self.error = true
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    withAnimation(.default) {
                        self.loading = false
                        self.error = true
                    }
                }
            }
        }
    }
    
    func reload() {
        Task { await loadData() }
        Task {
            await LinksViewModel.shared.loadData()
            LinksViewModel.shared.scrollTopList.toggle()
        }
    }
    
    func reloadAll(setLoading: Bool = false) async {
        await loadData(setLoading: setLoading)
        _ = await (LinksViewModel.shared.loadData(), LinksViewModel.shared.scrollTopList.toggle(), CollectionsProvider.shared.loadData(), TagsProvider.shared.loadData())
    }
    
    func reset() {
        self.data = []
        self.loading = true
        self.error = false
        self.path = NavigationPath()
        self.pinnedLinks = nil
    }
}
