import SwiftUI

struct TagItemComponent: View {
    let tag: TagsResponse_DataClass_Tag
    
    init(tag: TagsResponse_DataClass_Tag) {
        self.tag = tag
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Environment(TagsViewModel.self) private var tagsViewModel
    
    @State private var showDeleteAlert: Bool = false
        
    var body: some View {
        let dateFormatted = formatDate(tag.createdAt)
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
        .padding(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .cornerRadius(12)
        .contextMenu {
            Button("Delete", systemImage: "trash", role: .destructive) {
                showDeleteAlert = true
            }
        }
        .alert("Delete tag", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert = false
            }
            Button("Delete tag", role: .destructive) {
                Task {
                    await tagsViewModel.deleteTag(tagId: tag.id)
                }
            }
        } message: {
            Text("This tag will be deleted. This action is not reversible.")
        }
    }
}
