import Foundation

class TagCreationRequest: Codable, @unchecked Sendable {
    var tags: [TagCreationItem]
    
    init() {
        self.tags = []
    }
}

class TagCreationItem: Codable, @unchecked Sendable {
    var label: String
    
    init(label: String) {
        self.label = label
    }
}
