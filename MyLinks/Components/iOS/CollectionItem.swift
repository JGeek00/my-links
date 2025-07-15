import SwiftUI

struct CollectionItemComponent: View {
    let collection: Collection
    let onDelete: () -> Void
    
    init(collection: Collection, onDelete: @escaping () -> Void) {
        self.collection = collection
        self.onDelete = onDelete
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var showDeleteAlert = false
    @State private var collectionFormSheet = false
    
    var body: some View {
        let dateFormatted = collection.createdAt != nil ? formatDate(collection.createdAt!) : nil
        NavigationLink {
            LinksFilteredView(navigationFlow: .library)
                .environmentObject(LinksFilteredViewModel(input: LinksFilteredRequest(name: collection.name!, mode: .collection, id: collection.id!)))
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
                    Text(collection.name!)
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
                            .frame(width: 16)
                    }
                    if let linkCount = collection._count?.links {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(String(linkCount))
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.gray)
            }
        }
        .padding(horizontalSizeClass == .regular ? 12 : 2)
        .foregroundStyle(Color.foreground)
        .background(horizontalSizeClass == .regular ? Color.listItemBackground: Color.clear)
        .cornerRadius(horizontalSizeClass == .regular ? 12 : 1)
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                collectionFormSheet = true
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                showDeleteAlert.toggle()
            }
        }
        .sheet(isPresented: $collectionFormSheet, content: {
            CollectionFormView {
                collectionFormSheet = false
            } onSuccess: { item, action in
                collectionFormSheet = false
            }
            .environmentObject(CollectionFormViewModel(collection: collection))
        })
        .alert("Delete collection", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert.toggle()
            }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This collection and all it's links will be deleted. This action is not reversible.")
        }
    }
}
