import Foundation

struct CollectionCreationRequest: Codable {
    var id: Int? = nil
    var name: String
    var description: String? = nil
    var color: String? = nil
    var members: [String]
    var parentId: Int? = nil
    var parent: Parent? = nil
    var isPublic: Bool? = nil
}
