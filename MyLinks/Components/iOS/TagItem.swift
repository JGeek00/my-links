import SwiftUI

struct TagItemComponent: View {
    let tag: Tag
    
    init(tag: Tag) {
        self.tag = tag
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
    var body: some View {
        let dateFormatted = tag.createdAt != nil ? formatDate(tag.createdAt!) : nil
        NavigationLink {
            LinksFilteredView(linksFilteredRequest: LinksFilteredRequest(name: tag.name!, mode: .tag, id: tag.id!))
        } label: {
            VStack(alignment: .leading) {
                Text(tag.name!)
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
                    if let linkCount = tag._count?.links {
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
        .padding(horizontalSizeClass == .regular ? 16 : 0)
        .foregroundStyle(Color.foreground)
        .background(horizontalSizeClass == .regular ? Color.listItemBackground : Color.clear)
        .cornerRadius(horizontalSizeClass == .regular ? 24 : 0)
    }
}
