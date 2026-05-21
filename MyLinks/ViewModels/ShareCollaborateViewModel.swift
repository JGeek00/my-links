
import Foundation
import SwiftUI
import AlertToast

@MainActor
@Observable
class ShareCollaborateViewModel {
    @ObservationIgnored private let collection: Collection
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let userRepository: UserRepository

    init(collection: Collection, apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, collectionsRepository: CollectionsRepository = RepositoriesContainer.shared.collectionsRepository, userRepository: UserRepository = RepositoriesContainer.shared.userRepository) {
        self.collection = collection
        
        self.apiClientRepository = apiClientRepository
        self.collectionsRepository = collectionsRepository
        self.userRepository = userRepository
        
        self.makeCollectionPublic = collection.isPublic ?? false
        self.members = collection.members.map { member in
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
    
    var userData: UserData? {
        userRepository.data
    }
    
    var toastPresenting = false
    var toast: AlertToast? = nil
    
    var makeCollectionPublic: Bool = false
    var publicUrl: String {
        (self.apiClientRepository.instance?.getInstanceUrl() ?? "") + "/public/collections/\(self.collection.id)"
    }
    
    var members: [CollectionCreationMember] = []
    var currentUserText = ""
    var applyMembersToSubcollections = false
    
    var saving: Bool = false
    var savingErrorMessage = ""
    var savingErrorAlert = false
    var addingMember: Bool = false

    func copyPublicUrlClipboard() {
        UIPasteboard.general.string = publicUrl
        toast = AlertToast(type: .systemImage("doc.on.doc", .foreground.opacity(0.7)), title: String(localized: "Copied to clipboard"), style: .style(titleColor: .foreground.opacity(0.7)))
        toastPresenting = true
    }
    
    func addMember() {
        guard !addingMember else { return }
        guard let instance = apiClientRepository.instance else { return }

        addingMember = true
        let username = currentUserText.trimmingCharacters(in: .whitespaces).lowercased()

        Task {
            let result = await instance.users.fetchPublicUser(username: username)
            switch result.data?.response {
            case .string, .none:
                toast = AlertToast(type: .systemImage("person.slash.fill", .foreground.opacity(0.7)), title: String(localized: "User not found"), style: .style(titleColor: .foreground.opacity(0.7)))
                toastPresenting = true
            case .user(let user):
                let member = CollectionCreationMember(
                    userID: user.id,
                    collectionID: collection.id,
                    canCreate: false,
                    canUpdate: false,
                    canDelete: false,
                    user: CollectionCreationMemberUser(id: user.id, username: user.username, name: user.name)
                )
                self.members.append(member)
                self.currentUserText = ""
            }
            
            self.addingMember = false
        }
    }
    
    func updateMemberPermission(userId: Int, role: Enums.MemberRole) {
        let (canCreate, canUpdate, canDelete) = fromRoleToPermissions(role: role)
        members = members.map({ member in
            if member.userID == userId {
                var newMember = member
                newMember.canCreate = canCreate
                newMember.canUpdate = canUpdate
                newMember.canDelete = canDelete
                return newMember
            }
            return member
        })
    }
    
    func removeMember(userId: Int) {
        members = members.filter { $0.userID != userId }
    }
    
    func save(onCompleted: @escaping (Collection) -> Void) {
        let data = CollectionCreationRequest(
            id: collection.id,
            name: collection.name,
            members: members,
            isPublic: makeCollectionPublic,
            propagateToSubcollections: applyMembersToSubcollections
        )
        Task {
            await collectionsRepository.editCollection(collectionId: collection.id, body: data) { processing in
                self.saving = processing
            } onSuccess: { collection in
                onCompleted(collection)
            } onError: { statusCode in
                if let statusCode = statusCode {
                    self.savingErrorMessage = "Error \(statusCode)."
                    self.savingErrorAlert = true
                }
                else {
                    self.savingErrorMessage = String(localized: "Cannot reach the server. Check your Internet connection.")
                    self.savingErrorAlert = true
                }
            }
        }
    }
}
