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
    
    @Environment(TagsViewModel.self) private var tagsViewModel
    
    @State private var showDeleteAlert: Bool = false
    @State private var showEditForm: Bool = false
        
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
                if let count = tag.count {
                    Image(systemName: "link")
                        .font(.system(size: 12))
                    Text(String(count.links))
                        .font(.system(size: 14))
                    Spacer()
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
            Button("Edit", systemImage: "pencil") {
                showEditForm = true
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                showDeleteAlert = true
            }
        }
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
            } onSuccess: { tag in
                showEditForm = false
                onEditTag(tag)
            }
        }
    }
}
