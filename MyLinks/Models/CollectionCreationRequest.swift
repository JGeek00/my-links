import Foundation

struct CollectionCreationRequest: Codable {
    var id: Int? = nil
    var name: String
    var description: String? = nil
    var color: String? = nil
    var members: [CollectionCreationMember]
    var parentId: Int? = nil
    var parent: Parent? = nil
    var isPublic: Bool? = nil
    var propagateToSubcollections: Bool? = nil
}

// MARK: - CollectionMember
struct CollectionCreationMember: Codable, Hashable {
    let userID, collectionID: Int
    var canCreate: Bool
    var canUpdate: Bool
    var canDelete: Bool
    let user: CollectionCreationMemberUser

    enum CodingKeys: String, CodingKey {
        case userID = "userId"
        case collectionID = "collectionId"
        case canCreate, canUpdate, canDelete, user
    }
}

// MARK: - CollectionMemberUser
struct CollectionCreationMemberUser: Codable, Hashable {
    let id: Int
    let username: String
    let name: String?
}

extension Collection {
    func toCreationMembers() -> [CollectionCreationMember] {
        members.map { member in
            CollectionCreationMember(
                userID: member.userID,
                collectionID: member.collectionID,
                canCreate: member.canCreate,
                canUpdate: member.canUpdate,
                canDelete: member.canDelete,
                user: CollectionCreationMemberUser(
                    id: member.userID,
                    username: member.user.username,
                    name: member.user.name
                )
            )
        }
    }
}

