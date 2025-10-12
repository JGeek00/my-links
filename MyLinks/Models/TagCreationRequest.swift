import Foundation

class TagCreationRequest: Codable {
    var tags: [TagCreationItem]
    
    init() {
        self.tags = []
    }
}

class TagCreationItem: Codable {
    var label: String
    
    init(label: String) {
        self.label = label
    }
}
