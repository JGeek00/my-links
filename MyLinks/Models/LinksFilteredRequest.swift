import Foundation

struct LinksFilteredRequest: Hashable, Equatable {
    let name: String
    let mode: Enums.LinksFilteredMode
    let id: Int?
    
    init(name: String, mode: Enums.LinksFilteredMode, id: Int?) {
        self.name = name
        self.mode = mode
        self.id = id
    }
}
