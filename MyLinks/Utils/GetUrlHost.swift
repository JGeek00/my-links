import Foundation

func getUrlHost(_ urlString: String) -> String? {
    guard let url = URL(string: urlString) else {
        return nil
    }
    
    guard let host = url.host else {
        return nil
    }
    
    return host
}
