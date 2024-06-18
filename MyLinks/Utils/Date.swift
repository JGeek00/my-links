import Foundation

func formatDate(_ originalDateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

    if let date = dateFormatter.date(from: originalDateString) {
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "MMM dd, yyyy"
        
        let formattedDateString = outputDateFormatter.string(from: date)
        return formattedDateString
    } else {
        return nil
    }
}
