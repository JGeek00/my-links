import Foundation

class Enums {
    enum Hosting: String {
        case cloud
        case selfhosted
    }
    
    enum ConnectionMethod: String {
        case http
        case https
    }
    
    enum AuthMethod: String {
        case userPass
        case token
    }
    
    public enum Theme: String {
        case system
        case light
        case dark
        
        init?(stringValue: String) {
            switch stringValue.lowercased() {
                case "system":
                    self = .system
                case "light":
                    self = .light
                case "dark":
                    self = .dark
                default:
                    return nil
            }
        }
    }
    
    enum Status: String {
        case loaded
        case loading
        case error
    }
    
    enum LoadingState<T> {
        case loading
        case success(T)
        case failure
        
        var isLoading: Bool {
            if case .loading = self {
                return true
            }
            return false
        }
        
        var data: T? {
            if case .success(let data) = self {
                return data
            }
            return nil
        }
        
        var error: Bool {
            if case .failure = self {
                return true
            }
            return false
        }
    }
    
    
    enum LinkFormMode: String {
        case creation
        case editing
    }
    
    enum LinksFilteredMode: String {
        case collection
        case tag
        case recent
        case pinned
    }
    
    enum LinkFormAction: String {
        case create
        case edit
    }
    
    enum LinkTaskAction: String {
        case edit
        case delete
    }
    
    enum CollectionFormAction: String {
        case edit
        case create
    }
    
    enum CollectionTaskAction: String {
        case edit
        case delete
    }
    
    enum PinUnpinAction: String {
        case pin
        case unpin
    }
    
    enum SortingOptions: Int {
        case dateNewestFirst
        case dateOldestFirst
        case nameAZ
        case nameZA
        case descriptionAZ
        case descriptionZA
    }
    
    enum DashboardView: String {
        case dashboard
        case links
        case collections
        case tags
    }
    
    enum DownloadDocumentType: String {
        case pdf
        case image
    }
    
    enum LinkFormItem: String {
        case url
        case file
    }
    
    enum HTMLViewerMode: String {
        case reader
        case webpage
    }
    
    enum CollectionListMode: String {
        case links
        case subcollections
    }
    
    enum TabViewTabs {
        case home
        case catalog
        case settings
        case search
    }
    
    enum ElementsDetailView: String, CaseIterable {
        case links = "Links"
        case collections = "Collections"
        case tags = "Tags"
    }
    
    enum OpenLinkByDefault: String {
        case internalBrowser
        case systemBrowser
        case readableMode
        case pdfDocument
        case imageDocument
    }
}
