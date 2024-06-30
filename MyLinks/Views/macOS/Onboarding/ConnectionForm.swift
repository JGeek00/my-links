import SwiftUI

struct ConnectionForm: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var tokenInstructionsSheet = false
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(alignment: .center) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 40))
                    Spacer()
                        .frame(height: 18)
                    Text("Setup the server connection")
                        .fontWeight(.semibold)
                        .font(.system(size: 24))
                }
                Spacer()
            }
            Spacer()
                .frame(height: 24)
            ScrollView {
                Form {
                    Section {
                        Picker("Server type", selection: $onboardingViewModel.hostingMode) {
                            Text("Cloud")
                                .tag(Enums.Hosting.cloud)
                            Text("Self hosted")
                                .tag(Enums.Hosting.selfhosted)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    if onboardingViewModel.hostingMode == .selfhosted {
                        Section("Server route") {
                            Picker("Connection method", selection: $onboardingViewModel.connectionMethod) {
                                Text("HTTP")
                                    .tag(Enums.ConnectionMethod.http)
                                Text("HTTPS")
                                    .tag(Enums.ConnectionMethod.https)
                            }
                            TextField("IP address or domain", text: $onboardingViewModel.ipDomain)
                                .autocorrectionDisabled()
                            TextField("Port", text: $onboardingViewModel.port)
                                .autocorrectionDisabled()
                            TextField("Path", text: $onboardingViewModel.path)
                                .autocorrectionDisabled()
                        }
                    }
                    Section {
                        SecureField("Token", text: $onboardingViewModel.token)
                            .autocorrectionDisabled()
                    } header: {
                        Text("Authentication")
                    } footer: {
                        Button("How to get an API token") {
                            tokenInstructionsSheet = true
                        }
                        .font(.system(size: 12))
                    }
                    Section {
                        Button {
                            onboardingViewModel.onConnect()
                        } label: {
                            Group {
                                Spacer()
                                if onboardingViewModel.connecting == true {
                                    ProgressView()
                                }
                                else {
                                    Text("Connect")
                                        .fontWeight(.semibold)
                                        .font(.system(size: 16))
                                }
                                Spacer()
                            }
                            .frame(height: 30)
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .disabled(onboardingViewModel.connecting)
                .formStyle(.grouped)
            }
            .alert("Invalid values", isPresented: $onboardingViewModel.invalidValuesAlert, actions: {
                Button {
                    onboardingViewModel.invalidValuesAlert.toggle()
                } label: {
                    Text("Close")
                }
            }, message: {
                Text(onboardingViewModel.invalidValuesMessage)
            })
            .alert("Connection error", isPresented: $onboardingViewModel.connectionErrorAlert, actions: {
                Button {
                    onboardingViewModel.connectionErrorAlert.toggle()
                } label: {
                    Text("Close")
                }
            }, message: {
                Text(onboardingViewModel.connectionErrorMessage)
            })
            .frame(maxWidth: 500, maxHeight: 500)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
