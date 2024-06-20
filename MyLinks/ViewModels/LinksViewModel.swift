import Foundation

class LinksViewModel: ObservableObject {
    static let shared = LinksViewModel()
    
    @Published var data: [Link] = []
    @Published var loading = true
    @Published var error = false
    
    @Published var searchFieldValue = ""
    @Published var searchPresented = false
    
    @Published var loadingMore = false
    
    var searchQueryValue: String? = nil
    
    func loadData(
        cursor: Int? = nil,
        setLoading: Bool = false,
        setError: Bool = true,
        loadMore: Bool = false
    ) async {
        if setLoading == true {
            DispatchQueue.main.sync {
                self.loading = true
            }
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let dashboardResult = await instance.fetchLinks(cursor: cursor, searchQueryString: searchQueryValue, searchByName: searchQueryValue != nil ? true : nil)
        if dashboardResult.successful == true {
            DispatchQueue.main.async {
                if loadMore == true {
                    self.data = self.data + (dashboardResult.data?.response ?? [])
                }
                else {
                    self.data = dashboardResult.data?.response ?? []
                }
                self.loading = false
                self.error = false
            }
        }
        else {
            DispatchQueue.main.async {
                self.loading = false
                if setError == true {
                    self.error = true
                }
            }
        }
    }
    
    func loadMore() {
        if loadingMore == true && !data.isEmpty {
            return
        }
        self.loadingMore = true
        Task {
            await loadData(cursor: data.last!.id!, setError: false, loadMore: true)
            DispatchQueue.main.async {
                self.loadingMore = false
            }
        }
    }
    
    func search() {
        self.searchQueryValue = searchFieldValue
        Task {
            await loadData(setLoading: true)
        }
    }
    
    func clearSearch() {
        self.searchQueryValue = nil
        Task {
            await loadData(setLoading: true)
        }
    }
    
    func reload() {
        Task { await loadData() }
        Task { await DashboardViewModel.shared.loadData() }
    }
}
