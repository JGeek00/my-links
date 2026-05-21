import SwiftUI
import AlertToast

struct ShareCollaborateView: View {
    var collection: Collection
    var onClose: () -> Void
    var onSave: (Collection) -> Void
    
    @State private var viewModel: ShareCollaborateViewModel
    
    init(collection: Collection, onClose: @escaping () -> Void, onSave: @escaping (Collection) -> Void) {
        self.collection = collection
        self.onClose = onClose
        self.onSave = onSave
        _viewModel = State(initialValue: ShareCollaborateViewModel(collection: collection))
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Public collection") {
                    Toggle("Make collection public", isOn: $viewModel.makeCollectionPublic)
                    if viewModel.makeCollectionPublic == true {
                        HStack {
                            Text(verbatim: viewModel.publicUrl)
                                .fontDesign(.monospaced)
                            Spacer()
                            Button {
                               viewModel.copyPublicUrlClipboard()
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .accessibilityLabel("Copy public URL")
                        }
                    }
                }
                Section {
                    HStack {
                        TextField("Add members by email or username", text: $viewModel.currentUserText)
                            .textInputAutocapitalization(.never)
                        if viewModel.addingMember {
                            ProgressView()
                        } else {
                            Button {
                                viewModel.addMember()
                            } label: {
                                Image(systemName: "plus")
                            }
                            .accessibilityLabel("Add member")
                            .disabled(viewModel.currentUserText.isEmpty)
                        }
                    }
                    .disabled(viewModel.addingMember)
                } header: {
                    Text("Members")
                        .padding(.top, 24)
                }
                Section {
                    if let userData = viewModel.userData {
                        HStack {
                            userName(username: userData.username, name: userData.name)
                            Spacer()
                            Text("Owner")
                                .fontWeight(.semibold)
                        }
                    }
                    ForEach(viewModel.members, id: \.self) { member in
                        HStack {
                            userName(username: member.user.username, name: member.user.name)
                            Picker("", selection: Binding(get: {
                                return fromPermissionsToRole(canCreate: member.canCreate, canUpdate: member.canUpdate, canDelete: member.canDelete)
                            }, set: { v in
                                viewModel.updateMemberPermission(userId: member.userID, role: v)
                            })) {
                                Text("Viewer")
                                    .tag(Enums.MemberRole.viewer)
                                Text("Contributor")
                                    .tag(Enums.MemberRole.contributor)
                                Text("Admin")
                                    .tag(Enums.MemberRole.admin)
                            }
                            .accessibilityLabel("Role")
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                viewModel.removeMember(userId: member.userID)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
                Section {
                    Toggle("Apply members and roles to subcollections", isOn: $viewModel.applyMembersToSubcollections)
                }
            }
            .disabled(viewModel.saving)
            .navigationTitle("Share and collaborate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton(onClose: onClose)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.save { collection in
                            onSave(collection)
                        }
                    } label: {
                        if viewModel.saving == true {
                            ProgressView()
                        }
                        else {
                            Label("Save", systemImage: "checkmark")
                        }
                    }
                    .glassProminentButtonStyleIfAvailable()
                    .disabled(viewModel.saving)
                }
            }
            .alert("Error", isPresented: $viewModel.savingErrorAlert) {
                Button {
                    viewModel.savingErrorAlert = false
                } label: {
                    Text("Close")
                }
            } message: {
                Text(viewModel.savingErrorMessage)
            }
        }
        .interactiveDismissDisabled()
        .toast(isPresenting: $viewModel.toastPresenting, duration: 2, tapToDismiss: true) {
            viewModel.toast ?? AlertToast(type: .regular)
        }

    }
    
    @ViewBuilder
    func userName(username: String, name: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let name = name {
                Text(verbatim: name)
                    .fontWeight(.semibold)
                Text(verbatim: "@\(username)")
                    .foregroundStyle(Color.gray)
                    .fontWeight(.semibold)
                    .font(.system(size: 14))
            }
            else {
                Text(verbatim: "@\(username)")
                    .fontWeight(.semibold)
            }
        }
    }
}
