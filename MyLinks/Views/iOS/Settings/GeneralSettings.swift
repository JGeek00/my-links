import SwiftUI

struct GeneralSettings: View {
    init() {}
    
    @State var disconnectAlert = false
    @State var collectionsViewModeSheet = false
    
    @AppStorage(StorageKeys.showFavicons, store: UserDefaults.shared) private var showFavicons: Bool = true
    @AppStorage(StorageKeys.openLinkByDefault, store: UserDefaults.shared) private var openLinkByDefault: Enums.OpenLinkByDefault = .internalBrowser
    
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Show favicons", isOn: $showFavicons)
                    Picker("Open by default", selection: $openLinkByDefault) {
                        Section {
                            Text("Internal browser")
                                .tag(Enums.OpenLinkByDefault.internalBrowser)
                            Text("System browser")
                                .tag(Enums.OpenLinkByDefault.systemBrowser)
                        }
                        Section {
                            Text("Readable mode")
                                .tag(Enums.OpenLinkByDefault.readableMode)
                            Text("PDF document")
                                .tag(Enums.OpenLinkByDefault.pdfDocument)
                            Text("Image document")
                                .tag(Enums.OpenLinkByDefault.imageDocument)
                        }
                    }
                    .pickerStyle(.menu)
                } header: {
                    Text("Links")
                } footer: {
                    VStack(alignment: .leading) {
                        Text("Open by default")
                            .fontWeight(.semibold)
                        Text("In case of the selected option is not available for a specific item, if the item is a link will always fallback to Internal browser, and if the item is a file will always fallback to the file viewer.")
                    }
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
