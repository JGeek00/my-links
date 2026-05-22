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
            HStack {
                if let dateFormatted = dateFormatted {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(dateFormatted)
                        .font(.system(size: 14))
                    Spacer()
                }
                if let linkCount = collection._count?.links {
                    Spacer()
                    Image(systemName: "link")
                        .font(.system(size: 12))
                    Text(String(linkCount))
                        .font(.system(size: 14))
                }
            }
            .foregroundStyle(Color.gray)
        }
        .contentShape(Rectangle())
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .cornerRadius(12)
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
                    showDeleteAlert.toggle()
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
