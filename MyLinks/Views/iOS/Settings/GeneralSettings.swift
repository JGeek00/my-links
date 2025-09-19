import SwiftUI

struct GeneralSettings: View {
    init() {}
    
    @State var disconnectAlert = false
    @State var collectionsViewModeSheet = false
    
    @AppStorage(StorageKeys.showFavicons, store: UserDefaults.shared) private var showFavicons: Bool = true
    
    var body: some View {
        NavigationStack {
            List {
                Section("Links") {
                    Toggle("Show favicons", isOn: $showFavicons)
                }
                
                Section("Server") {
                    Button {
                        disconnectAlert.toggle()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "xmark", iconColor: .red, textColor: .red, label: "Disconnect from server")
                    }
                    .alert("Disconnect from server", isPresented: $disconnectAlert) {
                        Button("Cancel", role: .cancel) {
                            disconnectAlert.toggle()
                        }
                        Button("Disconnect", role: .destructive) {
                            ApiClientProvider.shared.destroy()
                        }
                    } message: {
                        Text("You will have to establish a connection again.")
                    }
                }
            }
            .navigationTitle("General settings")
        }
    }
}
