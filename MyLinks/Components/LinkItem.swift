import SwiftUI

struct LinkItemComponent: View {
    var item: Link
    var onTap: () -> Void
    var onTaskCompleted: (Link, Enums.LinkTaskCompleted) -> Void
    
    init(item: Link, onTap: @escaping () -> Void, onTaskCompleted: @escaping (Link, Enums.LinkTaskCompleted) -> Void) {
        self.item = item
        self.onTap = onTap
        self.onTaskCompleted = onTaskCompleted
    }
    
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @State private var linkFormOpen = false
    @State private var showDeleteAlert = false
    @State private var showDetailsSheet = false
    @State private var readerModeSheet = false
    @State private var pdfViewerSheet = false
    @State private var imageViewerSheet = false
        
    var body: some View {
        let urlHost = getUrlHost(item.url!)
        let dateFormatted = item.createdAt != nil ? formatDate(item.createdAt!) : nil
        let readerUrl = item.readable != nil ? URL(string: "\(ApiClientProvider.shared.instance!.url)/preserved/\(item.id!)?format=3") : nil
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading) {
                Text(item.name != "" ? item.name! : item.description != "" ? item.description! : item.url!)
                    .lineLimit(1)
                    .fontWeight(.medium)
                    .animation(.default, value: item.name != "" ? item.name! : item.description != "" ? item.description! : item.url!)
                if urlHost != nil {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                        Text(urlHost!)
                            .font(.system(size: 14))
                            .animation(.default, value: urlHost!)
                    }
                    .foregroundStyle(Color.gray)
                }
                if dateFormatted != nil || (item.collection?.name != nil) {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Image(systemName: "folder")
                            .font(.system(size: 10))
                        Text(item.collection!.name!)
                            .font(.system(size: 14))
                            .animation(.default, value: item.collection!.name!)
                        if dateFormatted != nil {
                            Spacer()
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text(dateFormatted!)
                                .font(.system(size: 14))
                                .animation(.default, value: dateFormatted!)
                        }
                    }
                    .foregroundStyle(Color.gray)
                }
            }
        }
        .foregroundColor(Color.foreground)
        .contextMenu {
            Section {
                Button {
                    showDetailsSheet.toggle()
                } label: {
                    Label("Link details", systemImage: "info.circle")
                }
                if readerUrl != nil || item.pdf != nil || item.image != nil {
                    Menu("Preserved formats", systemImage: "doc.viewfinder") {
                        if readerUrl != nil {
                            Button {
                                readerModeSheet.toggle()
                            } label: {
                                Label("Readable", systemImage: "textformat")
                            }
                        }
                        if item.pdf != nil {
                            Button {
                                pdfViewerSheet.toggle()
                            } label: {
                                Label("PDF", systemImage: "doc")
                            }
                        }
                        if item.image != nil {
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
            LinkFormView {
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
    }
}

private struct LinkDetailsSheet: View {
    var link: Link
    var onClose: () -> Void

    init(link: Link, onClose: @escaping () -> Void) {
        self.link = link
        self.onClose = onClose
    }
    
    var body: some View {
        let createdAt = link.createdAt != nil && link.createdAt != "" ? stringToDate(link.createdAt!) : nil
        let updatedAt = link.updatedAt != nil && link.updatedAt != "" ? stringToDate(link.updatedAt!) : nil
        NavigationStack {
            List {
                DetailsItem(icon: "link", iconColor: .green, label: "URL", value: Text(link.url!))
                if link.name != "" {
                    DetailsItem(icon: "textformat.size.smaller", iconColor: .blue, label: String(localized: "Name"), value: Text(link.name!))
                }
                if link.description != "" {
                    DetailsItem(icon: "paragraph", iconColor: .orange, label: String(localized: "Description"), value: Text(link.description!))
                }
                if link.collection!.name != "" {
                    DetailsItem(icon: "folder.fill", iconColor: .red, label: String(localized: "Collection"), value: Text(link.collection!.name!))
                }
                if !link.tags!.isEmpty {
                    DetailsItem(icon: "tag.fill", iconColor: .gray, label: String(localized: "Tags"), value: Text(link.tags!.map() { $0.name! }.joined(separator: ", ")))
                }
                if createdAt != nil {
                    DetailsItem(icon: "clock.fill", iconColor: .brown, label: String(localized: "Created at"), value: Text(createdAt!.formatted(date: .complete, time: .shortened)))
                }
                if updatedAt != nil {
                    DetailsItem(icon: "clock.fill", iconColor: .indigo, label: String(localized: "Updated at"), value: Text(updatedAt!.formatted(date: .complete, time: .shortened)))
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
        }
    }
}

private struct DetailsItem: View {
    var icon: String
    var iconColor: Color
    var label: String
    var value: Text
    
    init(icon: String, iconColor: Color, label: String, value: Text) {
        self.icon = icon
        self.iconColor = iconColor
        self.label = label
        self.value = value
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
            value
                .font(.system(size: 16))
                .textSelection(.enabled)
        }
    }
}
