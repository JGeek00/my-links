import SwiftUI
import AlertToast

struct LinkItemComponent: View {
    var item: Link
    var onTaskCompleted: (Link, Enums.LinkTaskCompleted) -> Void
    
    init(item: Link, onTaskCompleted: @escaping (Link, Enums.LinkTaskCompleted) -> Void) {
        self.item = item
        self.onTaskCompleted = onTaskCompleted
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @State private var linkFormOpen = false
    @State private var showDeleteAlert = false
    @State private var showDetailsSheet = false
    @State private var readerModeSheet = false
    @State private var pdfViewerSheet = false
    @State private var imageViewerSheet = false
    @State private var linkContentUnavailable = false
        
    var body: some View {
        let urlHost = getUrlHost(item.url)
        let dateFormatted = item.createdAt != nil ? formatDate(item.createdAt!) : nil
        let readerUrl = item.readable != nil && item.readable != "unavailable" && ApiClientProvider.shared.instance != nil ? URL(string: "\(ApiClientProvider.shared.instance!.url)/preserved/\(item.id!)?format=3") : nil
        Button {
            switch item.type {
            case .url:
                if let url = item.url {
                    openSafariView(url)
                } else {
                    linkContentUnavailable = true
                }
            case .image:
                imageViewerSheet = true
            case .pdf:
                pdfViewerSheet = true
            case .none:
                linkContentUnavailable = true
            }
        } label: {
            VStack(alignment: .leading) {
                Text(item.name != "" ? item.name! : item.description != "" ? item.description! : item.url ?? "")
                    .lineLimit(1)
                    .fontWeight(.medium)
                Spacer()
                    .frame(height: 4)
                HStack {
                    switch item.type {
                    case .url:
                        if let urlHost = urlHost {
                            Image(systemName: "link")
                                .font(.system(size: 10))
                            Text(urlHost)
                                .font(.system(size: 14))
                        }
                    case .pdf:
                        Image(systemName: "doc")
                            .font(.system(size: 10))
                        Text("PDF")
                            .font(.system(size: 14))
                    case .image:
                        Image(systemName: "photo")
                            .font(.system(size: 10))
                        Text("Image")
                            .font(.system(size: 14))
                    case .none:
                        Spacer().frame(width: 0, height: 0)
                    }
                }
                .foregroundStyle(Color.gray)
                if dateFormatted != nil || (item.collection?.name != nil) {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        if let name = item.collection?.name {
                            Image(systemName: "folder")
                                .font(.system(size: 10))
                            Text(name)
                                .font(.system(size: 14))
                        }
                        if let dateFormatted =  dateFormatted {
                            Spacer()
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text(dateFormatted)
                                .font(.system(size: 14))
                        }
                    }
                    .foregroundStyle(Color.gray)
                }
            }
        }
        .padding(horizontalSizeClass == .regular ? 12 : 0)
        .foregroundColor(Color.foreground)
        .background(horizontalSizeClass == .regular ? Color.listItemBackground : Color.clear)
        .cornerRadius(horizontalSizeClass == .regular ? 12 : 0)
        .contextMenu {
            Section {
                Button {
                    showDetailsSheet.toggle()
                } label: {
                    Label("Link details", systemImage: "info.circle")
                }
                if readerUrl != nil || (item.pdf != nil && item.pdf != "unavailable") || (item.image != nil && item.image != "unavailable") {
                    Menu("Preserved formats", systemImage: "doc.viewfinder") {
                        if readerUrl != nil {
                            Button {
                                readerModeSheet.toggle()
                            } label: {
                                Label("Readable", systemImage: "textformat")
                            }
                        }
                        if item.pdf != nil && item.pdf != "unavailable" {
                            Button {
                                pdfViewerSheet.toggle()
                            } label: {
                                Label("PDF", systemImage: "doc")
                            }
                        }
                        if item.image != nil && item.image != "unavailable" {
                            Button {
                                imageViewerSheet.toggle()
                            } label: {
                                Label("Image", systemImage: "photo")
                            }
                        }
                    }
                }
            }
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
                    linkFormOpen.toggle()
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
        .sheet(isPresented: $linkFormOpen, content: {
            LinkFormView(mode: item.type == .url ? .url : .file) {
                linkFormOpen = false
            } onSuccess: { resultLink, action in
                linkFormOpen = false
                onTaskCompleted(resultLink, action)
            }
            .environmentObject(LinkFormViewModel(link: item))
        })
        .sheet(isPresented: $showDetailsSheet, content: {
            LinkDetailsSheet(link: item) {
                showDetailsSheet.toggle()
            }
        })
        .sheet(isPresented: $readerModeSheet, content: {
            ReaderView(link: item) {
                readerModeSheet.toggle()
            }
        })
        .sheet(isPresented: $pdfViewerSheet, content: {
            PDFViewerView(link: item) {
                pdfViewerSheet.toggle()
            }
        })
        .sheet(isPresented: $imageViewerSheet, content: {
            ImageViewerView(link: item) {
                imageViewerSheet.toggle()
            }
        })
        .alert("Link content unavailable", isPresented: $linkContentUnavailable) {
            Button("Close", role: .cancel) {
                linkContentUnavailable = false
            }
        }
    }
}

private struct LinkDetailsSheet: View {
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
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
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

private struct DetailsItem: View {
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
