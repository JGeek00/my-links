import SwiftUI

struct GeneralSettings: View {
    init() {}
    
    @State var disconnectAlert = false
    @State var collectionsViewModeSheet = false
    
    @AppStorage(StorageKeys.showFavicons, store: UserDefaults.shared) private var showFavicons: Bool = true
    
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    
    var body: some View {
        NavigationStack {
            List {
                Section("Links") {
                    Toggle("Show favicons", isOn: $showFavicons)
                }
                
                Section("Server") {
                    if let instance = apiClientProvider.instance {
                        if instance.isSelfHosted == true {
                            Text(instance.url)
                                .foregroundStyle(Color.gray)
                        }
                        else {
                            Text("Cloud mode")
                                .foregroundStyle(Color.gray)
                        }
                        Button {
                            disconnectAlert.toggle()
                        } label: {
                            Text(instance.isSelfHosted ==  true ? "Disconnect" : "Log out")
                                .foregroundStyle(Color.red)
                        }
                        .alert("Disconnect from server", isPresented: $disconnectAlert) {
                            Button("Cancel", role: .cancel) {
                                disconnectAlert.toggle()
                            }
                            Button(instance.isSelfHosted == true ? "Disconnect" : "Log out", role: .destructive) {
                                ApiClientProvider.shared.destroy()
                            }
                        } message: {
                            Text("You will have to establish a connection again.")
                        }
                    }
                }
            }
            .navigationTitle("General settings")
        }
    }
}
