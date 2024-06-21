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
    }
}
