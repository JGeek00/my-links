import Foundation

struct CollectionCreationRequest: Codable {
    var id: Int? = nil
    let name: String
    let description: String?
    let color: String?
    let members: [String]
    let parentId: Int?
    let parent: Parent?
}
