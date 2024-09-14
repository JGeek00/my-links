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
    
    enum LinkTaskCompleted: String {
        case delete
        case pin
        case edit
        case create
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
        case pinned
        case collections
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
    
    enum CollectionViewMode: String {
        case list
        case tabs
    }
}
