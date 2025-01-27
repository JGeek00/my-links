import SwiftUI

struct FaviconImage: View {
    var linkUrl: String
    
    init(linkUrl: String) {
        self.linkUrl = linkUrl
    }
    
    var body: some View {
        AsyncImage(url: URL(string: "https://t2.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=\(linkUrl)&size=32")) { phase in
            switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .scaledToFit()
                        .shimmer()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure:
                    Image(systemName: "globe")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
        .frame(width: 16, height: 16)
    }
}
