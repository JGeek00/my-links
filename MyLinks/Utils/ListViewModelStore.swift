import Foundation

/// Shared list view models keyed by request identity, so recreated destinations
/// reuse loaded data instead of refetching. Explicit reloads still hit the
/// network; only the layout-driven `.task` re-run is served from cache.
@MainActor
final class ListViewModelStore {
    static let shared = ListViewModelStore()

    private let maxFilteredEntries = 20
    private let maxQueryEntries = 10

    private var filtered: [String: LinksFilteredViewModel] = [:]
    private var filteredOrder: [String] = []
    private var links: [String: LinksViewModel] = [:]
    private var linksOrder: [String] = []
    private var tags: [String: TagsViewModel] = [:]
    private var tagsOrder: [String] = []

    // MARK: - Filtered (collection / tag / recent / pinned)

    /// `input` is refreshed so a renamed request shows the current title.
    func filteredViewModel(for request: LinksFilteredRequest) -> LinksFilteredViewModel {
        let key = Self.filteredKey(mode: request.mode, id: request.id)
        if let existing = filtered[key] {
            existing.input = request
            touch(key: key, in: &filteredOrder)
            return existing
        }
        let created = LinksFilteredViewModel(input: request)
        filtered[key] = created
        filteredOrder.append(key)
        evictIfNeeded(order: &filteredOrder, from: &filtered, keeping: maxFilteredEntries)
        return created
    }

    // MARK: - Links / Tags (plain + search results)

    func linksViewModel(searchQuery: String? = nil) -> LinksViewModel {
        let key = searchQuery ?? ""
        if let existing = links[key] {
            touch(key: key, in: &linksOrder)
            return existing
        }
        let created = LinksViewModel(searchQuery: searchQuery)
        links[key] = created
        linksOrder.append(key)
        evictIfNeeded(order: &linksOrder, from: &links, keeping: maxQueryEntries)
        return created
    }

    func tagsViewModel(searchQuery: String? = nil) -> TagsViewModel {
        let key = searchQuery ?? ""
        if let existing = tags[key] {
            touch(key: key, in: &tagsOrder)
            return existing
        }
        let created = TagsViewModel(searchQuery: searchQuery)
        tags[key] = created
        tagsOrder.append(key)
        evictIfNeeded(order: &tagsOrder, from: &tags, keeping: maxQueryEntries)
        return created
    }

    // MARK: - Helpers

    static func filteredKey(mode: Enums.LinksFilteredMode, id: Int?) -> String {
        "filtered#\(mode.rawValue)#\(id ?? -1)"
    }

    private func touch(key: String, in order: inout [String]) {
        order.removeAll { $0 == key }
        order.append(key)
    }

    private func evictIfNeeded<V>(order: inout [String], from dict: inout [String: V], keeping max: Int) {
        while order.count > max, let oldest = order.first {
            order.removeFirst()
            dict.removeValue(forKey: oldest)
        }
    }
}
