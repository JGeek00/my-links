import SwiftUI

struct TagItemComponent: View {
    let tag: TagsResponse_DataClass_Tag
    let onDeleteTag: (TagsResponse_DataClass_Tag) -> Void
    
    init(tag: TagsResponse_DataClass_Tag, onDeleteTag: @escaping (TagsResponse_DataClass_Tag) -> Void) {
        self.tag = tag
        self.onDeleteTag = onDeleteTag
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
    @State private var showDeleteAlert: Bool = false
        
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
                    Image(systemName: "link")
                        .font(.system(size: 12))
                    Text(String(tag.count.links))
                        .font(.system(size: 14))
                    Spacer()
                }
                .foregroundStyle(Color.gray)
            }
            .contentShape(Rectangle())
        }
        .contextMenu {
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
    }
}
