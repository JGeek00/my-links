func openLinkHandler(link: Link, defaultOption: Enums.OpenLinkByDefault) -> Enums.OpenLinkAction? {
    switch link.type {
    case .image:
        return .imageDocument
    case .pdf:
        return .pdfDocument
    case .url:
        switch defaultOption {
        case .imageDocument:
            return .imageDocument
        case .pdfDocument:
            return .pdfDocument
        case .internalBrowser:
            return .url
        case .readableMode:
            return .readableMode
        case .systemBrowser:
            return nil
        }
    }
}
