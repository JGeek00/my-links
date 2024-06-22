import SwiftUI

struct ConnectionForm: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    
    var body: some View {
        if onboardingViewModel.hostingMode == nil {
            VStack {
                Spacer()
                Button("Back to hosting mode selection") {
                    withAnimation(.default) {
                        onboardingViewModel.selectedTab = 1
                    }
                }
                Spacer()
            }
        }
        else {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 60))
                        Spacer()
                            .frame(height: 24)
                        Text("Setup the server connection")
                            .fontWeight(.semibold)
                            .font(.system(size: 30))
                    }
                }
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
                Section("Authentication") {
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
                Section {
                    Button {
                        onboardingViewModel.onConnect()
                    } label: {
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
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(.vertical, 6)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                Section {
                    Button {
                        withAnimation(.default) {
                            onboardingViewModel.selectedTab = 1
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.left")
                            Text("Back")
                            Spacer()
                        }
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
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
        }
    }
}
