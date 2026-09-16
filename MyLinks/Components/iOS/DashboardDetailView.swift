import SwiftUI

struct DashboardDetailView: View {
    let linkOpen: SelectedLinkOpen
    
    init(linkOpen: SelectedLinkOpen) {
        self.linkOpen = linkOpen
    }
    
    var body: some View {
        Group {
            switch linkOpen.type {
            case .url:
                EmbeddedBrowserView(link: linkOpen.link)
                .id(linkOpen.link.id)
            case .webpage:
                HTMLViewer(link: linkOpen.link, mode: .webpage, onClose: nil)
            case .imageDocument:
                ImageViewerView(link: linkOpen.link, onClose: nil)
            case .pdfDocument:
                PDFViewerView(link: linkOpen.link, onClose: nil)
            case .readableMode:
                HTMLViewer(link: linkOpen.link, mode: .reader, onClose: nil)
            }
        }
    }
}

