import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    
    @State var disconnectAlert = false
    
    @AppStorage(StorageKeys.showFavicons, store: UserDefaults.shared) private var showFavicons: Bool = true
    @AppStorage(StorageKeys.showPinnedBeforeRecent, store: UserDefaults.shared) private var showPinnedBeforeRecent: Bool = true
    
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        NavigationStack {
            Form {
                Picker("Theme", selection: $theme) {
                    Text("System defined")
                        .tag(Enums.Theme.system)
                    Text("Light")
                        .tag(Enums.Theme.light)
                    Text("Dark")
                        .tag(Enums.Theme.dark)
                }
                .pickerStyle(.radioGroup)
                Section("Dashboard") {
                    Toggle("Show pinned section before recent", isOn: $showPinnedBeforeRecent)
                }
                Section("Links") {
                    Toggle("Show favicons", isOn: $showFavicons)
                }
                Section("Server") {
                    if let instance = apiClientProvider.instance {
                        if instance.isSelfHosted == true {
                            HStack {
                                Text(instance.url)
                                Spacer()
                                Image(systemName: "server.rack")
                            }
                            .foregroundStyle(Color.gray)
                        }
                        else {
                            HStack {
                                Image(systemName: "cloud.fill")
                                Spacer()
                                    .frame(width: 16)
                                Text("Cloud mode")
                            }
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
                Section("Linkwarden") {
                    Button {
                        openURL(URL(string: Urls.linkwardenSite)!)
                    } label: {
                        ListRowWithIconEntry(systemIcon: "network", iconColor: .blue, label: "Website")
                    }
                    Button {
                        openURL(URL(string: Urls.linkwardenRepo)!)
                    } label: {
                        ListRowWithIconEntry(assetIcon: colorScheme == .dark ? "github" : "github-white", iconColor: Color.gitHub, label: "Repository")
                    }
                }
                Section {
                    NavigationLink {
                        TipsView()
                    } label: {
                        ListRowWithIconEntry(systemIcon: "dollarsign.circle.fill", iconColor: .green, label: "Give a tip to the developer")
                    }
                    Button {
                        openURL(URL(string: Urls.appSupport)!)
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
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Settings")
            .formStyle(GroupedFormStyle())
            .buttonStyle(PlainButtonStyle())
            .preferredColorScheme(getColorScheme(theme: theme))
        }
    }
}
