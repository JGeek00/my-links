import SwiftUI

struct TagItemComponent: View {
    let tag: Tag
    let onDeleteTag: (Tag) -> Void
    let onEditTag: (Tag) -> Void
    
    init(tag: Tag, onDeleteTag: @escaping (Tag) -> Void, onEditTag: @escaping (Tag) -> Void) {
        self.tag = tag
        self.onDeleteTag = onDeleteTag
        self.onEditTag = onEditTag
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
    @State private var showDeleteAlert: Bool = false
    @State private var showEditForm: Bool = false
        
    var body: some View {
        let dateFormatted = formatDate(tag.createdAt)
        NavigationLink {
            LinksFilteredView(linksFilteredRequest: LinksFilteredRequest(name: tag.name, mode: .tag, id: tag.id))
        } label: {
            VStack(alignment: .leading) {
                Text(tag.name)
                    .lineLimit(1)
                    .fontWeight(.medium)
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
                    if let count = tag.count {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(String(count.links))
                            .font(.system(size: 14))
                    }
                    Spacer()
                }
                .foregroundStyle(Color.gray)
            }
            .contentShape(Rectangle())
        }
        .contextMenu {
            Button("Edit", systemImage: "pencil") {
                showEditForm = true
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                showDeleteAlert = true
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(horizontalSizeClass == .regular ? 16 : 0)
        .foregroundStyle(Color.foreground)
        .background(horizontalSizeClass == .regular ? Color.listItemBackground : Color.clear)
        .cornerRadius(horizontalSizeClass == .regular ? 24 : 0)
        .alert("Delete tag", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert = false
            }
            Button("Delete tag", role: .destructive) {
                onDeleteTag(tag)
            }
        } message: {
            Text("This tag will be deleted. This action is not reversible.")
        }
        .sheet(isPresented: $showEditForm) {
            TagFormView(tag: tag, mode: .edit) {
                showEditForm = false
            } onSuccess: {
                showEditForm = false
                onEditTag(tag)
            }
        }
    }
}
