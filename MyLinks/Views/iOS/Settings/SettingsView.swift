import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @Environment(\.colorScheme) private var colorScheme
    
    @State var disconnectAlert = false
    
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        NavigationStack {
            List {
                Picker("Theme", selection: $theme) {
                    ListRowWithIconEntry(systemIcon: "iphone", iconColor: .green, label: "System defined")
                        .tag(Enums.Theme.system)
                    ListRowWithIconEntry(systemIcon: "sun.max.fill", iconColor: .orange, label: "Light")
                        .tag(Enums.Theme.light)
                    ListRowWithIconEntry(systemIcon: "moon.fill", iconColor: .indigo, label: "Dark")
                        .tag(Enums.Theme.dark)
                }
                .pickerStyle(.inline)
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
                Section("Linkwarden") {
                    Button {
                        settingsViewModel.linkwardenSiteOpen.toggle()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "network", iconColor: .blue, label: "Website")
                    }
                    Button {
                        settingsViewModel.linkwardenRepoOpen.toggle()
                    } label: {
                        ListRowWithIconEntry(assetIcon: colorScheme == .dark ? "github" : "github-white", iconColor: Color.gitHub, label: "Repository")
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
                        ListRowWithIconEntry(systemIcon: "message.fill", iconColor: .brown, label: "Contact the developer")
                    }
                    HStack {
                        ListRowWithIconEntry(systemIcon: "info.circle.fill", iconColor: .teal, label: "App version")
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
            .fullScreenCover(isPresented: $settingsViewModel.linkwardenSiteOpen, content: {
                SFSafariViewWrapper(url: URL(string: Urls.linkwardenSite)!).ignoresSafeArea()
            })
            .fullScreenCover(isPresented: $settingsViewModel.linkwardenRepoOpen, content: {
                SFSafariViewWrapper(url: URL(string: Urls.linkwardenRepo)!).ignoresSafeArea()
            })
        }
    }
}
