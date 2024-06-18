import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsViewModel = SettingsViewModel()
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        NavigationStack {
            List {
                Picker("Theme", selection: $theme) {
                    HStack {
                        Image(systemName: "iphone")
                            .padding(.trailing, 6)
                        Text("System defined")
                    }
                    .tag(Enums.Theme.system)
                    HStack {
                        Image(systemName: "sun.max")
                            .padding(.trailing, 6)
                        Text("Light")
                    }
                    .tag(Enums.Theme.light)
                    HStack {
                        Image(systemName: "moon")
                            .padding(.trailing, 6)
                        Text("Dark")
                    }
                    .tag(Enums.Theme.dark)
                }
                .pickerStyle(.inline)
                Section {
//                    NavigationLink {
//                        TipsView()
//                    } label: {
//                        Text("Give a tip to the developer")
//                    }
                    Button {
                        settingsViewModel.contactDeveloperSafariOpen.toggle()
                    } label: {
                        HStack {
                            Text("Contact the developer")
                                .foregroundColor(.foreground)
                            Spacer()
                            Image(systemName: "link")
                                .foregroundColor(Color.listItemValue)
                        }
                    }
                    HStack {
                        Text("App version")
                        Spacer()
                        Text(settingsViewModel.showBuildNumber == true ? buildNumber : version)
                            .foregroundColor(Color.listItemValue)
                            .animation(.default, value: settingsViewModel.showBuildNumber)
                            .onTapGesture {
                                settingsViewModel.showBuildNumber.toggle()
                            }
                    }
                } header: {
                    Text("About the app")
                } footer: {
                    HStack {
                        Spacer()
                        Text("Created on 🇪🇸 by JGeek00")
                            .multilineTextAlignment(.center)
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .fullScreenCover(isPresented: $settingsViewModel.contactDeveloperSafariOpen, content: {
                SFSafariViewWrapper(url: URL(string: Urls.appSupport)!).ignoresSafeArea()
            })
        }
    }
}
