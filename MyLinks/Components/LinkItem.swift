import SwiftUI

struct LinkItemComponent: View {
    var item: Link
    var onTap: () -> Void
    var onSuccessfulDeletion: () -> Void
    
    init(item: Link, onTap: @escaping () -> Void, onSuccessfulDeletion: @escaping () -> Void) {
        self.item = item
        self.onTap = onTap
        self.onSuccessfulDeletion = onSuccessfulDeletion
    }
    
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var deleteLinkProvider: DeleteLinkProvider
    @State private var showDeleteAlert = false
        
    var body: some View {
        let urlHost = getUrlHost(item.url!)
        let dateFormatted = item.createdAt != nil ? formatDate(item.createdAt!) : nil
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading) {
                Text(item.name != "" ? item.name! : item.description != "" ? item.description! : item.url!)
                    .lineLimit(1)
                    .fontWeight(.medium)
                if urlHost != nil {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                        Text(urlHost!)
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(Color.gray)
                }
                if dateFormatted != nil || (item.collection?.name != nil) {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Image(systemName: "folder")
                            .font(.system(size: 10))
                        Text(item.collection!.name!)
                            .font(.system(size: 14))
                        if dateFormatted != nil {
                            Spacer()
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text(dateFormatted!)
                                .font(.system(size: 14))
                        }
                    }
                    .foregroundStyle(Color.gray)
                }
            }
        }
        .foregroundColor(Color.foreground)
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                linkFormViewModel.editingId = item.id!
                linkFormViewModel.url = item.url!
                linkFormViewModel.name = item.name!
                linkFormViewModel.description = item.description!
                linkFormViewModel.selectedTags = item.tags!.map() { $0.name! }
                linkFormViewModel.collection = item.collection!.id!
                linkFormViewModel.sheetOpen = true
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                showDeleteAlert.toggle()
            }
        }
        .alert("Delete link", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert.toggle()
            }
            Button("Delete", role: .destructive) {
                Task {
                    let deleted = await deleteLinkProvider.deleteLink(id: item.id!)
                    if deleted == true {
                        onSuccessfulDeletion()
                    }
                }
            }
        } message: {
            Text("This link will be deleted. This action is not reversible.")
        }
    }
}
