import SwiftUI

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
        let createdAt = stringToDate(link.createdAt)
        let updatedAt = stringToDate(link.updatedAt)
        NavigationStack {
            Form {
                if let url = link.url {
                    DetailsItem(icon: "link", iconColor: .green, label: "URL", value: url) {
                        setCopiedClipboard()
                    }
                }
                DetailsItem(icon: "textformat.size.smaller", iconColor: .blue, label: String(localized: "Name"), value: link.name != "" ? link.name : String(localized: "No name")) {
                    setCopiedClipboard()
                }
                DetailsItem(icon: "paragraph", iconColor: .orange, label: String(localized: "Description"), value: link.description != "" ? link.description : String(localized: "No description")) {
                    setCopiedClipboard()
                }
                DetailsItem(icon: "folder.fill", iconColor: .red, label: String(localized: "Collection"), value: link.collection.name) {
                    setCopiedClipboard()
                }
                DetailsItem(icon: "tag.fill", iconColor: .gray, label: String(localized: "Tags"), value: link.tags.isEmpty ? String(localized: "This link has no tags") : link.tags.map() { $0.name }.joined(separator: ", ")) {
                    setCopiedClipboard()
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
            .formStyle(GroupedFormStyle())
            .navigationTitle("Link details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onClose()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
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
                    .font(.system(size: 12))
                    .frame(width: 20, height: 20)
                    .background(iconColor)
                    .foregroundStyle(Color.white)
                    .cornerRadius(6)
                Spacer()
                    .frame(width: 12)
                Text(label)
                    .font(.system(size: 16))
                    .fontWeight(.semibold)
            }
            Spacer()
                .frame(height: 12)
            Text(value)
                .font(.system(size: 12))
                .textSelection(.enabled)
        }
    }
}

