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
                .font(.system(size: 14))
                .fontWeight(.medium)
                .padding()
            }
            .navigationTitle("Token instructions")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        onClose()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
        .frame(width: 400, height: 300)
    }
}
