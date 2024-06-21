import SwiftUI

struct LinkItemComponent: View {
    var item: Link
    var onTap: () -> Void
    var onTaskCompleted: (Link, Enums.LinkTaskCompleted) -> Void
    
    init(item: Link, onTap: @escaping () -> Void, onTaskCompleted: @escaping (Link, Enums.LinkTaskCompleted) -> Void) {
        self.item = item
        self.onTap = onTap
        self.onTaskCompleted = onTaskCompleted
    }
    
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
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
                    .animation(.default, value: item.name != "" ? item.name! : item.description != "" ? item.description! : item.url!)
                if urlHost != nil {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                        Text(urlHost!)
                            .font(.system(size: 14))
                            .animation(.default, value: urlHost!)
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
                            .animation(.default, value: item.collection!.name!)
                        if dateFormatted != nil {
                            Spacer()
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text(dateFormatted!)
                                .font(.system(size: 14))
                                .animation(.default, value: dateFormatted!)
                        }
                    }
                    .foregroundStyle(Color.gray)
                }
            }
        }
        .foregroundColor(Color.foreground)
        .contextMenu {
            Section {
                if item.pinnedBy!.isEmpty {
                    Button("Pin to the dashboard", systemImage: "pin") {
                        Task {
                            await linkManagerProvider.pinUnpinLink(link: item) { item in
                                onTaskCompleted(item, .pin)
                            }
                        }
                    }
                }
                else {
                    Button("Unpin from the dashboard", systemImage: "pin.slash") {
                        Task {
                            await linkManagerProvider.pinUnpinLink(link: item) { item in
                                onTaskCompleted(item, .pin)
                            }
                        }
                    }
                }
            }
            Section {
                Button("Edit", systemImage: "pencil") {
                    linkFormViewModel.editingLink = item
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
        }
        .alert("Delete link", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert.toggle()
            }
            Button("Delete", role: .destructive) {
                Task {
                    await linkManagerProvider.deleteLink(id: item.id!) { link in
                        onTaskCompleted(link, .delete)
                    }
                }
            }
        } message: {
            Text("This link will be deleted. This action is not reversible.")
        }
    }
}
