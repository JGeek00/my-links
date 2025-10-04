import SwiftUI

struct ViewAllButton: View {
    var action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        if #available(iOS 26, *) {
            Button {
                action()
            } label: {
                Text("View all")
                Image(systemName: "chevron.right")
            }
            .font(.system(size: 14))
        }
        else {
            Button {
                action()
            } label: {
                Text("View all")
                Image(systemName: "chevron.right")
            }
            .font(.system(size: 12))
        }
    }
}
