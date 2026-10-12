import SwiftUI

struct DashboardDetailView: View {
    let linkOpen: SelectedLinkOpen
    let isArrangementView: Bool
    
    init(linkOpen: SelectedLinkOpen, isArrangementView: Bool = false) {
        self.linkOpen = linkOpen
        self.isArrangementView = isArrangementView
    }
    
    var body: some View {
        Group {
            switch linkOpen.type {
            case .url:
                EmbeddedBrowserView(link: linkOpen.link, collapsibleToolbar: !isArrangementView)
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

