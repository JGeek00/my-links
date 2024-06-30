import SwiftUI

struct TokenInstructions: View {
    var onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    Text("1. Log in into your Linkwarden account.")
                    Text("2. Click on your profile picture and then on Settings.")
                    Text("3. Go to the Access tokens section.")
                    Text("4. Create a new access token, set a name and set no expiration date.")
                    Text("5. Copy the generated API token and paste it into the token field of MyLinks.")
                }
                .font(.system(size: 18))
                .fontWeight(.medium)
                .padding()
            }
            .navigationTitle("Token instructions")
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
    }
}
