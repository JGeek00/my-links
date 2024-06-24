import SwiftUI

struct CollectionItemComponent: View {
    let collection: Collection
    let onTap: () -> Void
    let onDelete: () -> Void
    
    init(collection: Collection, onTap: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.collection = collection
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    @State private var showDeleteAlert = false
    
    var body: some View {
        let dateFormatted = collection.createdAt != nil ? formatDate(collection.createdAt!) : nil
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    if collection.color != nil {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .fill(Color.init(hex: collection.color!))
                            .frame(width: 12, height: 12)
                        Spacer()
                            .frame(width: 6)
                    }
                    Text(collection.name!)
                        .lineLimit(1)
                        .fontWeight(.medium)
                        .animation(.default, value: collection.name!)
                }
                if collection.description != "" {
                    Spacer()
                        .frame(height: 6)
                    Text(collection.description!)
                        .font(.system(size: 14))
                        .animation(.default, value: collection.description!)
                }
                Spacer()
                    .frame(height: 6)
                HStack {
                    if dateFormatted != nil {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(dateFormatted!)
                            .font(.system(size: 14))
                            .animation(.default, value: dateFormatted!)
                        Spacer()
                    }
                    if collection._count?.links != nil {
                        Spacer()
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(String(collection._count!.links!))
                            .font(.system(size: 14))
                            .animation(.default, value: collection._count!.links!)
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
                collectionFormViewModel.editingId = collection.id!
                collectionFormViewModel.name = collection.name!
                collectionFormViewModel.description = collection.description ?? ""
                collectionFormViewModel.color = collection.color != nil ? Color.init(hex: collection.color!) : Color.accentColor
                collectionFormViewModel.sheetOpen = true
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                showDeleteAlert.toggle()
            }
        }
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
