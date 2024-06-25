import SwiftUI

struct TagItemComponent: View {
    let tag: Tag
    let onTap: () -> Void
    
    init(tag: Tag, onTap: @escaping () -> Void) {
        self.tag = tag
        self.onTap = onTap
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
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
                    if dateFormatted != nil {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(dateFormatted!)
                            .font(.system(size: 14))
                        Spacer()
                    }
                    if tag._count?.links != nil {
                        Spacer()
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text(String(tag._count!.links!))
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
