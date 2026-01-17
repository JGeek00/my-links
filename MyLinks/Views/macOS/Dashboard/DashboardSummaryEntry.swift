import SwiftUI

struct SummaryEntry: View {
    var icon: String
    var label: String
    var value: Int
    var color: Color
    var status: Enums.Status
    
    init(icon: String, label: String, value: Int, color: Color, status: Enums.Status) {
        self.icon = icon
        self.label = label
        self.value = value
        self.color = color
        self.status = status
    }
    
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(Color.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(6)
            Spacer()
                .frame(width: 12)
            VStack {
                Text(LocalizedStringKey(label))
                    .lineLimit(1)
                    .fontWeight(.bold)
                Spacer()
                    .frame(height: 6)
                if status == .loading {
                    ProgressView()
                }
                else if status == .error {
                    Image(systemName: "exclamationmark.circle")
                }
                else {
                    Text(String(value))
                        .font(.system(size: 18))
                }
            }
            Spacer()
        }
    }
}
