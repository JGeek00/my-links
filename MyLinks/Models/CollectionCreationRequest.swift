import Foundation

struct CollectionCreationRequest: Codable {
    let name: String
    let description: String?
    let color: String?
    let members: [String]
}
