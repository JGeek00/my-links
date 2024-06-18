import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        NavigationStack {
            List {
                Picker("Theme", selection: $theme) {
                    Label("System defined", systemImage: "iphone")
                        .tag(Enums.Theme.system)
                    Label("Light", systemImage: "sun.max")
                        .tag(Enums.Theme.light)
                    Label("Dark", systemImage: "moon")
                        .tag(Enums.Theme.dark)
                }
                .foregroundStyle(Color.foreground)
                .pickerStyle(.inline)
                Section {
                    Button {
                        settingsViewModel.disconnectServer()
                    } label: {
                        Label("Disconnect from server", systemImage: "xmark")
                            .foregroundStyle(Color.red)
                    }
                }
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
