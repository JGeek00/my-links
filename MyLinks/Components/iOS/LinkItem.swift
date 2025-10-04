import SwiftUI
import UIKit
import AlertToast

struct LinkItemComponent: View {
    var item: Link
    var onTaskCompleted: (Link, Enums.LinkTaskCompleted) -> Void
    
    init(item: Link, onTaskCompleted: @escaping (Link, Enums.LinkTaskCompleted) -> Void) {
        self.item = item
        self.onTaskCompleted = onTaskCompleted
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) var openURL
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var toastProvider: ToastProvider
    @State private var linkFormOpen = false
    @State private var showDeleteAlert = false
    @State private var showDetailsSheet = false
    @State private var websiteViewerSheet = false
    @State private var readerModeSheet = false
    @State private var pdfViewerSheet = false
    @State private var imageViewerSheet = false
    @State private var linkContentUnavailable = false
    
    @AppStorage(StorageKeys.showFavicons, store: UserDefaults.shared) private var showFavicons: Bool = true
    @AppStorage(StorageKeys.openLinkByDefault, store: UserDefaults.shared) private var openLinkByDefault: Enums.OpenLinkByDefault = .internalBrowser
    
    func openItem(readerAvailable: Bool, pdfAvailable: Bool, imageAvailable: Bool) {
        func openInternalBrowser() {
            if let url = item.url {
                openSafariView(url)
            }
            else {
                linkContentUnavailable = true
            }
        }
        
        switch item.type {
        case .url:
            switch openLinkByDefault {
            case .internalBrowser:
               openInternalBrowser()
            case .systemBrowser:
                if let url = item.url {
                    if let url = URL(string: url) {
                        openURL(url)
                    } else {
                        linkContentUnavailable = true
                    }
                }
                else {
                    linkContentUnavailable = true
                }
            case .readableMode:
                if readerAvailable == true {
                    readerModeSheet.toggle()
                }
                else {
                    openInternalBrowser()
                }
            case .pdfDocument:
                if pdfAvailable == true {
                    pdfViewerSheet = true
                }
                else {
                    openInternalBrowser()
                }
            case .imageDocument:
                if imageAvailable == true {
                    imageViewerSheet = true
                }
                else {
                    openInternalBrowser()
                }
            }
        case .image:
            imageViewerSheet = true
        case .pdf:
            pdfViewerSheet = true
        case .none:
            linkContentUnavailable = true
        }
    }
    
    var body: some View {
        let urlHost = getUrlHost(item.url)
        let dateFormatted = item.createdAt != nil ? formatDate(item.createdAt!) : nil
        let readerUrl = item.readable != nil && item.readable != "unavailable" && ApiClientProvider.shared.instance != nil ? URL(string: "\(ApiClientProvider.shared.instance!.url)/preserved/\(item.id!)?format=3") : nil
        let pdfAvailable = item.pdf != nil && item.pdf != "unavailable"
        let imageAvailable = item.image != nil && item.image != "unavailable"
        let htmlWebpageAvailable = item.monolith != nil && item.monolith != "unavailable"
        
        Button {
            openItem(readerAvailable: readerUrl != nil, pdfAvailable: pdfAvailable, imageAvailable: imageAvailable)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    if showFavicons == true, let url = item.url {
                        FaviconImage(linkUrl: url)
                        Spacer()
                            .frame(width: 8)
                    }
                    Text(item.name != "" ? item.name! : item.description != "" ? item.description! : item.url ?? "")
                        .lineLimit(1)
                        .fontWeight(.medium)
                }
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
        .padding(horizontalSizeClass == .regular ? 16 : 0)
        .foregroundColor(Color.foreground)
        .background(horizontalSizeClass == .regular ? Color.listItemBackground : Color.clear)
        .cornerRadius(horizontalSizeClass == .regular ? 24 : 0)
        .contextMenu {
            if let url = item.url {
                Section {
                    Menu("Open in...", systemImage: "square.and.arrow.up.on.square") {
                        Button("In app browser") {
                            openSafariView(url)
                        }
                        Button("System default browser") {
                            if let url = URL(string: url) {
                                openURL(url)
                            } else {
                                linkContentUnavailable = true
                            }
                        }
                    }
                }
            }
            Section {
                Button {
                    showDetailsSheet.toggle()
                } label: {
                    Label("Link details", systemImage: "info.circle")
                }
                Button {
                    UIPasteboard.general.string = item.url!
                    toastProvider.showToast(icon: "doc.on.doc", title: String(localized: "Link URL copied to the clipboard"))
                } label: {
                    Label("Copy link URL", systemImage: "doc.on.doc")
                }
                if htmlWebpageAvailable == true || readerUrl != nil || pdfAvailable == true || imageAvailable == true {
                    Menu("Preserved formats", systemImage: "doc.viewfinder") {
                        if item.monolith != nil && item.monolith != "unavailable" {
                            Button {
                                websiteViewerSheet.toggle()
                            } label: {
                                Label("Webpage", image: colorScheme == .dark ? "htmltag-white" : "htmltag-black")
                            }
                        }
                        if readerUrl != nil {
                            Button {
                                readerModeSheet.toggle()
                            } label: {
                                Label("Readable", systemImage: "textformat")
                            }
                        }
                        if pdfAvailable == true {
                            Button {
                                pdfViewerSheet.toggle()
                            } label: {
                                Label("PDF", systemImage: "doc")
                            }
                        }
                        if imageAvailable == true {
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
        .sheet(isPresented: $websiteViewerSheet, content: {
            HTMLViewer(link: item, mode: .webpage) {
                websiteViewerSheet.toggle()
            }
        })
        .sheet(isPresented: $readerModeSheet, content: {
            HTMLViewer(link: item, mode: .reader) {
                readerModeSheet.toggle()
            }
        })
        .sheet(isPresented: $pdfViewerSheet, content: {
            PDFViewerView(link: item) {
                pdfViewerSheet.toggle()
            }
            .environmentObject(PdfViewerViewModel(link: item))
        })
        .sheet(isPresented: $imageViewerSheet, content: {
            ImageViewerView(link: item) {
                imageViewerSheet.toggle()
            }
            .environmentObject(ImageViewerViewModel(link: item))
        })
        .alert("Link content unavailable", isPresented: $linkContentUnavailable) {
            Button("Close", role: .cancel) {
                linkContentUnavailable = false
            }
        }
    }
}

