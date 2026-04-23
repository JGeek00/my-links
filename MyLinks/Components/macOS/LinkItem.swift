import SwiftUI
import AppKit

fileprivate struct FormatsAvailable {
    let pdf: Bool
    let image: Bool
    let html: Bool
    let reader: Bool
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
    
    @Environment(\.openURL) var openURL
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var linkFormOpen = false
    @State private var showDeleteAlert = false
    @State private var showDetailsSheet = false
    @State private var websiteViewerSheet = false
    @State private var readerModeSheet = false
    @State private var pdfViewerSheet = false
    @State private var imageViewerSheet = false
    @State private var linkContentUnavailable = false
    
    @AppStorage(StorageKeys.showFavicons, store: UserDefaults.shared) private var showFavicons: Bool = true
    
    var body: some View {
        let urlHost = getUrlHost(item.url)
        let dateFormatted = formatDate(item.createdAt)

        let formatsAvailable = {
            let pdfAvailable = item.pdf != nil && item.pdf != "unavailable"
            let imageAvailable = item.image != nil && item.image != "unavailable"
            let htmlAvailable = item.monolith != nil && item.monolith != "unavailable"
            let readerAvailable = item.readable != nil && item.readable != "unavailable"
            return FormatsAvailable(pdf: pdfAvailable, image: imageAvailable, html: htmlAvailable, reader: readerAvailable)
        }()
        
        Button {
            if let url = item.url, let convertedUrl = URL(string: url) {
                openURL(convertedUrl)
            }
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    if showFavicons == true, let url = item.url {
                        FaviconImage(linkUrl: url)
                        Spacer()
                            .frame(width: 8)
                    }
                    Text(item.name != "" ? item.name : item.description != "" ? item.description : item.url ?? "")
                        .lineLimit(1)
                        .fontWeight(.medium)
                }
                HStack(alignment: .center) {
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
                    availableFormatsButtons(formatsAvailable)
                }
                .foregroundStyle(Color.gray)
                .padding(.vertical, 4)
                Spacer()
                    .frame(height: 4)
                HStack {
                    Image(systemName: "folder")
                        .font(.system(size: 10))
                    Text(item.collection.name)
                        .font(.system(size: 14))
                    if let dateFormatted = dateFormatted {
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(dateFormatted)
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.gray)
            }
            .padding(12)
            .foregroundColor(Color.foreground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.gray.opacity(0.2), lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
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
                onTaskCompleted(resultLink, item.id, .edit)
            }
        })
        .sheet(isPresented: $showDetailsSheet, content: {
            LinkDetailsSheet(link: item) {
                showDetailsSheet.toggle()
            }
        })
        .sheet(isPresented: $pdfViewerSheet, content: {
            DocumentDownloaderView(linkId: item.id, documentType: .pdf) {
                pdfViewerSheet = false
            }
            .interactiveDismissDisabled()
        })
        .sheet(isPresented: $imageViewerSheet, content: {
            DocumentDownloaderView(linkId: item.id, documentType: .image) {
                imageViewerSheet = false
            }
            .interactiveDismissDisabled()
        })
        .sheet(isPresented: $websiteViewerSheet, content: {
            HTMLViewer(link: item, mode: .webpage) {
                websiteViewerSheet.toggle()
            }
        })
        .sheet(isPresented: $readerModeSheet, content: {
            HTMLViewer(link: item, mode: .reader) {
                readerModeSheet = false
            }
            .interactiveDismissDisabled()
            .frame(minWidth: 300, idealWidth: 800, maxWidth: 1000, minHeight: 300, idealHeight: 600, maxHeight: 1000)
        })
        .alert("Link content unavailable", isPresented: $linkContentUnavailable) {
            Button("Close", role: .cancel) {
                linkContentUnavailable = false
            }
        }
    }
    
    @ViewBuilder
    fileprivate func contextMenu(_ formatsAvailable: FormatsAvailable) -> some View {
        Section {
            Button {
                showDetailsSheet.toggle()
            } label: {
                Label("Link details", systemImage: "info.circle")
            }
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(item.url!, forType: .string)
            } label: {
                Label("Copy link URL", systemImage: "doc.on.doc")
            }

            if formatsAvailable.html == true || formatsAvailable.reader == true || formatsAvailable.pdf == true || formatsAvailable.image == true {
                Menu("Preserved formats", systemImage: "doc.viewfinder") {
                    if item.monolith != nil && item.monolith != "unavailable" {
                        Button {
                            websiteViewerSheet.toggle()
                        } label: {
                            Label("Webpage", systemImage: "globe")
                        }
                    }
                    if formatsAvailable.reader == true {
                        Button {
                            readerModeSheet.toggle()
                        } label: {
                            Label("Readable", systemImage: "textformat")
                        }
                    }
                    if formatsAvailable.pdf == true {
                        Button {
                            pdfViewerSheet.toggle()
                        } label: {
                            Label("PDF", systemImage: "doc")
                        }
                    }
                    if formatsAvailable.image == true {
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
    
    @ViewBuilder
    fileprivate func availableFormatsButtons(_ formatsAvailable: FormatsAvailable) -> some View {
        if formatsAvailable.html == true || formatsAvailable.reader == true || formatsAvailable.pdf == true || formatsAvailable.image == true {           Spacer()
            Group {
                if item.monolith != nil && item.monolith != "unavailable" {
                    Button {
                        websiteViewerSheet.toggle()
                    } label: {
                        Image("htmltag-gray")
                            .resizable()
                            .frame(width: 12, height: 12)
                    }
                }
                if formatsAvailable.reader == true {
                    Button {
                        readerModeSheet.toggle()
                    } label: {
                        Label("Reader mode", systemImage: "textformat")
                    }
                }
                if formatsAvailable.pdf == true {
                    Button {
                        pdfViewerSheet.toggle()
                    } label: {
                        Label("Download PDF file", systemImage: "doc")
                    }
                }
                if formatsAvailable.image == true {
                    Button {
                        imageViewerSheet.toggle()
                    } label: {
                        Label("Download image file", systemImage: "photo")
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .labelStyle(.iconOnly)
        }
        else {
            Spacer()
        }
    }
}
