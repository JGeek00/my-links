import SwiftUI

struct ConnectionForm: View {
    @Environment(OnboardingViewModel.self) private var onboardingViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var tokenInstructionsSheet = false
    
    var body: some View {
        @Bindable var onboardingViewModel = onboardingViewModel
        Form {
            Section {} header: {
                VStack(alignment: .leading) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 60))
                    Spacer()
                        .frame(height: 24)
                    Text("Setup the server connection")
                        .fontWeight(.semibold)
                        .font(.system(size: 30))
                }
                .foregroundStyle(Color.foreground)
                .padding(.vertical, 24)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                    TextField("Port", text: $onboardingViewModel.port)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    TextField("Path", text: $onboardingViewModel.path)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
            }
            Section {
                Picker("Method", selection: $onboardingViewModel.authMethod) {
                    Text("Username and password")
                        .tag(Enums.AuthMethod.userPass)
                    Text("Access token")
                        .tag(Enums.AuthMethod.token)
                }
                switch onboardingViewModel.authMethod {
                case .userPass:
                    TextField("Username or email", text: $onboardingViewModel.username)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $onboardingViewModel.password)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                case .token:
                    HStack {
                        SecureField("Token", text: $onboardingViewModel.token)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        Button {
                            if let clipboardText = UIPasteboard.general.string {
                                onboardingViewModel.token = clipboardText
                            }
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            } header: {
                Text("Authentication")
            } footer: {
                VStack {
                    if onboardingViewModel.authMethod == .token {
                        Button("How to get an API token") {
                            tokenInstructionsSheet = true
                        }
                        .font(.system(size: 12))
                    }
                    Spacer()
                    let backContent = HStack {
                        Spacer()
                        Image(systemName: "chevron.left")
                        Text("Back")
                        Spacer()
                    }
                    .fontWeight(.semibold)

                    let connectContent = Group {
                        Spacer()
                        if onboardingViewModel.connecting == true {
                            ProgressView()
                        }
                        else {
                            Text("Connect")
                                .fontWeight(.semibold)
                                .font(.system(size: 18))
                        }
                        Spacer()
                    }

                    HStack {
                        if #available(iOS 26, *) {
                            Button {
                                withAnimation(.default) {
                                    onboardingViewModel.selectedTab = 1
                                }
                            } label: {
                                backContent
                            }
                            .buttonStyle(.glass)
                            Spacer()
                                .frame(width: 16)
                            Button {
                                onboardingViewModel.onConnect()
                            } label: {
                                connectContent
                            }
                            .buttonStyle(.glassProminent)
                        }
                        else {
                            Button {
                                withAnimation(.default) {
                                    onboardingViewModel.selectedTab = 1
                                }
                            } label: {
                                backContent
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                                .frame(width: 16)
                            Button {
                                onboardingViewModel.onConnect()
                            } label: {
                                connectContent
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 32)
                    .disabled(onboardingViewModel.connecting)
                }
            }
        }
        .disabled(onboardingViewModel.connecting)
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
        .sheet(isPresented: $tokenInstructionsSheet, content: {
            TokenInstructions {
                tokenInstructionsSheet = false
            }
        })
    }
}
