import SwiftUI

struct SquareIcon: View {
    var icon: String
    var color: Color

    init(icon: String, color: Color) {
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
        Image(systemName: icon)
            .foregroundStyle(Color.white)
            .frame(width: 28, height: 28)
            .background(color)
            .cornerRadius(6)
    }
}
