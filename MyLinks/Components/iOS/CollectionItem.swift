import SwiftUI

struct CollectionItemComponent: View {
    let collection: Collection
    let onTaskCompleted: (Collection, Enums.CollectionTaskAction) -> Void
    
    init(collection: Collection, onTaskCompleted: @escaping (Collection, Enums.CollectionTaskAction) -> Void) {
        self.collection = collection
        self.onTaskCompleted = onTaskCompleted
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showDeleteAlert = false
    @State private var collectionFormSheet = false
    
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
                HStack {
                    if let dateFormatted = dateFormatted {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(dateFormatted)
                            .font(.system(size: 14))
                        Spacer()
                            .frame(width: 16)
                    }
                    if let linkCount = collection._count?.links {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(String(linkCount))
                            .font(.system(size: 14))
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
            Button("Edit", systemImage: "pencil") {
                collectionFormSheet = true
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                showDeleteAlert = true
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
