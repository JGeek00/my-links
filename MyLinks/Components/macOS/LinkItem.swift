import SwiftUI

struct LinkItemComponent: View {
    var item: Link
    
    init(item: Link) {
        self.item = item
    }
    
    @Environment(\.openURL) var openURL
    
    var body: some View {
        let urlHost = getUrlHost(item.url!)
        let dateFormatted = item.createdAt != nil ? formatDate(item.createdAt!) : nil
        Button {
            openURL(URL(string: item.url!)!)
        } label: {
            VStack(alignment: .leading) {
                Text(item.name != "" ? item.name! : item.description != "" ? item.description! : item.url!)
                    .lineLimit(1)
                    .fontWeight(.medium)
                if let urlHost = urlHost {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        Image(systemName: "link")
                            .font(.system(size: 10))
                        Text(urlHost)
                            .font(.system(size: 14))
                    }
                    .foregroundStyle(Color.gray)
                }
                if dateFormatted != nil || (item.collection?.name != nil) {
                    Spacer()
                        .frame(height: 4)
                    HStack {
                        if let name = item.collection?.name {
                            Image(systemName: "folder")
                                .font(.system(size: 10))
                            Text(name)
                                .font(.system(size: 14))
                        }
                        if let dateFormatted =  dateFormatted {
                            Spacer()
                            Image(systemName: "calendar")
                                .font(.system(size: 12))
                            Text(dateFormatted)
                                .font(.system(size: 14))
                        }
                    }
                    .foregroundStyle(Color.gray)
                }
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
    }
}
