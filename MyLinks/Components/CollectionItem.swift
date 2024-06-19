import SwiftUI

struct CollectionItemComponent: View {
    let collection: Collection
    let onTap: () -> Void
    
    init(collection: Collection, onTap: @escaping () -> Void) {
        self.collection = collection
        self.onTap = onTap
    }
    
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
    var body: some View {
        let dateFormatted = collection.createdAt != nil ? formatDate(collection.createdAt!) : nil
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    if collection.color != nil {
                        Circle()
                            .foregroundStyle(Color.init(hex: collection.color!))
                            .frame(width: 12, height: 12)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        Spacer()
                            .frame(width: 6)
                    }
                    Text(collection.name!)
                        .lineLimit(1)
                        .fontWeight(.medium)
                }
                if collection.description != "" {
                    Spacer()
                        .frame(height: 6)
                    Text(collection.description!)
                        .font(.system(size: 14))
                }
                Spacer()
                    .frame(height: 6)
                HStack {
                    if dateFormatted != nil {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(dateFormatted!)
                            .font(.system(size: 14))
                        Spacer()
                    }
                    if collection._count?.links != nil {
                        Spacer()
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(String(collection._count!.links!))
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.gray)
            }
        }
        .foregroundStyle(Color.foreground)
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                collectionFormViewModel.editingId = collection.id!
                collectionFormViewModel.name = collection.name!
                collectionFormViewModel.description = collection.description ?? ""
                collectionFormViewModel.color = collection.color != nil ? Color.init(hex: collection.color!) : Color.accentColor
                collectionFormViewModel.sheetOpen = true
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                
            }
        }
    }
}
