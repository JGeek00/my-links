import SwiftUI
import UIKit
import AlertToast

fileprivate struct FormatsAvailable {
    let pdf: Bool
    let image: Bool
    let html: Bool
    let readerUrl: URL?
}

struct LinkItemComponent: View {
    let item: Link
    let onTaskCompleted: (Link?, Int?, Enums.LinkTaskAction) -> Void
    let onPinUnpin: ((Link, Enums.PinUnpinAction) -> Void)?
    
    init(item: Link, onTaskCompleted: @escaping (Link?, Int?, Enums.LinkTaskAction) -> Void, onPinUnpin: ((Link, Enums.PinUnpinAction) -> Void)? = nil) {
        self.item = item
        self.onTaskCompleted = onTaskCompleted
        self.onPinUnpin = onPinUnpin
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) var openURL
    
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
    
    fileprivate func openItem(_ formats: FormatsAvailable) {
        func openInternalBrowser() {
            if let url = item.url {
                openSafariView(url)
            }
        }
        
        switch item.type {
        case .url:
            switch openLinkByDefault {
            case .internalBrowser:
               openInternalBrowser()
            case .systemBrowser:
                if let itemUrl = item.url, let url = URL(string: itemUrl) {
                    openURL(url)
                } else {
                    linkContentUnavailable = true
                }
            case .readableMode:
                if formats.readerUrl != nil {
                    readerModeSheet.toggle()
                }
                else {
                    openInternalBrowser()
                }
            case .pdfDocument:
                if formats.pdf == true {
                    pdfViewerSheet = true
                }
                else {
                    openInternalBrowser()
                }
            case .imageDocument:
                if formats.image == true {
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
        }
    }
    
    var body: some View {
        let urlHost = getUrlHost(item.url)
        let dateFormatted = formatDate(item.createdAt)

        let formatsAvailable = {
            let pdfAvailable = item.pdf != nil && item.pdf != "unavailable"
            let imageAvailable = item.image != nil && item.image != "unavailable"
            let htmlAvailable = item.monolith != nil && item.monolith != "unavailable"
            let readerUrl = item.readable != nil && item.readable != "unavailable" ? RepositoriesContainer.shared.apiClientRepository.instance?.files.getReaderUrl(linkId: item.id) : nil
            return FormatsAvailable(pdf: pdfAvailable, image: imageAvailable, html: htmlAvailable, readerUrl: readerUrl)
        }()
        
        Button {
            openItem(formatsAvailable)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    if let url = item.url, showFavicons == true {
                        FaviconImage(linkUrl: url)
                        Spacer()
                            .frame(width: 8)
                    }
                    Text(item.name != "" ? item.name : item.description != "" ? item.description : item.url ?? "")
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
                    }
                }
                .foregroundStyle(Color.gray)
                if dateFormatted != nil {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Image(systemName: "folder")
                            .font(.system(size: 10))
                        Text(item.collection.name)
                            .font(.system(size: 14))
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
            contextMenu(formatsAvailable)
        }
        .alert("Delete link", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {
                showDeleteAlert.toggle()
            }
            Button("Delete", role: .destructive) {
                onTaskCompleted(nil, item.id, .delete)
            }
        } message: {
            Text("This link will be deleted. This action is not reversible.")
        }
        .sheet(isPresented: $linkFormOpen, content: {
            LinkFormView(mode: item.type == .url ? .url : .file, link: item) {
                linkFormOpen = false
            } onSuccess: { resultLink, _ in
                linkFormOpen = false
                onTaskCompleted(resultLink, nil, .edit)
            }
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
    
    @ViewBuilder
    fileprivate func contextMenu(_ formats: FormatsAvailable) -> some View {
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
                UIPasteboard.general.string = item.url
                RepositoriesContainer.shared.toastRepository.showToast(icon: "doc.on.doc", title: String(localized: "Link URL copied to the clipboard"))
            } label: {
                Label("Copy link URL", systemImage: "doc.on.doc")
            }
            if formats.html == true || formats.readerUrl != nil || formats.pdf == true || formats.image == true {
                Menu("Preserved formats", systemImage: "doc.viewfinder") {
                    if item.monolith != nil && item.monolith != "unavailable" {
                        Button {
                            websiteViewerSheet.toggle()
                        } label: {
                            Label("Webpage", image: colorScheme == .dark ? "htmltag-white" : "htmltag-black")
                        }
                    }
                    if formats.readerUrl != nil {
                        Button {
                            readerModeSheet.toggle()
                        } label: {
                            Label("Readable", systemImage: "textformat")
                        }
                    }
                    if formats.pdf == true {
                        Button {
                            pdfViewerSheet.toggle()
                        } label: {
                            Label("PDF", systemImage: "doc")
                        }
                    }
                    if formats.image == true {
                        Button {
                            imageViewerSheet.toggle()
                        } label: {
                            Label("Image", systemImage: "photo")
                        }
                    }
                }
            }
        }
        if let onPinUnpin = onPinUnpin {
            Section {
                if let pinnedBy = item.pinnedBy, pinnedBy.isEmpty {
                    Button("Pin to the dashboard", systemImage: "pin") {
                        onPinUnpin(item, .pin)
                    }
                }
                else {
                    Button("Unpin from the dashboard", systemImage: "pin.slash") {
                        onPinUnpin(item, .unpin)
                    }
                }
            }
        }
        Section {
            Button("Edit", systemImage: "pencil") {
                linkFormOpen = true
            }
            Button("Delete", systemImage: "trash", role: .destructive) {
                showDeleteAlert = true
            }
        }
    }
}

