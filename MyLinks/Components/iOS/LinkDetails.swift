import SwiftUI
import AlertToast

struct LinkDetailsSheet: View {
    var link: Link
    var onClose: () -> Void

    init(link: Link, onClose: @escaping () -> Void) {
        self.link = link
        self.onClose = onClose
    }
    
    @State private var copiedClipboard = false
    
    func setCopiedClipboard() {
        if copiedClipboard == true {
            copiedClipboard = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                copiedClipboard = true
            }
        }
        else {
            copiedClipboard = true
        }
    }
    
    var body: some View {
        let createdAt = link.createdAt != nil && link.createdAt != "" ? stringToDate(link.createdAt!) : nil
        let updatedAt = link.updatedAt != nil && link.updatedAt != "" ? stringToDate(link.updatedAt!) : nil
        NavigationStack {
            List {
                if let url = link.url {
                    DetailsItem(icon: "link", iconColor: .green, label: "URL", value: url) {
                        setCopiedClipboard()
                    }
                }
                if let name = link.name {
                    DetailsItem(icon: "textformat.size.smaller", iconColor: .blue, label: String(localized: "Name"), value: name != "" ? name : String(localized: "No name")) {
                        setCopiedClipboard()
                    }
                }
                if let description = link.description {
                    DetailsItem(icon: "paragraph", iconColor: .orange, label: String(localized: "Description"), value: description != "" ? description : String(localized: "No description")) {
                        setCopiedClipboard()
                    }
                }
                if let collectionName = link.collection?.name {
                    DetailsItem(icon: "folder.fill", iconColor: .red, label: String(localized: "Collection"), value: collectionName) {
                        setCopiedClipboard()
                    }
                }
                if let tags = link.tags {
                    DetailsItem(icon: "tag.fill", iconColor: .gray, label: String(localized: "Tags"), value: tags.isEmpty ? String(localized: "This link has no tags") : tags.map() { $0.name! }.joined(separator: ", ")) {
                        setCopiedClipboard()
                    }
                }
                if let createdAt = createdAt {
                    DetailsItem(icon: "clock.fill", iconColor: .brown, label: String(localized: "Created at"), value: createdAt.formatted(date: .complete, time: .shortened)) {
                        setCopiedClipboard()
                    }
                }
                if let updatedAt = updatedAt {
                    DetailsItem(icon: "clock.fill", iconColor: .indigo, label: String(localized: "Updated at"), value: updatedAt.formatted(date: .complete, time: .shortened)) {
                        setCopiedClipboard()
                    }
                }
            }
            .listRowSpacing(12)
            .navigationTitle("Link details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    CloseButton {
                        onClose()
                    }
                }
            }
            .background(.listBackground)
            .toast(isPresenting: $copiedClipboard) {
                AlertToast(type: .systemImage("doc.on.clipboard", .foreground), title: String(localized: "Copied to the clipboard"))
            } onTap: {
                copiedClipboard = false
            }
        }
    }
}

fileprivate struct DetailsItem: View {
    var icon: String
    var iconColor: Color
    var label: String
    var value: String
    var showCopiedClipboard: () -> Void
    
    init(icon: String, iconColor: Color, label: String, value: String, showCopiedClipboard: @escaping () -> Void) {
        self.icon = icon
        self.iconColor = iconColor
        self.label = label
        self.value = value
        self.showCopiedClipboard = showCopiedClipboard
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 24, height: 24)
                    .background(iconColor)
                    .foregroundStyle(Color.white)
                    .cornerRadius(6)
                Spacer()
                    .frame(width: 12)
                Text(label)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
            }
            Spacer()
                .frame(height: 12)
            Text(value)
                .font(.system(size: 16))
                .onTapGesture {
                    let attributedString = NSAttributedString(string: value)
                    let plainString = attributedString.string
                    UIPasteboard.general.string = plainString
                    showCopiedClipboard()
                }
        }
    }
}
