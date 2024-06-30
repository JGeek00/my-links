import SwiftUI

struct TagItemComponent: View {
    let tag: Tag
    let onTap: () -> Void
    
    init(tag: Tag, onTap: @escaping () -> Void) {
        self.tag = tag
        self.onTap = onTap
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
    var body: some View {
        let dateFormatted = tag.createdAt != nil ? formatDate(tag.createdAt!) : nil
        Button {
            onTap()
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
                    }
                    if let linkCount = tag._count?.links {
                        Spacer()
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(String(linkCount))
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.gray)
            }
        }
        .padding(horizontalSizeClass == .regular ? 12 : 0)
        .foregroundStyle(Color.foreground)
        .background(horizontalSizeClass == .regular ? Color.listItemBackground : Color.clear)
        .cornerRadius(horizontalSizeClass == .regular ? 12 : 0)
    }
}
