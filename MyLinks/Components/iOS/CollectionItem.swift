import SwiftUI

struct CollectionItemComponent: View {
    let collection: Collection
    let allowSharingOptions: Bool
    let onTaskCompleted: (Collection, Enums.CollectionTaskAction) -> Void
    
    init(collection: Collection, allowSharingOptions: Bool, onTaskCompleted: @escaping (Collection, Enums.CollectionTaskAction) -> Void) {
        self.collection = collection
        self.allowSharingOptions = allowSharingOptions
        self.onTaskCompleted = onTaskCompleted
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showDeleteAlert = false
    @State private var collectionFormSheet = false
    @State private var shareCollaborateSheet = false
    
    var body: some View {
        let dateFormatted = collection.createdAt != nil ? formatDate(collection.createdAt!) : nil
        NavigationLink {
            LinksFilteredView(linksFilteredRequest: LinksFilteredRequest(name: collection.name, mode: .collection, id: collection.id))
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    if let color = collection.color {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .fill(Color.init(hex: color))
                            .frame(width: 12, height: 12)
                        Spacer()
                            .frame(width: 6)
                    }
                    Text(collection.name)
                        .lineLimit(1)
                        .fontWeight(.medium)
                    Spacer()
                }
                if let description = collection.description {
                    if description != "" {
                        Spacer()
                            .frame(height: 6)
                        Text(description)
                            .font(.system(size: 14))
                    }
                }
                Spacer()
                    .frame(height: 6)
                HStack(spacing: 12) {
                    if let dateFormatted = dateFormatted {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text(dateFormatted)
                                .font(.system(size: 14))
                        }
                    }
                    if let linkCount = collection._count?.links {
                        HStack(spacing: 6) {
                            Image(systemName: "link")
                                .font(.system(size: 12))
                            Text(String(linkCount))
                                .font(.system(size: 14))
                        }
                    }
                    if collection.members.isEmpty == false {
                        HStack(spacing: 6) {
                            Image(systemName: "person")
                                .font(.system(size: 12))
                            Text(verbatim: String(collection.members.count + 1)) // members + owner
                                .font(.system(size: 14))
                        }
                    }
                    if collection.isPublic == true {
                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                                .font(.system(size: 12))
                            Text("Public")
                                .font(.system(size: 14))
                        }
                    }
                    Spacer()
                }
                .foregroundStyle(Color.gray)
            }
            .contentShape(Rectangle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(horizontalSizeClass == .regular ? 16 : 2)
        .foregroundStyle(Color.foreground)
        .background(horizontalSizeClass == .regular ? Color.listItemBackground: Color.clear)
        .cornerRadius(horizontalSizeClass == .regular ? 24 : 1)
        .contextMenu {
            if allowSharingOptions == true {
                Section {
                    Button("Share and collaborate", systemImage: "globe") {
                        shareCollaborateSheet = true
                    }
                }
            }
            Section {
                Button("Edit", systemImage: "pencil") {
                    collectionFormSheet = true
                }
                Button("Delete", systemImage: "trash", role: .destructive) {
                    showDeleteAlert = true
                }
            }
        }
        .sheet(isPresented: $collectionFormSheet, content: {
            CollectionFormView(collectionId: collection.id, action: .edit) {
                collectionFormSheet = false
            } onSuccess: { item, action in
                collectionFormSheet = false
                onTaskCompleted(item, .edit)
            }
        })
        .sheet(isPresented: $shareCollaborateSheet, content: {
            ShareCollaborateView(collection: collection) {
                shareCollaborateSheet = false
            } onSave: { item in
                shareCollaborateSheet = false
                onTaskCompleted(item, .edit)
            }
        })
        .alert("Delete collection", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert.toggle()
            }
            Button("Delete", role: .destructive) {
                onTaskCompleted(collection, .delete)
            }
        } message: {
            Text("This collection and all it's links will be deleted. This action is not reversible.")
        }
    }
}
