import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    
    @State var disconnectAlert = false
    
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
