import SwiftUI

struct InvalidUrlView: View {
    var onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                ContentUnavailableView("Invalid URL", systemImage: "link", description: Text("The provided URL is not valid."))
                Spacer()
            }
            .navigationTitle("Create new link")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onClose()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundColor(Color.foreground.opacity(0.5))
                    }
                    .buttonStyle(BorderedButtonStyle())
                    .clipShape(Circle())
                }
            }
        }
        .fontDesign(.rounded)
    }
}
